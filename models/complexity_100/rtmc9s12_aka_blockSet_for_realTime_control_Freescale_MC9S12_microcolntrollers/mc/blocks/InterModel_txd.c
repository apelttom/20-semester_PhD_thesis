/******************************************************************************/
/*                                                                            */
/* Name: InterModel_txd.c  - S-Function for the communication between models  */
/*                                                                            */
/******************************************************************************/

// =============================================================================
// fw-04-05
//
// level 2 s-function
//
// =============================================================================

#define S_FUNCTION_NAME InterModel_txd
#define S_FUNCTION_LEVEL 2


/* undefine VERBOSE to run this DLL in silent mode */
//#define VERBOSE


#include <simstruc.h>
#ifdef EXTERN_C
#undef EXTERN_C                 // required when using 'lcc' (fw-06-07)
#endif
#include <windows.h>			// BuildCommDCB, CloseHandle, CreateFile, EscapeCommFunction, GetCommState,
								// GetLastError, ReadFile, SetCommState, SetCommTimeouts, WriteFile, FlushFileBuffers
								// Sleep
#include <stdio.h>				// sprintf
#include <stdlib.h>				// malloc, calloc
#include <string.h>				// memcpy


#ifdef MATLAB_MEX_FILE
#define abort_LED(x) return
#endif

// declaration of global user communication admin variables (only relevant for the target module, defined in ext_srv.h)
#include "mc_freePortComms.h"


// -------------------------------------------------------------------------------
// Number of S-function Parameters and macros to access from the SimStruct
// -------------------------------------------------------------------------------

#define SAMPLE_TIME_ARG		ssGetSFcnParam(S,0)		/* Sample time in seconds */
#define CHANNEL_NO_ARG		ssGetSFcnParam(S,1) 	/* communication channel number (up to MAX_FREECOM_CHANNELS) */
#define NUM_ELEMENTS_ARG	ssGetSFcnParam(S,2)		/* block output width ->  # of elements */
#define DATA_TYPE_ARG       ssGetSFcnParam(S,3) 	/* data type to be expected at block input */
#define NUMBER_OF_ARG       4              			/* Number of input arguments */


// -------------------------------------------------------------------------------
// Macros to access the S-function parameter values
// -------------------------------------------------------------------------------

#define SAMPLE_TIME     ((real_T)   mxGetPr (SAMPLE_TIME_ARG)[0])
#define CHANNEL_NO      ((uint_T)   mxGetPr (CHANNEL_NO_ARG)[0])
#define NUM_ELEMENTS    ((uint_T)   mxGetPr (NUM_ELEMENTS_ARG)[0])
#define DATA_TYPE       ((int_T)    mxGetPr (DATA_TYPE_ARG)[0])



// ----------------------------------------------------------------------------------------------------
// global variables
// ----------------------------------------------------------------------------------------------------

// input signals may have the following bytes per element
const int_T	BuiltInDTypeSize[8] =	{
										4,    /* real32_T  */
    									1,    /* int8_T    */
    									1,    /* uint8_T   */
    									2,    /* int16_T   */
    									2,    /* uint16_T  */
    									4,    /* int32_T   */
    									4,    /* uint32_T  */
    									2     /* boolean_T */
									};

// comms port handle
static HANDLE   hCom = INVALID_HANDLE_VALUE;;



// ----------------------------------------------------------------------------------------------------
// local methods
// ----------------------------------------------------------------------------------------------------

/* allocate and initialise the communication variables associated with a particular channel (buffer, admin, ... ) */
static myUsrBuf *AllocateUserBuffer(uint_T channel, uint_T bufsize, uint8_T data_type_len) {

	uint8_T			*buf;
	static myUsrBuf	*admin = NULL;

	/* allocate memory for admin structure of this instance's data buffer */
	if((admin = (myUsrBuf *)calloc(1, sizeof(myUsrBuf))) == NULL)  return NULL;
		
	/* allocate memory for the buffer itself (buf_size '+ 4'  ->  telegram size, channel number, '0 0' [reserved]) */
	/* the additional '+3' has been introduced to allow safe byte-swapping -- required on the 9S12...  fw-03-05 */
	/* (the order of every group of 4 bytes gets reversed -> uint8_T transmissions might just end up on '+1' -> '+3' makes it dword aligned) */
	if((buf = (uint8_T *)calloc(bufsize + 4 + 3, sizeof(uint8_T))) == NULL)  return NULL;

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
	if (mxGetNumberOfElements(SAMPLE_TIME_ARG) != 1)					abort_LED(36);	// parameter must be a scalar
	if ((SAMPLE_TIME < 0) && (SAMPLE_TIME != INHERITED_SAMPLE_TIME))	abort_LED(36);	// invalid negative sample time

	// check parameter: CHANNEL_NO
	if (mxGetNumberOfElements(CHANNEL_NO_ARG) != 1)						abort_LED(37);	// parameter must be a scalar
	if ((CHANNEL_NO < 0) || (CHANNEL_NO >= MAX_FREECOM_CHANNELS))       abort_LED(37);	// invalid channel number

	// check parameter: NUM_ELEMENTS
	if (mxGetNumberOfElements(NUM_ELEMENTS_ARG) != 1)					abort_LED(38);	// parameter must be a scalar
	if ((NUM_ELEMENTS < 1) || 
		(BuiltInDTypeSize[DATA_TYPE-1] * NUM_ELEMENTS > MAX_FREECOM_BUF_SIZE))	abort_LED(38);	// inadmissible buffer size
}
#endif /* MDL_CHECK_PARAMETERS */



