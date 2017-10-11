/******************************************************************************/
/*                                                                            */
/* Name: freePortReceive.c  - mex function for the communication to the       */
/*                            free asynchronous serial interface SCI0/1       */
/*                                                                            */
/******************************************************************************/

// =============================================================================
// fw-10-06
// =============================================================================

/* undefine VERBOSE to run this DLL in silent mode */
//#define VERBOSE


#include "mex.h"
#include "matrix.h"
#ifdef EXTERN_C
#undef EXTERN_C                 // required when using 'lcc' (fw-06-07)
#endif
#include <windows.h>			// BuildCommDCB, CloseHandle, CreateFile, EscapeCommFunction, GetCommState,
								// GetLastError, ReadFile, SetCommState, SetCommTimeouts, WriteFile, FlushFileBuffers
								// Sleep
#include <stdio.h>				// sprintf
#include <stdlib.h>				// malloc, calloc
#include <string.h>				// memcpy

#include "mc_freePortComms.h"		// macros, struct myUsrBuf


// DEFINE global user communication admin variables
myUsrBuf	*freecomTelBuf[MAX_FREECOM_CHANNELS];		/* pointer to the data buffer admin structures of all user telegrams */



// ----------------------------------------------------------------------------------------------------
// global variables
// ----------------------------------------------------------------------------------------------------

// input signals may have the following bytes per element
#define		numDATATYPES	8
const unsigned int BuiltInDTypeSize[numDATATYPES] =	{
															4,    /* single  : ID = 0*/
															1,    /* int8    : ID = 1 */
															1,    /* uint8   : ID = 2 */
															2,    /* int16   : ID = 3 */
															2,    /* uint16  : ID = 4 */
															4,    /* int32   : ID = 5 */
															4,    /* uint32  : ID = 6 */
															2     /* boolean : ID = 7 */
														};


#define  tSINGLE  	0
#define  tINT8  	1
#define  tUINT8  	2
#define  tINT16  	3
#define  tUINT16  	4
#define  tINT32  	5
#define  tUINT32  	6
#define  tBOOLEAN	7

// map BAUDRATE parameter (1 - 10) to true baudrates
#define		numBAUDRATES	10
const unsigned int BaudRates[numBAUDRATES] =	{
													300,
													600,
												   1200,
												   2400,
												   4800,
												   9600,
												  19200,
												  38400,
												  57600,
												 115200
												};


// DEFINE maximum number of elements per channel transmission
// (inconsistent -> see freePortComms.h, macro MAX_FREECOM_BUF_SIZE  --  fw-10-05)
#define		maxNUMELEMENTS			100


/* receive */
BOOL     ReceiveTimeoutFlag;


// flag : communication with/without echo?
#define with_echo  TRUE
#define no_echo    FALSE

// flag : display on-screen timeout messages?
#define with_to_messages  TRUE 
#define no_to_messages    FALSE


/* descramble buffer ... (fw-09-06) */
unsigned char	receivebuf[MAX_FREECOM_BUF_SIZE + 10];



// ----------------------------------------------------------------------------------------------------
// local methods
// ----------------------------------------------------------------------------------------------------

/* allocate and initialise the communication variables associated with a particular channel (buffer, admin, ... ) */
static myUsrBuf *AllocateUserBuffer(uint_T channel, uint_T bufsize, uint8_T data_type_len) {

	uint8_T			*buf;
	static myUsrBuf	*admin = NULL;

	/* allocate memory for admin structure of this instance's data buffer */
	if((admin = (myUsrBuf *)calloc(1, sizeof(myUsrBuf))) == NULL)  return NULL;
		
	/* allocate memory for the buffer itself (buf_size '+ 4'  ->  telegram size, channel number, data type length, '0' [reserved]) */
	if((buf = (uint8_T *)calloc(bufsize + 4, sizeof(uint8_T))) == NULL)  return NULL;

	/* store pointer to buf in the admin structure */
	admin->buf = buf;

	/* store size of the actual data buffer */
	admin->buf_size = bufsize;

	/* initialise the access_count field */
	admin->access_count = 1;

	/* initialise the buffer_full flag */
	admin->buffer_full = 0;

	/* initialise the header_received flag (although it's not used by freePortReceive, fw-08-07) */
	admin->header_received = 0;


	/* initialise buffer */

	/* set first field of the buffer to the number of bytes per user telegram (remains invariant)... */
	buf[0] = (uint8_T)(bufsize + 4);

	/* set second field of the buffer to the channel number (remains invariant)... */
	buf[1] = (uint8_T)channel;

	/* set third field of the buffer to the channel data type length: 1, 2, 4) (remains invariant)... */
	buf[2] = data_type_len;

	//mexPrintf("Setting channel %d data type length to: %d\n", channel, data_type_len);

	/* ... and clear the reserved byte (buf[3]) as well as the local data buffer */
	memset(&buf[3], 0, bufsize + 1);
	

	/* return access pointer */
	return admin;
}
		

