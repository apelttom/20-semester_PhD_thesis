/******************************************************************************/
/*                                                                            */
/* Name: freePortComms_txd.c  - S-Function for the communication using the    */
/*                              second asynchronous serial interface SCI0/1   */
/*                                                                            */
/******************************************************************************/

// =============================================================================
// fw-04-05
//
// level 2 s-function
//
// =============================================================================

#define S_FUNCTION_NAME freePortComms_txd
#define S_FUNCTION_LEVEL 2


/* undefine VERBOSE to run this DLL in silent mode */
//#define VERBOSE


#include <simstruc.h>

#ifdef EXTERN_C
#undef EXTERN_C                 // required when using 'lcc' (fw-06-07)
#endif
#include <windows.h>            // BuildCommDCB, CloseHandle, CreateFile, EscapeCommFunction, GetCommState,
                                // GetLastError, ReadFile, SetCommState, SetCommTimeouts, WriteFile, FlushFileBuffers
                                // Sleep
#include <stdio.h>                // sprintf
#include <stdlib.h>                // malloc, calloc
#include <string.h>                // memcpy


#ifdef MATLAB_MEX_FILE
#define abort_LED(x) return
#endif

// declaration of global user communication admin variables (only relevant for the target module, defined in ext_srv.h)
#include "..\core\BSP\bsp_dtypes.h"
#include "..\core\MC\mc_freePortComms.h"

// DEFINE global user communication admin variables ( initialised in mc_main->Init_ComVars() )
myUsrBuf    *freecomTelBuf[MAX_FREECOM_CHANNELS];        /* pointer to the data buffer admin structures of all user telegrams */


/* send */
BOOL SendTimeoutFlag;


// flag : communication with/without echo?
#define with_echo  TRUE
#define no_echo    FALSE

// flag : display on-screen timeout messages?
#define with_to_messages  TRUE 
#define no_to_messages    FALSE


// -------------------------------------------------------------------------------
// Number of S-function Parameters and macros to access from the SimStruct
// -------------------------------------------------------------------------------

#define SAMPLE_TIME_ARG        ssGetSFcnParam(S,0)        /* Sample time in seconds */
#define CHANNEL_NO_ARG        ssGetSFcnParam(S,1)     /* communication channel number (up to MAX_FREECOM_CHANNELS) */
#define NUM_ELEMENTS_ARG    ssGetSFcnParam(S,2)        /* block output width ->  # of elements */
#define DATA_TYPE_ARG       ssGetSFcnParam(S,3)     /* data type to be expected at block input */
#define PORT_ARG            ssGetSFcnParam(S,4)     /* communication port ([COM]1 - [COM]4) */
#define BAUDRATE_ARG        ssGetSFcnParam(S,5)     /* baudrate (300 [bps] - 115200 [bps]) */
#define FORMAT_ARG          ssGetSFcnParam(S,6)     /* format (0: formatted, 1: unformatted */
#define NUMBER_OF_ARG       7                          /* Number of input arguments */


// -------------------------------------------------------------------------------
// Macros to access the S-function parameter values
// -------------------------------------------------------------------------------

#define SAMPLE_TIME     ((real_T)   mxGetPr (SAMPLE_TIME_ARG)[0])
#define CHANNEL_NO      ((uint_T)   mxGetPr (CHANNEL_NO_ARG)[0])
#define NUM_ELEMENTS    ((uint_T)   mxGetPr (NUM_ELEMENTS_ARG)[0])
#define DATA_TYPE       ((uint_T)   mxGetPr (DATA_TYPE_ARG)[0])
#define PORT            ((uint_T)   mxGetPr (PORT_ARG)[0])
#define BAUDRATE        ((uint32_T) mxGetPr (BAUDRATE_ARG)[0])
#define FORMAT          ((uint_T)   mxGetPr (FORMAT_ARG)[0])


// ----------------------------------------------------------------------------------------------------
// global variables
// ----------------------------------------------------------------------------------------------------

// input signals may have the following bytes per element
const int_T    BuiltInDTypeSize[8] =    {
                                        4,    /* real32_T  */
                                        1,    /* int8_T    */
                                        1,    /* uint8_T   */
                                        2,    /* int16_T   */
                                        2,    /* uint16_T  */
                                        4,    /* int32_T   */
                                        4,    /* uint32_T  */
                                        2     /* boolean_T */
                                    };


