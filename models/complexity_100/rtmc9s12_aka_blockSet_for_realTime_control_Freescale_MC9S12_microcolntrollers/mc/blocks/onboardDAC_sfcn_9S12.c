/******************************************************************************/
/*                                                                            */
/* Name: onboardDAC_sfcn_9S12 - S-Function producing						  */
/*       analog outputs using the onboard DACs (0,1) of the RevE Dragon-12    */
/*                                                                            */
/* fw-03-05                                                                   */
/******************************************************************************/

/*=====================================*
 * Required setup for C MEX S-Function *
 *=====================================*/

#define S_FUNCTION_NAME  onboardDAC_sfcn_9S12
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

#define NUMBER_OF_ARG		3					// Number of s-function input arguments

#define SAMPLE_TIME     (real_T)((mxGetPr(ssGetSFcnParam(S,0)))[0])   // real_T
#define DAC_CHANNEL     (uint_T)((mxGetPr(ssGetSFcnParam(S,1)))[0])   // real_T
#define V_SAT           (real_T)((mxGetPr(ssGetSFcnParam(S,1)))[0])   // real_T




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
   if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))  abort_LED(10);		// incorrect number of parameters

   // not tunable during simulation : sampletime (P0), DAC channel (P1)
   ssSetSFcnParamNotTunable(S, 0);
   ssSetSFcnParamNotTunable(S, 1);

   
   if(!ssSetNumInputPorts(S, 1))	abort_LED(18);
   ssSetInputPortWidth(S, 0, 1);
   ssSetInputPortDirectFeedThrough(S, 0, 1);		// direct feedthrough (only executs after update of inputs)
   ssSetInputPortRequiredContiguous(S, 0, 1);		// ports to be stored contiguously in memory
   ssSetInputPortDataType(S, 0, SS_DOUBLE);			/* input always taken as double  --  fw-03-05 */

   if(!ssSetNumOutputPorts(S, 0)) abort_LED(18);	// set number of outputs (none)

   ssSetNumSampleTimes (S, 1);					// only 'one' sampletime in this S-Function

   ssSetNumContStates (S, 0);					// number of continuous states
   ssSetNumDiscStates (S, 0);					// number of discrete states

   /* work vectors  --  this information is used during the generation of model.rtw to add the respective data structures */
   /*                   TLC then generates entries in DWork; these can be accessed directly using LibBlockRWork(), etc.   */
   /* fw-03-05 */
   ssSetNumIWork (S, 0);						// number of integer work vector elements : 
   ssSetNumRWork (S, 1);						// number of real work vector elements  :  previous output value
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

real_T	*pU0 = (real_T *)ssGetInputPortSignal(S,0);

	/* Set output equal to input */
	mexPrintf("On-board DAC%d = %f\n", DAC_CHANNEL, pU0[0]);

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
# error "Attempt to use onboardDAC_sfcn_9S12.c as non-inlined S-function"
#endif