/* Function: checkCOMforData ===================================================
 * check if there's data in the COM buffer (FW-09-02)
 */
static int checkCOMforData(HANDLE hCom) {

	COMSTAT		cs;
	DWORD		error;

	//mexPrintf("checkCOM4data: IN.\n");

	/* only check port if 'hCom' is valid... */
    if (hCom != INVALID_HANDLE_VALUE) {

		// reset error status (returns structure COMSTAT [winbase.h])
		if(!ClearCommError(hCom, (LPDWORD)&error, (LPCOMSTAT)&cs)) {
			// error during call to ClearCommError
			mexPrintf("checkCOM4data: Error during call to ClearCommError.\n");

			// flag error to the calling function
			return -1;
		}
		else {
		
			// debug
			//mexPrintf("FreePort: checkCOMforData detected %d data bytes in COM buffer\n", (int)cs.cbInQue);
		
			// return number of bytes in the buffer
			return (int)cs.cbInQue;
		}

	} else {

		/* port handle not valid (not a COM port) */
		//mexPrintf("checkCOM4data: OUT (not valid).\n");
		return -1;

	}

} /* end checkCOMforData */



/* Function: FreePortOpenConnection =================================================
 *
 *  Open the connection with the target using the free communication port.
 */
HANDLE FreePortOpenConnection(unsigned int port, unsigned int baudrate) {

	HANDLE			hCom = INVALID_HANDLE_VALUE;
	static char    COMxString[5];								// serial interface designator
	char		    COMxStringParam[16];
	DCB		        dcb;
	COMMTIMEOUTS	CommTimeouts;

	char			tmp[512];									// error messages

	// default communication parameters (dummy)
	#define	DefaultComParam ":9600,n,8,1"

	// default timeout value (ms) - send and receive
	#define	DefaultTimeout		10000


	#ifdef VERBOSE
	mexPrintf("freePortReceive|FreePortOpenConnection: IN\n");
	#endif /* VERBOSE */


	// open serial interface 'COMxString'
	sprintf(COMxString, "COM%1d", (uint8_T)port);
	hCom = CreateFile (COMxString, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);
	if (hCom == INVALID_HANDLE_VALUE) {

		sprintf(tmp, "Error while trying to open serial interface %s:\n", COMxString);
		mexErrMsgTxt(tmp);
	}

	// initialise 'DCB' structure
	dcb.DCBlength = sizeof (DCB);
	if (!GetCommState (hCom, &dcb)) {

		mexErrMsgTxt("Error while trying to determine current state of the COM interface.\n");
	}

	sprintf (COMxStringParam, "%s%s", COMxString, DefaultComParam);
	if (!BuildCommDCB (COMxStringParam, &dcb)) {

		mexErrMsgTxt("Error while generating DCB data structure,\n");

	}

	// set transmission parameters
	dcb.BaudRate = baudrate;						// transmission speed (bps)
	dcb.fRtsControl = RTS_CONTROL_DISABLE;			// RTS = 'low' (mis-used to generate a software 'reset'...
	dcb.fOutX = FALSE;								// disable XON/XOFF protocol
	dcb.fInX = FALSE;								// (both for TX and RX)

	// initialise serial interface 'hCom'
	if (!SetCommState (hCom, &dcb)) {

		sprintf(tmp, "Error during initialisation of the serial interface %s:\n", COMxString);
		mexErrMsgTxt(tmp);
	}

	// reset 'hCom' and set length of input/output buffer to FREEPORT_HOST_BUF_SIZE (default: 1200) bytes (each)
	if (!SetupComm (hCom, FREEPORT_HOST_BUF_SIZE, FREEPORT_HOST_BUF_SIZE)) {

		sprintf(tmp, "Error during reset of the serial interface %s:\n", COMxString);
		mexErrMsgTxt(tmp);
	}

	// initialise all timeouts (send/receive) as 'DefaultTimeout' (1000 ms)
	CommTimeouts.ReadIntervalTimeout = DefaultTimeout;
	CommTimeouts.ReadTotalTimeoutMultiplier = DefaultTimeout;
	CommTimeouts.ReadTotalTimeoutConstant = DefaultTimeout;
	CommTimeouts.WriteTotalTimeoutMultiplier = DefaultTimeout;
	CommTimeouts.WriteTotalTimeoutConstant = DefaultTimeout;
	SetCommTimeouts(hCom, &CommTimeouts);

	/* make sure we start with an empty buffer... */
	if(!FlushFileBuffers(hCom)) {
				
		/* flushing of the output buffer returns unsuccessful... */
		mexPrintf ("freePortComms_rxd|FreePortOpenConnection: Error whilst flushing output buffers (FlushFileBuffers).\n");
		{
			DWORD err = GetLastError();
			mexPrintf("Error code: %ld\n", err);
		}
				
	}

	#ifdef VERBOSE
	mexPrintf("freePortReceive|FreePortOpenConnection: OUT\n");
	#endif /* VERBOSE */

	return hCom;

} /* end ExtOpenConnection */