#define  tSINGLE      0
#define  tINT8      1
#define  tUINT8      2
#define  tINT16      3
#define  tUINT16      4
#define  tINT32      5
#define  tUINT32      6
#define  tBOOLEAN    7


// map BAUDRATE parameter (1 - 10) to true baudrates
const DWORD BaudRates[10] =    {
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


/* descramble buffer ... (fw-09-06) */
static unsigned char    sendbuf[MAX_FREECOM_BUF_SIZE + 10];


// ----------------------------------------------------------------------------------------------------
// local methods
// ----------------------------------------------------------------------------------------------------

/* allocate and initialise the communication variables associated with a particular channel (buffer, admin, ... ) */
static myUsrBuf *AllocateUserBuffer(uint_T channel, uint_T bufsize, uint8_T data_type_len) {

    uint8_T            *buf;
    static myUsrBuf    *admin = NULL;

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
        

#ifdef ERASE
/* Function: checkCOMforData ===================================================
 * check if there's data in the COM buffer (FW-09-02)
 */
static int checkCOMforData(HANDLE hCom) {

    COMSTAT        cs;
    DWORD        error;

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
        return -1;

    }

} /* end checkCOMforData */
#endif


/* Function: FreePortOpenConnection =================================================
 *
 *  Open the connection with the target using the free communication port.
 */
HANDLE FreePortOpenConnection(SimStruct *S) {

    HANDLE            hCom = INVALID_HANDLE_VALUE;
    static char     COMxString[5];                                // serial interface designator
    char            COMxStringParam[16];
    DCB                dcb;
    COMMTIMEOUTS    CommTimeouts;

    char            tmp[512];                                    // error messages

    // default communication parameters (dummy)
    #define    DefaultComParam ":9600,n,8,1"

    // default timeout value (ms) - send and receive
    #define    DefaultTimeout        10000


    #ifdef VERBOSE
    mexPrintf("freePortComms_rxd|FreePortOpenConnection: IN\n");
    #endif /* VERBOSE */


    // open serial interface 'COMxString' (PORT = 3 -> COM1, PORT = 4 -> COM2, etc.)
    sprintf(COMxString, "COM%1d", (uint8_T)(PORT - 2));
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
    dcb.BaudRate = BaudRates[BAUDRATE-1];            // transmission speed (bps)
    dcb.fRtsControl = RTS_CONTROL_DISABLE;            // RTS = 'low' (mis-used to generate a software 'reset'...
    dcb.fOutX = FALSE;                                // disable XON/XOFF protocol
    dcb.fInX = FALSE;                                // (both for TX and RX)

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
    mexPrintf("freePortComms_rxd|FreePortOpenConnection: OUT\n");
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
// '&data':            string to be sent is stored here 
// 'nToWrite':        number of characters to be sent
// 'EchoFlag = TRUE/FALSE':     Send() awaits 'echo' / 'no echo'
// 'SendTimeoutFlag':        TRUE (timeout occurred), FALSE (no timeout)
// 'TimeoutMessageFlag':    TRUE (onscreen timeout messages) / FALSE (no messages)
//
// RETURN VALUE:            TRUE (successful transmission) / FALSE ('transmission error' or 'timeout')

BOOL Send(HANDLE hCom, BYTE data[], DWORD nToWrite, BOOL EchoFlag,
          BOOL *SendTimeoutFlag, BOOL TimeoutMessageFlag)
{
int        i;
DWORD    nWritten, z_len_read;
BYTE     *myChar;
BYTE     r_myChar;

    
    /* only attempt to send stuff if we're working with a proper port (not for the dummy port  --  fw-09-06) */
    if (hCom == INVALID_HANDLE_VALUE) return FALSE;


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
                                ssPrintf ("Send: Transmission ('%3d') and reception ('%3d') differ.\n\n", *myChar, r_myChar);
                                return (FALSE);

                            }
                        }
                        else {

                            // z_len_read != 1  >> more/less than one character have been received
                            // -> timeout occurred during reception of the data echo (most likely)
                            if (TimeoutMessageFlag == with_to_messages)
                                ssPrintf ("Send: Timeout during reception of data echo.\n");
                    
                            *SendTimeoutFlag = TRUE;        // signal timeout
                            return (FALSE);
                        }
                    }
                    else {

                        // error during call to ReadFile()
                        ssPrintf ("Send: Unspecified error during reception of data echo.\n");
                        return (FALSE);
                    }
                }  
                else {

                    // z_len_write != 1 >> more/less than one character have been sent
                    // -> timeout occurred during the transmission of the character
                    if (TimeoutMessageFlag == with_to_messages)
                        ssPrintf ("Send: Timeout during data transmission (with echo).\n");

                    *SendTimeoutFlag = TRUE;
                    return (FALSE);
                }
            }
            else {

                // error during call to WriteFile()
                ssPrintf ("Send: Unspecified error during transmission (with echo).\n");
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
                    ssPrintf ("Send: Timeout occurred during data transmission (without echo).\n");

                *SendTimeoutFlag = TRUE;
                return (FALSE);
            }
        }
        else {

            // WriteFile() returned unsuccessfully
            ssPrintf ("Send: Unspecified error during data transmission (without echo).\n");
            return (FALSE);

        }
    }
}