/* Function: mdlInitializeSizes ===============================================
 *
 */
static void mdlInitializeSizes (SimStruct *S)
{
int_T	i;

	ssSetNumSFcnParams(S, NUMBER_OF_ARG);											// expected number of parameters
	if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))  abort_LED(35);			// incorrect number of parameters
	else {

		#ifdef MDL_CHECK_PARAMETERS
		mdlCheckParameters(S);							// check all parameters
		#endif
	}


	/* setup sizes of both work vectors and state vectors */
	//ssSetNumIWork (S, 0);						// no instance-local integer values
	//ssSetNumRWork (S, 0);						// no instance-local real values
	ssSetNumPWork (S, 1);						// instance-local pointer: access to this channel's buffer structure
	//ssSetNumDWork (S, 0);						// no instance-local user data types used
	//ssSetNumContStates (S, 0);				// width of the instance-local vector of continuous states
	//ssSetNumDiscStates (S, 0);				// width of the instance-local vector of discrete states
	

	/* define number of sample times used by this s-function */
	ssSetNumSampleTimes (S, 1);					// only 'one' sampletime in this S-Function

	// None of this s-functions's parameters are tunable during simulation (sample time, channel, buffer size, data type)
	for (i=0; i<NUMBER_OF_ARG; i++) ssSetSFcnParamNotTunable(S, i);


	if(!ssSetNumInputPorts(S, 1))	abort_LED(39);			// block has a single input...
	if(!ssSetNumOutputPorts(S, 0))	abort_LED(39);			// ... and no output (-> sink)

	ssSetInputPortWidth(S, 0, NUM_ELEMENTS);				// input width: number of elements

	//mexPrintf("Data type: %d\n", DATA_TYPE);

	ssSetInputPortDataType(S, 0, DATA_TYPE);				// block initialization code (mbc_userteltxd.m) adjusts this to '1' ... (no '0' = 'double')
	ssSetInputPortDirectFeedThrough(S, 0, 1);				// direct feedthrough (only executs after update of inputs)
	ssSetInputPortRequiredContiguous(S, 0, 1);				// ports to be stored contiguously in memory

}



/* Function: mdlInitializeSampleTimes =========================================
 *
 */
static void mdlInitializeSampleTimes (SimStruct *S)
{
   ssSetSampleTime(S, 0, SAMPLE_TIME);				// this S-Function only has 'one' sampletime -> index '0'
   ssSetOffsetTime(S, 0, 0.0);
}



/* Function: mdlStart =========================================================
 *
 */
#define MDL_START
static void mdlStart(SimStruct *S)
{
	
	void		**PWork = ssGetPWork(S);
	uint8_T		data_type = BuiltInDTypeSize[DATA_TYPE-1];		// first possible 'DATA_TYPE' is '1' ('sinle') -> map this to '0' (beginning of array)
	uint_T		buf_size = 	data_type * NUM_ELEMENTS;


	#ifdef MATLAB_MEX_FILE

	/* host S-Function (DLL) */

	{

		mxArray		*FreeBufferAdminVar;
		myUsrBuf	*admin, **myPtr;
		int_T		i;
		
		/* all admin variables associated with a buffer are communicated via the workspace variable 'FreeBufferAdminVar' */

		//mexPrintf("s0_usertel_txd: mdlStart.\n");
		
		/* check if variable 'FreeBufferAdminVar' exists in the base workspace */
		if((FreeBufferAdminVar = mexGetVariable("base", "FreeBufferAdminVar")) == NULL) {

			/* FreeBufferAdminVar doesn't exist -> create & initialise it */
			FreeBufferAdminVar = mxCreateNumericMatrix(MAX_FREECOM_CHANNELS, 1, mxUINT32_CLASS, mxREAL);

			/* initialise the array to be stored in variable FreeBufferAdminVar */
			myPtr = (myUsrBuf **)mxGetPr(FreeBufferAdminVar);

			/* initialise all pointers with NULL */
			for(i=0; i<MAX_FREECOM_CHANNELS; i++) myPtr[i] = NULL;

			/* allocate memory for buffer (buf_size bytes) and its admin structure, returns the access pointer */
			if((admin = AllocateUserBuffer(CHANNEL_NO, buf_size, data_type)) == NULL) {

				mexErrMsgTxt("FreePortComms_txd: Problem during memory allocation [insufficient memory].\n");

			}
			
			//mexPrintf("Channel %d access count: %d\n", CHANNEL_NO, admin->access_count);

			/* store the access pointer in the workspace variable */
			myPtr[CHANNEL_NO] = admin;

			/* retain a local copy for fast access */
			PWork[0] = admin;

			/* export variable FreeBufferAdminVar to the base workspace */
			mexPutVariable("base", "FreeBufferAdminVar", FreeBufferAdminVar);

		}
		else {

			/* FreeBufferAdminVar exist */
			myPtr = (myUsrBuf **)mxGetPr(FreeBufferAdminVar);

			/*  check if the buffer has already been initialised */
			if(myPtr[CHANNEL_NO] == NULL) {

				/* this channel has not been initialised yet -> do so now... */
				if((admin = AllocateUserBuffer(CHANNEL_NO, buf_size, data_type)) == NULL) {

					mexErrMsgTxt("FreePortComms_txd: Problem during memory allocation [insufficient memory].\n");

				}

				//mexPrintf("Channel %d access count: %d\n", CHANNEL_NO, admin->access_count);

				/* store the access pointer in the workspace variable */
				myPtr[CHANNEL_NO] = admin;

				/* retain a local copy for fast access */
				PWork[0] = admin;

				/* export variable FreeBufferAdminVar to the base workspace */
				mexPutVariable("base", "FreeBufferAdminVar", FreeBufferAdminVar);

			}
			else {

				/* channel already initialised (rxd side) -> fetch it from there... */
				admin = myPtr[CHANNEL_NO];
				
				/* ... and increase access count (to '2') */
				admin->access_count++;
			
				//mexPrintf("Channel %d access count: %d\n", CHANNEL_NO, admin->access_count);
			
				/* retain a local copy for fast access */
				PWork[0] = admin;

			}
			
		}

	} /* context */


	#else
	
		/* not used here -- see corresponding TLC file */

	#endif

}