/* Function: FreePortCloseConnection ================================================
 * 
 *  Close the connection via the free comms port.
 */
void FreePortCloseConnection(HANDLE hCom) {

	#ifdef VERBOSE
	mexPrintf("FreePortCloseConnection: IN\n");
	#endif

    if (hCom != INVALID_HANDLE_VALUE) {

		// close serial interface 'hCom'
		if(!CloseHandle(hCom)) {
			mexErrMsgTxt("Error when closing the serial interface.\n");
		}

	}

	#ifdef VERBOSE
	mexPrintf("FreePortCloseConnection: OUT\n");
	#endif

} /* end FreePortCloseConnection */


		
// =====================================================================================================
// Receive... receive a string from the serial interface 'hCom'
// =====================================================================================================

// CALL-UP PARAMETERS:
//
// '&r_zeichen':			store received characters here...
// 'z_len_toread':		number of characters to be read
// 'ReceiveTimeoutFlag':	TRUE (timeout occurred), FALSE (no timeout)
// 'TimeoutMessageFlag':	TRUE (onscreen timeout messages) / FALSE (no messages)
//
// RETURN VALUE:			TRUE (successful reception) / FALSE ('reception error' or 'timeout')


BOOL Receive (HANDLE hCom, BYTE r_zeichen[], DWORD z_len_toread, 
              BOOL *ReceiveTimeoutFlag, BOOL TimeoutMessageFlag)
{
DWORD		z_len_read;


   *ReceiveTimeoutFlag = FALSE;
   if (ReadFile(hCom, (LPSTR) r_zeichen, z_len_toread, &z_len_read, NULL))
   {
      if (z_len_read == z_len_toread)
	{
         // successful reception
         return (TRUE);
      }
      else
	{
	   // timeout occurred during reception of data
         if (TimeoutMessageFlag == with_to_messages)
            mexPrintf ("Receive: Timeout during data reception.\n");
         *ReceiveTimeoutFlag = TRUE;
         return (FALSE);
      }
   }
   else
   {
      // unspecified error during data reception
      mexPrintf ("Receive: Unspecified error during data reception.\n");
      return (FALSE);
   }
}


/* Function: ReverseOrder4 =================================================
 *
 *  Reverse the order of bytes in a 4-tuple
 */
void *ReverseOrder4(unsigned char *buf) {

unsigned char	temp;

	#ifdef VERBOSE
	{
		mexPrintf("ReverseOrder4 %d:%d:%d:%d >> ", buf[0], buf[1], buf[2], buf[3]);
	}
	#endif /* VERBOSE */

	temp   = buf[0];
	buf[0] = buf[3];
	buf[3] = temp;
	temp   = buf[1];
	buf[1] = buf[2];
	buf[2] = temp;
	
	#ifdef VERBOSE
	{
		mexPrintf("%d:%d:%d:%d\n", buf[0], buf[1], buf[2], buf[3]);
	}
	#endif /* VERBOSE */
	
	return (void *)buf;
	
}