/* Function: ReverseOrder4 =================================================
 *
 *  Reverse the order of bytes in a 4-tuple
 */
void *ReverseOrder4(unsigned char *buf) {

unsigned char    temp;

    #ifdef VERBOSE
    {
        mexPrintf("freePortComms_txd: ReverseOrder4 %d:%d:%d:%d >> ", buf[0], buf[1], buf[2], buf[3]);
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

unsigned char    temp;

    #ifdef VERBOSE
    {
        mexPrintf("freePortComms_txd: ReverseOrder2 %d:%d >> ", buf[0], buf[1]);
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
// S-Function methods
// ----------------------------------------------------------------------------------------------------

/* Function: mdlCheckParameters ===============================================
 *
 */
#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS)
static void mdlCheckParameters(SimStruct *S)
{
    // check parameter: SAMPLE_TIME
    if (mxGetNumberOfElements(SAMPLE_TIME_ARG) != 1)                    abort_LED(36);    // parameter must be a scalar
    if ((SAMPLE_TIME < 0) && (SAMPLE_TIME != INHERITED_SAMPLE_TIME))    abort_LED(36);    // invalid negative sample time

    // check parameter: CHANNEL_NO
    if (mxGetNumberOfElements(CHANNEL_NO_ARG) != 1)                        abort_LED(37);    // parameter must be a scalar
    if ((CHANNEL_NO < 0) || (CHANNEL_NO >= MAX_FREECOM_CHANNELS))       abort_LED(37);    // invalid channel number

    // check parameter: NUM_ELEMENTS
    if (mxGetNumberOfElements(NUM_ELEMENTS_ARG) != 1)                    abort_LED(38);    // parameter must be a scalar
    if ((NUM_ELEMENTS < 1) || 
        (BuiltInDTypeSize[DATA_TYPE-1] * NUM_ELEMENTS > MAX_FREECOM_BUF_SIZE))    abort_LED(38);    // inadmissible buffer size
}
#endif /* MDL_CHECK_PARAMETERS */



/* Function: mdlInitializeSizes ===============================================
 *
 */
static void mdlInitializeSizes (SimStruct *S) {

int_T    i;

    ssSetNumSFcnParams(S, NUMBER_OF_ARG);                                            // expected number of parameters
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))  abort_LED(35);            // incorrect number of parameters
    else {

        #ifdef MDL_CHECK_PARAMETERS
        mdlCheckParameters(S);                            // check all parameters
        #endif
    }


    /* setup sizes of both work vectors and state vectors */
    ssSetNumIWork (S, 1);                        // instance-local integer value: channel number
    //ssSetNumRWork (S, 0);                        // no instance-local real values
    ssSetNumPWork (S, 1);                        // instance-local pointer: access to this channel's port access structure
    //ssSetNumDWork (S, 0);                        // no instance-local user data types used
    //ssSetNumContStates (S, 0);                // width of the instance-local vector of continuous states
    //ssSetNumDiscStates (S, 0);                // width of the instance-local vector of discrete states
    

    /* define number of sample times used by this s-function */
    ssSetNumSampleTimes (S, 1);                    // only 'one' sampletime in this S-Function

    // None of this s-functions's parameters are tunable during simulation (sample time, channel, buffer size, data type)
    for (i=0; i<NUMBER_OF_ARG; i++) ssSetSFcnParamNotTunable(S, i);


    if(!ssSetNumInputPorts(S, 1))    abort_LED(39);            // block has a single input...
    if(!ssSetNumOutputPorts(S, 0))    abort_LED(39);            // ... and no output (-> sink)

    ssSetInputPortWidth(S, 0, NUM_ELEMENTS);                // input width: number of elements

    //mexPrintf("Data type: %d\n", DATA_TYPE);

    ssSetInputPortDataType(S, 0, DATA_TYPE);                // block initialization code (mbc_userteltxd.m) adjusts this to '1' ... (no '0' = 'double')
    ssSetInputPortDirectFeedThrough(S, 0, 1);                // direct feedthrough (only executs after update of inputs)
    ssSetInputPortRequiredContiguous(S, 0, 1);                // ports to be stored contiguously in memory

}



/* Function: mdlInitializeSampleTimes =========================================
 *
 */
static void mdlInitializeSampleTimes (SimStruct *S) {

   ssSetSampleTime(S, 0, SAMPLE_TIME);                // this S-Function only has 'one' sampletime -> index '0'
   ssSetOffsetTime(S, 0, 0.0);

}



/* Function: mdlStart =========================================================
 *
 */
#define MDL_START
static void mdlStart(SimStruct *S) {
    
    /* check if this instance relates to a COM port -> host model (PORT = 3 -> COM1, PORT = 4 -> COM2, etc.) */
    if(PORT > 2) {

        void        **PWork = ssGetPWork(S);
        uint8_T        data_type = BuiltInDTypeSize[DATA_TYPE-1];        // first possible 'DATA_TYPE' is '1' ('single') -> map this to '0' (beginning of array)
        uint_T        buf_size =     data_type * NUM_ELEMENTS;
        mxArray        *FreePortAdminVar;
        myCOMPort   **myPtr;
        myUsrBuf    *admin;
        myCOMPort   *adminP = NULL;
        uint_T      i;
        int_T        *IWork = ssGetIWork(S);
                

        #ifdef VERBOSE
        mexPrintf("freePortComms_txd|mdlStart: IN\n");
        #endif /* VERBOSE */

        #ifdef ERASE
        mexPrintf("Sampletime: %f\n", SAMPLE_TIME);
        mexPrintf("Channel nb: %d\n", CHANNEL_NO);
        mexPrintf("Nb of elements: %d\n", NUM_ELEMENTS);
        mexPrintf("Data type: %d\n", DATA_TYPE);
        mexPrintf("Port: %d\n", PORT);
        mexPrintf("Baudrate: %d\n", BAUDRATE);
        mexPrintf("Format: %d\n", FORMAT);
        #endif

        /* ensure we're using channel '0' for raw data transmissions */
        if(FORMAT == 1)  IWork[0] = 0;
        else             IWork[0] = CHANNEL_NO;
        
        /* create 'FreePortAdminVar' in the base workspace -- if required (first use) */
        if((FreePortAdminVar = mexGetVariable("base", "FreePortAdminVar")) == NULL) {

            /* FreePortAdminVar doesn't exist -> create & initialise it */
            FreePortAdminVar = mxCreateNumericMatrix(MAX_NUM_COM_PORTS, 1, mxUINT32_CLASS, mxREAL);

            /* initialise the array to be stored in variable FreePortAdminVar */
            myPtr = (myCOMPort **)mxGetPr(FreePortAdminVar);

            /* initialise all COM port access pointers with NULL */
            for(i=0; i<MAX_NUM_COM_PORTS; i++) myPtr[i] = NULL;

        }
        else {

            /* 'FreePortAdminVar' already exists -> get pointer to data in FreePortAdminVar */
            myPtr = (myCOMPort **)mxGetPr(FreePortAdminVar);

        }


        /* allocate memory for buffer (buf_size bytes) for channel 'IWork[0]' and its admin structure, returns the access pointer */
        if((admin = AllocateUserBuffer(IWork[0], buf_size, data_type)) == NULL) {
            mexErrMsgTxt("FreePortComms_txd: Problem during memory allocation [insufficient memory, admin].\n");
        }
                
        /* store the access pointer in the global buffer contents variable */
        freecomTelBuf[IWork[0]] = admin;     /* IWork[0] = instance local channel number */
                

        /* only open port if it's not already open */
        if(myPtr[PORT-3] == NULL) {

            /* allocate memory for admin structure of this instance's COM port access */
            if((adminP = (myCOMPort *)calloc(1, sizeof(myCOMPort))) == NULL) {
                mexErrMsgTxt("FreePortComms_txd: Problem during memory allocation [insufficient memory, adminP].\n");
            }
        
            /* initialize port access structure */
            adminP->access_count = 0;
            adminP->hCom = FreePortOpenConnection(S);

            /* store port access pointer in workspace variable */
            myPtr[PORT-3] = adminP;

        }

        /* initialize instance local pointer to the port access structure */
        PWork[0] = myPtr[PORT-3];

        /* increase port access pointer */
        myPtr[PORT-3]->access_count += 1;

        /* export variable FreePortAdminVar to the base workspace */
        mexPutVariable("base", "FreePortAdminVar", FreePortAdminVar);

        #ifdef VERBOSE
        mexPrintf("freePortComms_txd|mdlStart: OUT\n");
        #endif /* VERBOSE */

    }

}



/*
 * mdlOutputs - compute the outputs
 *
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */
static void mdlOutputs(SimStruct *S, int_T tid) {

    /* check if this instance relates to a COM port -> host model (PORT = 3 -> COM1, PORT = 4 -> COM2, etc.) */
    if(PORT > 2) {

        int_T    *IWork      = ssGetIWork(S);     /* channel number */
        myUsrBuf  *admin      = freecomTelBuf[IWork[0]];
        uint_T    size        = admin->buf_size;
        uint8_T   *buf          = admin->buf;
        uint8_T      *blockInput = (uint8_T *)ssGetInputPortSignal(S, 0);
        myCOMPort *adminP     = ssGetPWorkValue(S, 0);

        /* buffer empty -> check if new user data has arrived */
        if(memcmp(buf+4, blockInput, (uint16_T)size) != 0) {

            #ifdef ERASE
            {
                int i;
                mexPrintf("size = %d\n", size);
                for(i=0; i<size; i++) {
                    mexPrintf("buf[%d+4] = %d\n", i, buf[i+4]);
                    mexPrintf("blockInput[%d] = %d\n", i, blockInput[i]);
                }
            }
            #endif

            /* new data available -> copy to data buffer */
            memcpy(buf+4, blockInput, (uint16_T)size);

            /* copy data to transmission buffer */
            {
                
                unsigned int    fi;
                unsigned int    mydType = DATA_TYPE-1;
                unsigned char    *pbuf = sendbuf;

                for(fi=0; fi<NUM_ELEMENTS; fi++) {
                    
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
                            float    *pData = (float *)(buf+4);
                            float    tData = (float)pData[fi];
                            
                            *((float *)pbuf) = *(float *)(ReverseOrder4((unsigned char *)&tData));
                            pbuf += BuiltInDTypeSize[mydType];
                        }
                        break;
                        
                    case tINT8:
                        
                        *((int8_T *)pbuf) = (int8_T)(buf[4+fi]);
                        pbuf += BuiltInDTypeSize[mydType];
                        break;
                        
                    case tUINT8:

                        *((uint8_T *)pbuf) = (uint8_T)(buf[4+fi]);
                        pbuf += BuiltInDTypeSize[mydType];
                        break;
                        
                    case tINT16:
                        {
                            int16_T    *pData = (int16_T *)(buf+4);
                            int16_T    tData = (int16_T)pData[fi];
                            
                            *((int16_T *)pbuf) = *(int16_T *)(ReverseOrder2((unsigned char *)&tData));
                            pbuf += BuiltInDTypeSize[mydType];
                        }
                        break;
                        
                    case tUINT16:
                        {
                            uint16_T    *pData = (uint16_T *)(buf+4);
                            uint16_T    tData = (uint16_T)pData[fi];
                            
                            *((uint16_T *)pbuf) = *(uint16_T *)(ReverseOrder2((unsigned char *)&tData));
                            pbuf += BuiltInDTypeSize[mydType];
                        }
                        break;
                        
                    case tINT32:
                        {
                            int32_T    *pData = (int32_T *)(buf+4);
                            int32_T    tData = (int32_T)pData[fi];
                            
                            *((int32_T *)pbuf) = *(int32_T *)(ReverseOrder4((unsigned char *)&tData));
                            pbuf += BuiltInDTypeSize[mydType];
                        }
                        break;
                        
                    case tUINT32:
                        {
                            uint32_T    *pData = (uint32_T *)(buf+4);
                            uint32_T    tData = (uint32_T)pData[fi];
                            
                            *((uint32_T *)pbuf) = *(uint32_T *)(ReverseOrder4((unsigned char *)&tData));
                            pbuf += BuiltInDTypeSize[mydType];
                        }
                        break;
                        
                    case tBOOLEAN:
                        {
                            boolean_T    *pData = (boolean_T *)(buf+4);
                            boolean_T    tData = (boolean_T)pData[fi];
                            
                            *((boolean_T *)pbuf) = *(boolean_T *)(ReverseOrder2((unsigned char *)&tData));
                            pbuf += BuiltInDTypeSize[mydType];
                        }
                        //*((boolean *)pbuf) = (boolean)(pData[fi]);
                        //pbuf += BuiltInDTypeSize[mydType];
                        break;
                        
                    } /* switch(mydType) */
                    
                } /* for */
                
            } /* copy elements to transmission buffer */
            

            
            /* download data to the target */
            if(FORMAT == 0) {

                /* formatted telegram */
                #ifdef VERBOSE
                {

                    uint_T    i;
        
                    mexPrintf("TxD > Channel[%d] ", IWork[0]);

                    /* new buffer... */
                    for(i=0; i<size; i++)
                        mexPrintf(":%d", sendbuf[i]);
        
                    mexPrintf(":\n");
        
                }
                #endif /* VERBOSE */

                
                #ifdef VERBOSE
                mexPrintf("Sending header (%d:%d:%d:%d)... ", buf[0], buf[1], buf[2], buf[3]);
                #endif /* VERBOSE */
                Send(adminP->hCom, buf, (DWORD)4, no_echo, &SendTimeoutFlag, with_to_messages);

            }

            /* raw data */
            #ifdef VERBOSE
            mexPrintf("sending data (%d bytes).\n", size);
            #endif /* VERBOSE */
            Send(adminP->hCom, sendbuf, (DWORD)size, no_echo, &SendTimeoutFlag, with_to_messages);

        } /* if : new user data available */

    } /* COM port */

}


