/******************************************************************************/
/*                                                                            */
/* Name: fuzzy_ni1o.c  - S-Function implementing a simple fuzzy controller    */
/*                                                                            */
/******************************************************************************/

// =============================================================================
// fw-09-06
//
// level 2 s-function
//
// =============================================================================

#define S_FUNCTION_NAME fuzzy_ni1o
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

#define NUMBER_OF_ARG   2

#define SAMPLE_TIME     (real_T)((mxGetPr(ssGetSFcnParam(S,0)))[0])
#define NUM_INPUTS      (uint_T)((mxGetPr(ssGetSFcnParam(S,1)))[0])




// ----------------------------------------------------------------------------------------------------
// S-Function methods
// ----------------------------------------------------------------------------------------------------


/* Function: mdlInitializeSizes ===============================================
 *
 */
static void mdlInitializeSizes (SimStruct *S) {

unsigned int i;

	ssSetNumSFcnParams(S, NUMBER_OF_ARG);										// expected number of parameters
	if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))  abort_LED(10);		// incorrect number of parameters

	// not tunable during simulation
	ssSetSFcnParamNotTunable(S, 0);		/* sample time */
	ssSetSFcnParamNotTunable(S, 1);		/* number of block inputs */

			
	// configure input ports
	if(!ssSetNumInputPorts(S, NUM_INPUTS))	abort_LED(18);
	for(i=0; i< NUM_INPUTS; i++) {
		
		ssSetInputPortWidth(S, i, 1);					// input width: scalar
		ssSetInputPortDirectFeedThrough(S, i, 1);		// direct feedthrough (only executs after update of inputs)
		ssSetInputPortRequiredContiguous(S, i, 1);		// ports to be stored contiguously in memory
		ssSetInputPortDataType(S, i, SS_DOUBLE);

	}

	// configure output port
	if(!ssSetNumOutputPorts(S, 1))	abort_LED(18);
	ssSetOutputPortWidth(S, 0, 1);						// block output width : number of elements
	ssSetOutputPortDataType(S, 0, SS_DOUBLE);

	// block sample times etc.
	ssSetNumSampleTimes (S, 1);					// only 'one' sampletime in this S-Function

	ssSetNumContStates (S, 0);					// number of continuous states
	ssSetNumDiscStates (S, 0);					// number of discrete states

	ssSetNumIWork (S, 0);						// number of integer work vector elements
	ssSetNumRWork (S, 0);						// number of real work vector elements
	ssSetNumPWork (S, 0);						// number of pointer work vector elements
			
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
# error "Attempt to use fuzzy_ni1o.c as non-inlined S-function"
#endif