/* Function: ReverseOrder2 =================================================
 *
 *  Reverse the order of bytes in a 2-tuple
 */
void *ReverseOrder2(unsigned char *buf) {

unsigned char	temp;

	#ifdef VERBOSE
	{
		mexPrintf("ReverseOrder2 %d:%d >> ", buf[0], buf[1]);
	}
	#endif /* VERBOSE */

	temp   = buf[0];
	buf[0] = buf[1];
	buf[1] = temp;
	
	#ifdef VERBOSE
	{
		mexPrintf("%d:%d\n", buf[0], buf[1]);
	}
	#endif /* VERBOSE */
	
	return (void *)buf;
	
}



// ----------------------------------------------------------------------------------------------------
// mex function
// ----------------------------------------------------------------------------------------------------

/* Function: mexFunction =======================================================
 * Abstract:
 *    Gateway from Matlab.
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    

mxArray		    *pArray;            /* output data */
mxArray		    *pArray2;           /* number of elements received */
mxArray			*FreePortAdminVar;
myCOMPort		**myPtr;

unsigned int	myPort = 1;
unsigned int	myBaud = 300;
unsigned int	myChannel = 0;
		 int	channel = -1;
unsigned int	myElements = 0;
unsigned char	mydType = 0;
unsigned int	myRawFlag;
unsigned int	buf_size = 0;
unsigned int	size;
unsigned char	*buf;
unsigned int	myBlockingFlag = 0;

myUsrBuf	*admin;
myCOMPort   *adminP = NULL;
uint8_T		*outBuf;
double		*outnEls;

