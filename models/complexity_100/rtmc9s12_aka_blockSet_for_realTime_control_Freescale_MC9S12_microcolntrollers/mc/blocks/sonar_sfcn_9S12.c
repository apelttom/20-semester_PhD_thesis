/*=====================================*
 * Required setup for C MEX S-Function *
 *=====================================*/

#define S_FUNCTION_NAME  sonar_sfcn_9S12
#define S_FUNCTION_LEVEL 2


 /*========================*
 * General Defines/macros *
 *========================*/

#ifdef MATLAB_MEX_FILE
#define abort_LED(x) return
#endif


 /*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h" 

#define TRUE    1
#define FALSE   0



// -------------------------------------------------------------------------------
// Macros to access the S-function parameter values
// -------------------------------------------------------------------------------

#define NUMBER_OF_ARG		5					// Number of s-function input arguments

#define SAMPLE_TIME         (real_T)((mxGetPr(ssGetSFcnParam(S,0)))[0])   // real_T
#define OUT_PORT			(uint_T)((mxGetPr(ssGetSFcnParam(S,1)))[0])   // real_T
#define OUT_PIN		        (uint_T)((mxGetPr(ssGetSFcnParam(S,2)))[0])   // real_T
#define IN_PORT 			(uint_T)((mxGetPr(ssGetSFcnParam(S,3)))[0])   // real_T
#define IN_PIN		        (uint_T)((mxGetPr(ssGetSFcnParam(S,4)))[0])   // real_T

// ----------------------------------------------------------------------------------------------------
// S-Function methods
// ----------------------------------------------------------------------------------------------------

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Initialize the sizes array
 */
/* Function: mdlInitializeSizes ===============================================
 *
 */
static void mdlInitializeSizes (SimStruct *S) {

   ssSetNumSFcnParams(S, NUMBER_OF_ARG);										// expected number of parameters
   if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))  abort_LED(10);

   // not tunable during simulation : sampletime (P0)
   ssSetSFcnParamNotTunable(S, 0);
   ssSetSFcnParamNotTunable(S, 1);
   ssSetSFcnParamNotTunable(S, 2);
   ssSetSFcnParamNotTunable(S, 3);
   ssSetSFcnParamNotTunable(S, 4);

   /* this is a source block... -> no inputs */
    if ( !ssSetNumInputPorts(S, 0) ) return;
    
   /* Single output port of width equal to nChannels */
    if ( !ssSetNumOutputPorts(S, 1) ) return;
    
   ssSetOutputPortWidth(S, 0, 1);
   
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

   ssSetSampleTime(S, 0, SAMPLE_TIME);			// this S-Function only has 'one' sampletime -> index '0'
   ssSetOffsetTime(S, 0, 0.0);

}

/* Function: mdlStart =========================================================
 *
 */
#define MDL_START
static void mdlStart(SimStruct *S) {

	// debug
	//mexPrintf("Port = %d, pin = %d\n", PORT, PIN);

   #ifndef MATLAB_MEX_FILE

	/* THIS SECTION IS NEVER USED -- USING TLC TO GENERATE TARGET CODE,  fw-03-05 */

   #endif  /* MATLAB_MEX_FILE */

}

/*
 * mdlOutputs - compute the outputs
 *
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */
static void mdlOutputs(SimStruct *S, int_T tid) {


#ifndef MATLAB_MEX_FILE


#else /* MATLAB_MEX_FILE */

#endif  /* MATLAB_MEX_FILE */
	
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
   /* not used here */
}



// the define 'MATLAB_MEX_FILE' has to be specified when recompiling this module to a DLL.
// this is only required if the format of the call-up parameters is modified... (FW-06-01)
#ifdef MATLAB_MEX_FILE
   #include "simulink.c"
#else
# error "Attempt to use sonar_sfcn_9S12.c as non-inlined S-function"
#endif