/*
 * mdlTerminate - called when the simulation is terminated.
 *
 * In this function, you should perform any actions that are necessary
 * at the termination of a simulation.  For example, if memory was allocated
 * in mdlInitializeConditions, this is the place to free it.
 */
static void mdlTerminate (SimStruct *S) {
    
    /* check if this instance relates to a COM port -> host model (PORT = 3 -> COM1, PORT = 4 -> COM2, etc.) */
    if(PORT > 2) {

        mxArray        *FreePortAdminVar;
        int_T      *IWork = ssGetIWork(S);     /* channel number */


        /* update workspace variable 'FreePortAdminVar' */
        if((FreePortAdminVar = mexGetVariable("base", "FreePortAdminVar")) == NULL) {

            // do nothing, just exit
            //mexErrMsgTxt("freePortComms_txd: Error accessing workspace variable FreePortAdminVar (mdlTerminate).\n");
        
        }
        else {

            myUsrBuf    *admin = freecomTelBuf[IWork[0]];     /* IWork[0] : channel number */
            myCOMPort    **myPtr;
        
            /* yep -> close channel and free memory */
            free(admin->buf);
            free(admin);

            /* reset the channel specific access pointer */
            freecomTelBuf[IWork[0]] = NULL;                 /* IWork[0] : channel number */

            /* get FreePortAdminVar */
            myPtr = (myCOMPort **)mxGetPr(FreePortAdminVar);

            /* decrement port access pointer */
            myPtr[PORT-3]->access_count -= 1;
        
            /* check access counter */
            if(myPtr[PORT-3]->access_count == 0) {

                /* close port */
                FreePortCloseConnection(myPtr[PORT-3]->hCom);

                /* delete port access structure */
                free(myPtr[PORT-3]);
                myPtr[PORT-3] = NULL;

            }

            /* export variable FreePortAdminVar to the base workspace */
            mexPutVariable("base", "FreePortAdminVar", FreePortAdminVar);

        } /* FreePortAdminVar exists */

    } /* COM port */

}


// the define 'MATLAB_MEX_FILE' has to be specified when recompiling this module to a DLL.
// this is only required if the format of the call-up parameters is modified... (FW-06-01)
#ifdef MATLAB_MEX_FILE
   #include "simulink.c"
#else
# error "Attempt to use freePortComms_txd.c as non-inlined S-function"
#endif