/*
 * mdlOutputs - compute the outputs
 *
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{

	myUsrBuf	*admin = ssGetPWorkValue(S, 0);


	/* check 'buffer full' flag */
	if(admin->buffer_full == 0) {

		uint_T  channel		= (uint_T)admin->buf[1];
		uint_T	size		= admin->buf_size;
		uint8_T *buf		= (uint8_T *)&(admin->buf[4]);
		uint8_T	*blockInput	= (uint8_T *)ssGetInputPortSignal(S, 0);

		/* buffer empty -> check if new user data has arrived */
		if(memcmp(buf, blockInput, size) != 0) {

			/* new block input data available -> copy to the data buffer */
			memcpy(buf, blockInput, size);

			/* set 'buffer full' flag */
			admin->buffer_full = 1;
	

			#ifdef MATLAB_MEX_FILE
		
			/* host DLL -> echo... */
			
			#ifdef VERBOSE
			{

				uint_T	i;

				mexPrintf("TxD > Channel[%d] ", channel);

				/* new buffer... */
				for(i=0; i<size; i++)
					mexPrintf(":%d", (uint_T)buf[i]);

				mexPrintf(":\n");

			}
			#endif /* VERBOSE */

			#endif /* MATLAB_MEX_FILE */

		} /* if : new user data available */

	} /* if : buffer full flag reset */

}


/*
 * mdlTerminate - called when the simulation is terminated.
 *
 * In this function, you should perform any actions that are necessary
 * at the termination of a simulation.  For example, if memory was allocated
 * in mdlInitializeConditions, this is the place to free it.
 */
static void mdlTerminate (SimStruct *S)
{
	
	myUsrBuf	*admin = ssGetPWorkValue(S, 0);


	#ifdef MATLAB_MEX_FILE

	/* host S-Function (DLL) */
	{

		mxArray		*FreeBufferAdminVar;
		myUsrBuf	**myPtr;

		/* check if this is the last remaining access to this channel */
		if(admin->access_count == 1) {

			/* yep -> close channel and free memory */
			free(admin->buf);
			free(admin);

			/* update workspace variable 'FreeBufferAdminVar' */
			if((FreeBufferAdminVar = mexGetVariable("base", "FreeBufferAdminVar")) == NULL) {

				mexErrMsgTxt("s0_usrtel_txd: Error accessing workspace variable FreeBufferAdminVar (mdlTerminate).\n");

			}
			else {

				/* get base access pointer */
				myPtr = (myUsrBuf **)mxGetPr(FreeBufferAdminVar);

				/* reset the channel specific access pointer */
				myPtr[CHANNEL_NO] = NULL;

				/* export variable FreeBufferAdminVar to the base workspace */
				mexPutVariable("base", "FreeBufferAdminVar", FreeBufferAdminVar);

			}

		}
		else {
			
			/* decrease access counter, channel will be closed from the other side */
			admin->access_count--;

			//mexPrintf("Channel %d access count: %d\n", CHANNEL_NO, admin->access_count);

		}

	}


	#else

		/* not used here -- see corresponding TLC file */

	#endif

}


// the define 'MATLAB_MEX_FILE' has to be specified when recompiling this module to a DLL.
// this is only required if the format of the call-up parameters is modified... (FW-06-01)
#ifdef MATLAB_MEX_FILE
   #include "simulink.c"
#else
# error "Attempt to use InterModel_txd.c as non-inlined S-function"
#endif

