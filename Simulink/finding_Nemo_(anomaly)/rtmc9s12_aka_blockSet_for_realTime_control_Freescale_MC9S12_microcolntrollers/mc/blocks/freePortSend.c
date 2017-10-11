/******************************************************************************/
/*                                                                            */
/* Name: freePortSend.c  - mex function for the communication to the          */
/*                         free asynchronous serial interface SCI0/1          */
/*                                                                            */
/******************************************************************************/

// =============================================================================
// fw-10-05
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


/* send */
BOOL SendTimeoutFlag;


// flag : communication with/without echo?
#define with_echo  TRUE
#define no_echo    FALSE

// flag : display on-screen timeout messages?
#define with_to_messages  TRUE 
#define no_to_messages    FALSE




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

	// reset error status (returns structure COMSTAT [winbase.h])
	if(!ClearCommError(hCom, (LPDWORD)&error, (LPCOMSTAT)&cs)) {
		// error during call to ClearCommError
		mexPrintf("checkCOM4data: Error during call to ClearCommError.\n");

		// flag error to the calling function
		return(-1);
	}
	else {
		
		// debug
		//mexPrintf("FreePort: checkCOMforData detected %d data bytes in COM buffer\n", (int)cs.cbInQue);
		
		// return number of bytes in the buffer
		return((int)cs.cbInQue);
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
	mexPrintf("freePortSend|FreePortOpenConnection: IN\n");
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

	#ifdef VERBOSE
	mexPrintf("freePortSend|FreePortOpenConnection: OUT\n");
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
// Send... sends a string via the serial interface 'hCom'
// =====================================================================================================

// CALL-UP PARAMETERS:
//
// '&data':			string to be sent is stored here 
// 'nToWrite':		number of characters to be sent
// 'EchoFlag = TRUE/FALSE': 	Send() awaits 'echo' / 'no echo'
// 'SendTimeoutFlag':		TRUE (timeout occurred), FALSE (no timeout)
// 'TimeoutMessageFlag':	TRUE (onscreen timeout messages) / FALSE (no messages)
//
// RETURN VALUE:			TRUE (successful transmission) / FALSE ('transmission error' or 'timeout')

BOOL Send(HANDLE hCom, BYTE data[], DWORD nToWrite, BOOL EchoFlag,
          BOOL *SendTimeoutFlag, BOOL TimeoutMessageFlag)
{
int		i;
DWORD	nWritten, z_len_read;
BYTE 	*myChar;
BYTE 	r_myChar;

	*SendTimeoutFlag = FALSE;
	if (EchoFlag == with_echo) {

		// send message 'character by character'
		// request every character to be sent back (echo)
		for (i = 0; i < (int)(nToWrite); i++) {

			myChar = &data[i];
			if (WriteFile(hCom, (LPSTR) myChar, 1, &nWritten, NULL)) {

				if (nWritten == 1) {

					// a character has successfully been sent; awaiting echo...
					if (ReadFile(hCom, (LPSTR) &r_myChar, 1, &z_len_read, NULL)) {

						// ReadFile returns successfully
						if (z_len_read == 1) {

							// one character has been received
							if (r_myChar != *myChar) {

								// invalid echo
								mexPrintf ("Send: Transmission ('%3d') and reception ('%3d') differ.\n\n", *myChar, r_myChar);
								return (FALSE);

							}
						}
						else {

							// z_len_read != 1  >> more/less than one character have been received
							// -> timeout occurred during reception of the data echo (most likely)
							if (TimeoutMessageFlag == with_to_messages)
								mexPrintf ("Send: Timeout during reception of data echo.\n");
					
							*SendTimeoutFlag = TRUE;		// signal timeout
							return (FALSE);
						}
					}
					else {

						// error during call to ReadFile()
						mexPrintf ("Send: Unspecified error during reception of data echo.\n");
						return (FALSE);
					}
				}  
				else {

					// z_len_write != 1 >> more/less than one character have been sent
					// -> timeout occurred during the transmission of the character
					if (TimeoutMessageFlag == with_to_messages)
						mexPrintf ("Send: Timeout during data transmission (with echo).\n");

					*SendTimeoutFlag = TRUE;
					return (FALSE);
				}
			}
			else {

				// error during call to WriteFile()
				mexPrintf ("Send: Unspecified error during transmission (with echo).\n");
				return (FALSE);

			}

		} /* for (i = 0; i < nToWrite; i++) */

		return (TRUE);

	} /* if (EchoFlag == with_echo) */
	else {

		// send the entire string 'in one go' -> no echo
		if(WriteFile(hCom, (LPSTR) data, nToWrite, &nWritten, NULL)) {

			if (nWritten == nToWrite) {

				// no errors during transmission :-)
				return (TRUE);
			}   
			else {

				// Timeout during data transmission
				if (TimeoutMessageFlag == with_to_messages)
					mexPrintf ("Send: Timeout occurred during data transmission (without echo).\n");

				*SendTimeoutFlag = TRUE;
				return (FALSE);
			}
		}
		else {

			// WriteFile() returned unsuccessfully
			mexPrintf ("Send: Unspecified error during data transmission (without echo).\n");
			return (FALSE);

		}
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
    

unsigned int	myPort = 1;
unsigned int	myBaud = 300;
unsigned int	myChannel = 0;
unsigned int	myElements = 0;
unsigned char	mydType = 0;
unsigned int	myRawFlag;
unsigned int	buf_size = 0;
unsigned char	*buf;

myUsrBuf	*admin;
myCOMPort   *adminP = NULL;


	/* check syntax */
    if ((nlhs != 0) || (nrhs != 6)) {
        
        mexErrMsgTxt("Usage:  freePortSend(COMx, baudrate, channel, nElememts, dataType, data)\n");
        
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
						mexPrintf("freePortSend: COMx = %d\n", myPort);
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
							mexPrintf("freePortSend: Checking baudrate: %d\n", BaudRates[i]);
							#endif /* VERBOSE */
							
							if(myBaud == BaudRates[i]) {
								
								#ifdef VERBOSE
								mexPrintf("freePortSend: Detected supported baudrate (%d)\n", myBaud);
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
					mexPrintf("freePortSend: Channel = %d\n", myChannel);
					mexPrintf("freePortSend: rawdata = %d\n", myRawFlag);
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
						
					}
					else {
						
						mexErrMsgTxt("Parameter [nElements] needs to be a scalar number.\n");
						
					}	
					
					#ifdef VERBOSE
					mexPrintf("freePortSend: number of elements = %d\n", myElements);
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
					mexPrintf("freePortSend: data type = %d\n", mydType);
					#endif /* VERBOSE */
					
					k = k + 1;
					break;
					
				case 5:
					
					/* data */
					if(!mxIsEmpty(prhs[k])) {
						
						if(!mxIsNumeric(prhs[k]) || mxIsComplex(prhs[k])) {
							
							mexErrMsgTxt("Parameter [data] needs to be a real-valued vector.\n");
							
						}
						else {
							
							/* get data  */
							if((unsigned int)mxGetNumberOfElements(prhs[k]) != myElements) {
								mexErrMsgTxt("Inconsistent number of data elements.\n");
							}
							
							/* allocate memory for buffer (buf_size bytes) for channel 'IWork[0]' and its admin structure, returns the access pointer */
							if((admin = AllocateUserBuffer(myChannel, buf_size, mydType)) == NULL) {
								mexErrMsgTxt("freePortSend: Problem during memory allocation [insufficient memory, admin].\n");
							}
							
							/* open port */
							/* allocate memory for admin structure of this instance's COM port access */
							if((adminP = (myCOMPort *)calloc(1, sizeof(myCOMPort))) == NULL) {
								mexErrMsgTxt("freePortSend: Problem during memory allocation [insufficient memory, adminP].\n");
							}
							
							/* initialize port access structure */
							adminP->access_count = 1;
							adminP->hCom = FreePortOpenConnection(myPort, myBaud);
							
							/* get local copy of buffer pointer */
							buf = admin->buf;
							
							/* copy data to transmission buffer */
							{
								
								unsigned int	fi;
								unsigned char	*pbuf = admin->buf + 4;
								double			*pData = (double *)mxGetPr(prhs[k]);
								
								for(fi=0; fi<myElements; fi++) {
									
									/* single  : ID = 0*/
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
											float	tData = (float)pData[fi];
											
											*((float *)pbuf) = *(float *)(ReverseOrder4((unsigned char *)&tData));
											pbuf += BuiltInDTypeSize[mydType];
										}
										break;
										
										case tINT8:
											
										*((int8_T *)pbuf) = (int8_T)(pData[fi]);
										pbuf += BuiltInDTypeSize[mydType];
										break;
										
										case tUINT8:
											
										*((uint8_T *)pbuf) = (uint8_T)(pData[fi]);
										pbuf += BuiltInDTypeSize[mydType];
										break;
										
										case tINT16:
										{
											int16_T	tData = (int16_T)pData[fi];
											
											*((int16_T *)pbuf) = *(int16_T *)(ReverseOrder2((unsigned char *)&tData));
											pbuf += BuiltInDTypeSize[mydType];
										}
										break;
										
										case tUINT16:
										{
											uint16_T	tData = (uint16_T)pData[fi];
											
											*((uint16_T *)pbuf) = *(uint16_T *)(ReverseOrder2((unsigned char *)&tData));
											pbuf += BuiltInDTypeSize[mydType];
										}
										break;
										
										case tINT32:
										{
											int32_T	tData = (int32_T)pData[fi];
											
											*((int32_T *)pbuf) = *(int32_T *)(ReverseOrder4((unsigned char *)&tData));
											pbuf += BuiltInDTypeSize[mydType];
										}
										break;
										
										case tUINT32:
										{
											uint32_T	tData = (uint32_T)pData[fi];
											
											*((uint32_T *)pbuf) = *(uint32_T *)(ReverseOrder4((unsigned char *)&tData));
											pbuf += BuiltInDTypeSize[mydType];
										}
										break;
										
										case tBOOLEAN:
										{
											boolean_T	tData = (boolean_T)pData[fi];
											
											*((boolean_T *)pbuf) = *(boolean_T *)(ReverseOrder2((unsigned char *)&tData));
											pbuf += BuiltInDTypeSize[mydType];
										}
										//*((boolean *)pbuf) = (boolean)(pData[fi]);
										//pbuf += BuiltInDTypeSize[mydType];
										break;
										
									} /* switch(mydType) */
									
								} /* for */
								
							} /* copy elements to transmission buffer */
							
						} /* numeric and ! complex */				
						
					} /* not empty */
						
					else {
						
						mexErrMsgTxt("Empty data vector.\n");
						
					}
					
					#ifdef VERBOSE
					mexPrintf("freePortSend: buffer size = %d\n", buf_size);
					#endif /* VERBOSE */
					
					k = k + 1;
					break;
					
			} /* switch */
			
		} /* while [paramters] */
		
	} /* else: syntax correct */
	
    /* -------------------------------------------------------------------------------------------- */
	/* at this stage, the transmission data structure has been populated and is ready to be sent... */
    /* -------------------------------------------------------------------------------------------- */

	/* download data to the target */
	if(myRawFlag == 0) {
		
		/* formatted telegram */
		Send(adminP->hCom, buf, (DWORD)buf[0], no_echo, &SendTimeoutFlag, with_to_messages);
		
		#ifdef VERBOSE
		{
	
			unsigned int	i;
	
			mexPrintf("TX on channel %d >> ", myChannel);
	
			/* new buffer... */
			for(i=0; i<buf_size+4; i++)
				mexPrintf(":%d", (unsigned int)buf[i]);
	
			mexPrintf(": <<\n");
	
		}
		#endif /* VERBOSE */
		
	} else {
		
		/* raw data */
		Send(adminP->hCom, (uint8_T *)&buf[4], (DWORD)buf_size, no_echo, &SendTimeoutFlag, with_to_messages);
		
		#ifdef VERBOSE
		{
	
			unsigned int	i;
	
			mexPrintf("TX on channel %d >> ", myChannel);
	
			/* new buffer... */
			for(i=4; i<buf_size+4; i++)
				mexPrintf(":%d", (unsigned int)buf[i]);
	
			mexPrintf(": <<\n");
	
		}
		#endif /* VERBOSE */
		
	}
	

	// TERMINATE, delete data buffers
	free(admin->buf);
	free(admin);
	
	/* decrement port access pointer */
	adminP->access_count -= 1;

	/* check access counter */
	if(adminP->access_count == 0) {
		
		/* close port */
		FreePortCloseConnection(adminP->hCom);
		
		/* delete port access structure */
		free(adminP);
		
	}

} /* end mexFunction */