#define	 NDIMS  2							// dimension of the output data
static unsigned int   dims[NDIMS];


	/* check syntax */
    if ((nlhs != 2) || (nrhs != 6)) {
        
        mexErrMsgTxt("Usage:  [data, nElementsReceived] = freePortReceive(COMx, baudrate, channel, nElememts, dataType, blockingFlag)\n");
        
    } else {
		
		/* syntax correct -> analyse inputs */
		int  k = 0;
		while(k < 6) {
		
			switch(k) {
				
				case 0:
					
					/* COM port */
					if(mxIsNumeric(prhs[k]) && !mxIsComplex(prhs[k])) {
						
						/* get COM port */
						myPort = (unsigned int)mxGetScalar(prhs[k]);
						
						if((myPort < 0) || (myPort > 30))
							mexErrMsgTxt("Invalid COM port number.\n");
						
						#ifdef VERBOSE
						mexPrintf("freePortReceive: COMx = %d\n", myPort);
						#endif /* VERBOSE */
						
					}
					else {
						
						mexErrMsgTxt("Parameter [COMx] needs to be a scalar number.\n");
						
					}
					
					k = k + 1;
					break;
					
				case 1:
					
					/* Baudrate */
					if(mxIsNumeric(prhs[k]) && !mxIsComplex(prhs[k])) {
						
						int i, m;
						
						/* get Baudrate */
						myBaud = (unsigned int)mxGetScalar(prhs[k]);
						
						/* check if this is a valid baudrate */
						for(i=0, m=-1; i<numBAUDRATES; i++) {
							
							#ifdef VERBOSE
							mexPrintf("freePortReceive: Checking baudrate: %d\n", BaudRates[i]);
							#endif /* VERBOSE */
							
							if(myBaud == BaudRates[i]) {
								
								#ifdef VERBOSE
								mexPrintf("freePortReceive: Detected supported baudrate (%d)\n", myBaud);
								#endif /* VERBOSE */
								
								m = i;
								break;
								
							}
							
						}
						
						if(m == -1) {
							
							mexErrMsgTxt("Unsupported baudrate.\n");
							
						}
						
					}
					else {
						
						mexErrMsgTxt("Parameter [baudrate] needs to be a scalar number.\n");
						
					}
					
					k = k + 1;
					break;
					
				case 2:
					
					/* channel */
					if(mxIsEmpty(prhs[k])) {
						
						/* channel undefined -> raw data transmission */
						myRawFlag = 1;
						myChannel = 0;		/* (ab)using 'channel 0' (admin) */
						
					}
					else {
						
						/* channel defined -> formatted transmission */
						myRawFlag = 0;
							
						if(mxIsNumeric(prhs[k]) && !mxIsComplex(prhs[k])) {
							
							/* get channel number */
							myChannel = (unsigned int)mxGetScalar(prhs[k]);
							
							if((myChannel < 0) || (myChannel > MAX_FREECOM_CHANNELS-1))
								mexErrMsgTxt("Invalid channel number.\n");
							
						}
						else {
							
							mexErrMsgTxt("Parameter [channel] needs to be a scalar number.\n");
							
						}	
						
					}
					
					#ifdef VERBOSE
					mexPrintf("freePortReceive: Channel = %d\n", myChannel);
					mexPrintf("freePortReceive: rawdata = %d\n", myRawFlag);
					#endif /* VERBOSE */
					
					k = k + 1;
					break;
					
				case 3:
					
					/* number of elements */
					if(mxIsNumeric(prhs[k]) && !mxIsComplex(prhs[k])) {
						
						/* get number of elements */
						myElements = (unsigned int)mxGetScalar(prhs[k]);
						
						if((myElements <= 0) || (myElements > maxNUMELEMENTS))
							mexErrMsgTxt("Invalid number of elements.\n");

						/* set dimensions of the output array (n x 1) */
						dims[0] = myElements;
						dims[1] = 1;
						
					}
					else {
						
						mexErrMsgTxt("Parameter [nElements] needs to be a scalar number.\n");
						
					}	
					
					#ifdef VERBOSE
					mexPrintf("freePortReceive: number of elements = %d\n", myElements);
					#endif /* VERBOSE */
					
					k = k + 1;
					break;
					
				case 4:
					
					/* data type */
					if(mxIsNumeric(prhs[k]) && !mxIsComplex(prhs[k])) {
						
						/* get data type ID */
						mydType = (unsigned char)mxGetScalar(prhs[k]);
						
						if((mydType < 0) || (mydType > numDATATYPES-1))
							mexErrMsgTxt("Invalid data type ID.\n");
					}
					else {
						
						mexErrMsgTxt("Parameter [dataType] needs to be a scalar number.\n");
						
					}
					
					/* calculate telegram size */
					buf_size = 	BuiltInDTypeSize[mydType] * myElements;
					
					#ifdef VERBOSE
					mexPrintf("freePortReceive: data type = %d\n", mydType);
					#endif /* VERBOSE */
					
					k = k + 1;
					break;
					
				case 5:
					
					/* blockingFlag */
					if(mxIsNumeric(prhs[k]) && !mxIsComplex(prhs[k])) {
						
						/* get data type ID */
						myBlockingFlag = (unsigned int)mxGetScalar(prhs[k]);
						
						if((myBlockingFlag != 0) && (myBlockingFlag != 1))
							mexErrMsgTxt("Invalid value of 'blockingFlag'.\n");
					}
					else {
						
						mexErrMsgTxt("Parameter [blockingFlag] needs to be a scalar number.\n");
						
					}
					
					#ifdef VERBOSE
					mexPrintf("freePortReceive: blockingFlag = %d\n", myBlockingFlag);
					#endif /* VERBOSE */
					
					k = k + 1;
					break;
					
			} /* switch */
			
		} /* while [input paramters] */

		
		#ifdef VERBOSE
		mexPrintf("freePortReceive: Checked all inputs\n");
		#endif /* VERBOSE */

		/* prepare output array (1 column, 'nElements' rows) */
		switch(mydType) {
				
			case tSINGLE:
				pArray = mxCreateNumericArray(2, (int const *)&dims[0], mxSINGLE_CLASS, mxREAL);
				//mexPrintf("pArray created\n");
				break;
				
			case tINT8:
				pArray = mxCreateNumericArray(2, (int const *)&dims[0], mxINT8_CLASS, mxREAL);
				//mexPrintf("pArray created\n");
				break;
				
			case tUINT8:
				pArray = mxCreateNumericArray(2, (int const *)&dims[0], mxUINT8_CLASS, mxREAL);
				//mexPrintf("pArray created\n");
				break;
				
			case tINT16:
				pArray = mxCreateNumericArray(2, (int const *)&dims[0], mxINT16_CLASS, mxREAL);
				//mexPrintf("pArray created\n");
				break;
				
			case tUINT16:
				pArray = mxCreateNumericArray(2, (int const *)&dims[0], mxUINT16_CLASS, mxREAL);
				//mexPrintf("pArray created\n");
				break;
				
			case tINT32:
				pArray = mxCreateNumericArray(2, (int const *)&dims[0], mxINT32_CLASS, mxREAL);
				//mexPrintf("pArray created\n");
				break;
				
			case tUINT32:
				pArray = mxCreateNumericArray(2, (int const *)&dims[0], mxUINT32_CLASS, mxREAL);
				//mexPrintf("pArray created\n");
				break;
				
			case tBOOLEAN:
				pArray = mxCreateNumericArray(2, (int const *)&dims[0], mxUINT32_CLASS, mxREAL);
				//mexPrintf("pArray created\n");
				break;
				
		} /* switch(mydType) */
	
        /* get pointer to output buffer */
        outBuf = (unsigned char *)mxGetPr(pArray);
            
		/* create output 'nElementsReceived' */
		pArray2 = mxCreateDoubleMatrix(1, 1, mxREAL);

        /* get pointer to output buffer */
        outnEls = (double *)mxGetPr(pArray2);

		/* initialize number of elements received */
		*outnEls = 0.0;

		#ifdef VERBOSE
		mexPrintf("freePortReceive: Created output variables.\n");
		#endif /* VERBOSE */

	} /* else: syntax correct */


	/* manage channels (workspace variable 'FreePortAdminVar') */
	
	/* create 'FreePortAdminVar' in the base workspace -- if required (first use) */
	if((FreePortAdminVar = mexGetVariable("base", "FreePortAdminVar")) == NULL) {

		int  i;

		/* FreePortAdminVar doesn't exist -> create & initialise it */
		FreePortAdminVar = mxCreateNumericMatrix(MAX_NUM_COM_PORTS, 1, mxUINT32_CLASS, mxREAL);

		/* initialise the array to be stored in variable FreePortAdminVar */
		myPtr = (myCOMPort **)mxGetPr(FreePortAdminVar);

		/* initialise all COM port access pointers with NULL */
		for(i=0; i<MAX_NUM_COM_PORTS; i++) myPtr[i] = NULL;

		#ifdef VERBOSE
		mexPrintf("FreePortAdminVar created\n");
		#endif /* VERBOSE */

	}
	else {

		/* 'FreePortAdminVar' already exists -> get pointer to data in FreePortAdminVar */
		myPtr = (myCOMPort **)mxGetPr(FreePortAdminVar);

		#ifdef VERBOSE
		mexPrintf("FreePortAdminVar found in workspace.\n");
		#endif /* VERBOSE */
	}

	/* open port */
	/* only open port if it's not already open */
	if(myPtr[myPort] == NULL) {

		/* allocate memory for admin structure of this instance's COM port access */
		if((adminP = (myCOMPort *)calloc(1, sizeof(myCOMPort))) == NULL) {
			mexErrMsgTxt("freePortReceive: Problem during memory allocation [insufficient memory, adminP].\n");
		}
				
		/* initialize port access structure */
		adminP->access_count = 1;
		adminP->hCom = FreePortOpenConnection(myPort, myBaud);
							
		/* store port access pointer in workspace variable */
		myPtr[myPort] = adminP;

		#ifdef VERBOSE
		mexPrintf("freePortReceive: buffer size = %d\n", buf_size);
		#endif /* VERBOSE */

	}

	/* export variable FreePortAdminVar to the base workspace */
	mexPutVariable("base", "FreePortAdminVar", FreePortAdminVar);

				
	#ifdef VERBOSE
	mexPrintf("freePortReceive: All initialized -> checking COM buffer for data.\n");
	#endif /* VERBOSE */

	/* -------------------------------------------------------------------------------------------------- */
	/* at this stage, the parameters have been checked and memory has been allocated -> wait for data ... */
    /* -------------------------------------------------------------------------------------------------- */

	/* myBlockingFlag */
	do {
	
		/* check COM port for newly arrived data */
		if(checkCOMforData(adminP->hCom) > 0) {


			#ifdef VERBOSE
			mexPrintf("freePortReceive: Found data in COM buffer.\n");
			#endif /* VERBOSE */

			/* receive data...  */
			if(myRawFlag == 0) {
			
				/* formatted telegrams -> receive header */
				uint8_T   myBuf[4];
			
				#ifdef VERBOSE
				mexPrintf("RXD: %d byte(s) in buffer (waiting for at least 4 bytes)\n", checkCOMforData(adminP->hCom));
				#endif

				/* make sure there are at least 4 bytes before making the call to fetch the header */
				if(checkCOMforData(adminP->hCom) >= 4) {
				
					#ifdef VERBOSE
					mexPrintf("RXD: %d bytes in buffer\n", checkCOMforData(adminP->hCom));
					#endif

					/* receive first 4 data bytes from serial port buffer */
					if (!Receive (adminP->hCom, myBuf, 4, &ReceiveTimeoutFlag, with_to_messages)) {
						mexErrMsgTxt("freePortReceive: Error during reception of first 4 bytes.\n");
					}

					#ifdef VERBOSE
					mexPrintf("Header: %d:%d:%d:%d\n", myBuf[0], myBuf[1], myBuf[2], myBuf[3]);
					#endif /* VERBOSE */

					/* determine telegram size, etc. */
					channel = (int16_T)myBuf[1];

					#ifdef VERBOSE
					mexPrintf("Channel: %d\n", channel);
					#endif /* VERBOSE */

				}
				
			} else {

				/* unformatted data -> channel number '0' (set above) */
				channel = (int)myChannel;

			}
				
			
			/* all remaining parameters are independent of the telegram format */

			/* only proceed once the header has arrived (if necessary...) */
			if(channel != -1) {
			
				/* allocate memory for buffer (buf_size bytes) for the received channel and its admin structure, returns the access pointer */
				if((admin = AllocateUserBuffer(channel, buf_size, mydType)) == NULL) {
					mexErrMsgTxt("freePortReceive: Problem during memory allocation [insufficient memory, admin].\n");
				}
										
				/* store the access pointer in the global buffer contents variable */
				freecomTelBuf[channel] = admin;

				size    = admin->buf_size;
				buf     = admin->buf;

				/* make sure there are at least 'size' bytes before making the call to fetch the data 
				 * this can be blocking as we (need to) assume that the packet is sent in one piece...
				 * (otherwise there can theoretically be data corruption between packets from different channels)
				 *
				 * fw-08-07
				 */
				while(checkCOMforData(adminP->hCom) >= size) {
					/* block here */
				}

				/* receive remaining 'size' data bytes from serial port buffer */
				if (!Receive (adminP->hCom, buf, size, &ReceiveTimeoutFlag, with_to_messages)) {
					mexErrMsgTxt("freePortReceive: Error during reception of remaining bytes.\n");
				}

				#ifdef VERBOSE
				/* host DLL -> echo... */
				{

					uint_T	i;

					mexPrintf("RxD < Channel[%d] ", channel);
				
					/* new buffer... */
					for(i=0; i<size; i++)
						mexPrintf(":%d", (uint_T)buf[i]);

					mexPrintf(":\n");

				}
				#endif /* VERBOSE */

				/* indicate receipt of a telegram */
				admin->buffer_full = 1;

				/* break 'while' loop */
				myBlockingFlag = 0;

			} /* channel != -1 */

		} /* checkCOMforData() */

	} while(myBlockingFlag == 1);

	
	/* check if output of this instance needs updated... */
	admin = freecomTelBuf[myChannel];

	if(admin != NULL) {

		if(admin->buffer_full) {

			/* new data available -> descramble */
			{
				
				unsigned int	fi;
				unsigned char	*pbuf = receivebuf;

				for(fi=0; fi<myElements; fi++) {
					
					/* single  : ID = 0 */
					/* int8    : ID = 1 */
					/* uint8   : ID = 2 */
					/* int16   : ID = 3 */
					/* uint16  : ID = 4 */
					/* int32   : ID = 5 */
					/* uint32  : ID = 6 */
					/* boolean : ID = 7 */
					
					switch(mydType) {
						
					case tSINGLE:
						{
							float	*pData = (float *)buf;
							float	tData = (float)pData[fi];
							
							*((float *)pbuf) = *(float *)(ReverseOrder4((unsigned char *)&tData));
							pbuf += BuiltInDTypeSize[mydType];
						}
						break;
						
					case tINT8:
						
						*((int8_T *)pbuf) = (int8_T)(buf[fi]);
						pbuf += BuiltInDTypeSize[mydType];
						break;
						
					case tUINT8:
						
						*((uint8_T *)pbuf) = (uint8_T)(buf[fi]);
						pbuf += BuiltInDTypeSize[mydType];
						break;
						
					case tINT16:
						{
							int16_T	*pData = (int16_T *)buf;
							int16_T	tData = (int16_T)pData[fi];
							
							*((int16_T *)pbuf) = *(int16_T *)(ReverseOrder2((unsigned char *)&tData));
							pbuf += BuiltInDTypeSize[mydType];
						}
						break;
						
					case tUINT16:
						{
							uint16_T	*pData = (uint16_T *)buf;
							uint16_T	tData = (uint16_T)pData[fi];
							
							*((uint16_T *)pbuf) = *(uint16_T *)(ReverseOrder2((unsigned char *)&tData));
							pbuf += BuiltInDTypeSize[mydType];
						}
						break;
						
					case tINT32:
						{
							int32_T	*pData = (int32_T *)buf;
							int32_T	tData = (int32_T)pData[fi];
							
							*((int32_T *)pbuf) = *(int32_T *)(ReverseOrder4((unsigned char *)&tData));
							pbuf += BuiltInDTypeSize[mydType];
						}
						break;
						
					case tUINT32:
						{
							uint32_T	*pData = (uint32_T *)buf;
							uint32_T	tData = (uint32_T)pData[fi];
							
							*((uint32_T *)pbuf) = *(uint32_T *)(ReverseOrder4((unsigned char *)&tData));
							pbuf += BuiltInDTypeSize[mydType];
						}
						break;
						
					case tBOOLEAN:
						{
							boolean_T	*pData = (boolean_T *)buf;
							boolean_T	tData = (boolean_T)pData[fi];
							
							*((boolean_T *)pbuf) = *(boolean_T *)(ReverseOrder2((unsigned char *)&tData));
							pbuf += BuiltInDTypeSize[mydType];
						}
						//*((boolean *)pbuf) = (boolean)(pData[fi]);
						//pbuf += BuiltInDTypeSize[mydType];
						break;
						
					} /* switch(mydType) */
					
				} /* for */
				
			} /* descramble */

			
			/* new data might be for this instance -> copy appropriate data to the output array */
			#ifdef VERBOSE
			mexPrintf("freePortReceive: Copying %d bytes to output of channel %d\n", admin->buf_size, myChannel);
			#endif

			/* new data available for this instance -> update output */
			memcpy(outBuf, receivebuf, admin->buf_size);

			/* adjust number of elements received */
			*outnEls = (double)myElements;

			/* clear buffer full flag */
			admin->buffer_full = 0;

		} /* new data available for this instance */

	} /* admin != NULL */

	
	// TERMINATE, delete data buffers
	#ifdef VERBOSE
	mexPrintf("freePortReceive: Terminating - freeing buffers\n");
	#endif

	/* update workspace variable 'FreePortAdminVar' */
	if((FreePortAdminVar = mexGetVariable("base", "FreePortAdminVar")) == NULL) {

		// do nothing, just exit
		mexErrMsgTxt("freePortReceive: Error accessing workspace variable FreePortAdminVar (terminating).\n");
	
	}
	else {

		myUsrBuf  *admin = freecomTelBuf[myChannel];
	
		if(admin != NULL) {
			
			/* yep -> close channel and free memory */
			free(admin->buf);
			free(admin);

			/* reset the channel specific access pointer */
			freecomTelBuf[myChannel] = NULL;

		}
	
		/* get FreePortAdminVar */
		myPtr = (myCOMPort **)mxGetPr(FreePortAdminVar);

		/* decrement port access pointer */
		myPtr[myPort]->access_count -= 1;
	
		/* check access counter */
		if(myPtr[myPort]->access_count == 0) {

			/* close port */
			FreePortCloseConnection(myPtr[myPort]->hCom);

			/* delete port access structure */
			free(myPtr[myPort]);
			myPtr[myPort] = NULL;

		}

		/* export variable FreePortAdminVar to the base workspace */
		mexPutVariable("base", "FreePortAdminVar", FreePortAdminVar);

	} /* FreeBufferAdminVar exists */


	// return output array pointer (always)
	#ifdef VERBOSE
	mexPrintf("freePortReceive: Returning output array.\n");
	#endif
	plhs[0] = pArray;
	plhs[1] = pArray2;

} /* end mexFunction */
