/******************************************************************************/
/*                                                                            */
/* Name: rfComms_server.c  - S-Function for the communication using the       */
/*                           nRF24L01 radio module - server side              */
/*                                                                            */
/******************************************************************************/

// =============================================================================
// fw-09-06
//
// level 2 s-function
//
// =============================================================================

#define S_FUNCTION_NAME rfComms_server
#define S_FUNCTION_LEVEL 2


/* undefine VERBOSE to run this DLL in silent mode */
//#define VERBOSE


#include <simstruc.h>


#ifdef MATLAB_MEX_FILE
#define abort_LED(x) return
#endif



// -------------------------------------------------------------------------------
// Macros to access the S-function parameter values
// -------------------------------------------------------------------------------

#define NUMBER_OF_ARG   5

#define SAMPLE_TIME     (real_T)((mxGetPr(ssGetSFcnParam(S,0)))[0])
#define RXTXMODE	    (uint_T)((mxGetPr(ssGetSFcnParam(S,1)))[0])
#define CHANNEL_NO		(uint_T)((mxGetPr(ssGetSFcnParam(S,2)))[0])
#define NUM_ELEMENTS    (uint_T)((mxGetPr(ssGetSFcnParam(S,3)))[0])
#define DATA_TYPE       (uint_T)((mxGetPr(ssGetSFcnParam(S,4)))[0])

/* RXTX modes */
#define RX			1		/* receive */
#define TX			2		/* transmit */




// ----------------------------------------------------------------------------------------------------
// global variables
// ----------------------------------------------------------------------------------------------------

// input signals may have the following bytes per element
static const int_T	BuiltInDTypeSize[8] =	{
												4,    /* real32_T  */
												1,    /* int8_T    */
												1,    /* uint8_T   */
												2,    /* int16_T   */
												2,    /* uint16_T  */
												4,    /* int32_T   */
												4,    /* uint32_T  */
												2     /* boolean_T */
											};



// ----------------------------------------------------------------------------------------------------
// S-Function methods
// ----------------------------------------------------------------------------------------------------


/* Function: mdlInitializeSizes ===============================================
 *
 */
static void mdlInitializeSizes (SimStruct *S) {

	ssSetNumSFcnParams(S, NUMBER_OF_ARG);										// expected number of parameters
	if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))  abort_LED(10);		// incorrect number of parameters

	// not tunable during simulation
	ssSetSFcnParamNotTunable(S, 0);		/* sample time */
	ssSetSFcnParamNotTunable(S, 1);		/* mode RXTX */
	ssSetSFcnParamNotTunable(S, 2);		/* channel number */
	ssSetSFcnParamNotTunable(S, 3);		/* number of elements */
	ssSetSFcnParamNotTunable(S, 4);		/* data type */

	// define nb of i/p or o/p  --  depends on chosen mode
	switch(RXTXMODE) {
			
		case RX:
			
			// no input port
		   if(!ssSetNumInputPorts(S, 0))	abort_LED(18);
			
		   // configure output port
		   if(!ssSetNumOutputPorts(S, 1))	abort_LED(18);
		   ssSetOutputPortWidth(S, 0, NUM_ELEMENTS);			// block output width : number of elements
		   ssSetOutputPortDataType(S, 0, DATA_TYPE);			// data type: '1' = 'single', '2' = 'int8_T', ... (no '0' -> no 'double')
		   
		   break;
		   
		case TX:
			
			// no output port
		   if(!ssSetNumOutputPorts(S, 0))	abort_LED(18);
			
		   // configure input port
		   if(!ssSetNumInputPorts(S, 1))	abort_LED(18);
		   ssSetInputPortWidth(S, 0, NUM_ELEMENTS);				// input width: number of elements
		   ssSetInputPortDirectFeedThrough(S, 0, 1);			// direct feedthrough (only executs after update of inputs)
		   ssSetInputPortRequiredContiguous(S, 0, 1);			// ports to be stored contiguously in memory
		   ssSetInputPortDataType(S, 0, DATA_TYPE);				// block initialization code (mbc_userteltxd.m) adjusts this to '1' ... (no '0' = 'double')
		
	}

	// block sample times etc.
	ssSetNumSampleTimes (S, 1);					// only 'one' sampletime in this S-Function

	ssSetNumContStates (S, 0);					// number of continuous states
	ssSetNumDiscStates (S, 0);					// number of discrete states

	ssSetNumIWork (S, 0);						// number of integer work vector elements
	ssSetNumRWork (S, 0);						// number of real work vector elements
	ssSetNumPWork (S, 1);						// number of pointer work vector elements  (local buffer of data to be sent - might not be necessary)
			
	/* options */
	ssSetOptions(S,
       SS_OPTION_WORKS_WITH_CODE_REUSE |
       SS_OPTION_EXCEPTION_FREE_CODE);

}



/* Function: mdlInitializeSampleTimes =========================================
 *
 */
static void mdlInitializeSampleTimes (SimStruct *S) {

   ssSetSampleTime(S, 0, SAMPLE_TIME);				// this S-Function only has 'one' sampletime -> index '0'
   ssSetOffsetTime(S, 0, 0.0);

}



/* Function: mdlStart =========================================================
 *
 */
#define MDL_START
static void mdlStart(SimStruct *S) {
	
	/* empty -> target contents are specified in the corresponding 'tlc' file */

}



/*
 * mdlOutputs - compute the outputs
 *
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */
static void mdlOutputs(SimStruct *S, int_T tid) {

	/* empty -> target contents are specified in the corresponding 'tlc' file */

}


/*
 * mdlTerminate - called when the simulation is terminated.
 *
 * In this function, you should perform any actions that are necessary
 * at the termination of a simulation.  For example, if memory was allocated
 * in mdlInitializeConditions, this is the place to free it.
 */
static void mdlTerminate (SimStruct *S) {
	
	/* empty -> target contents are specified in the corresponding 'tlc' file */

}


// the define 'MATLAB_MEX_FILE' has to be specified when recompiling this module to a DLL.
// this is only required if the format of the call-up parameters is modified... (FW-06-01)
#ifdef MATLAB_MEX_FILE
   #include "simulink.c"
#else
# error "Attempt to use rfComms_server.c as non-inlined S-function"
#endif

