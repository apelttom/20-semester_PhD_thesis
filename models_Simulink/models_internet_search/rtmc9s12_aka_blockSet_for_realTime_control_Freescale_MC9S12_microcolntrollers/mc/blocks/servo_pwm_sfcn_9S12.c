/******************************************************************************/
/*                                                                            */
/* Name: servo_pwm_sfcn_9S12 - S-Function producing Pulse-Width Modulated     */
/*                             (PWM) o/p for servo motors signals             */
/*                                                                            */
/* fw-04-05                                                                   */
/******************************************************************************/

/*=====================================*
 * Required setup for C MEX S-Function *
 *=====================================*/

#define S_FUNCTION_NAME servo_pwm_sfcn_9S12
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

#define NUMBER_OF_ARG		4					// Number of s-function input arguments

#define SAMPLE_TIME     (real_T)((mxGetPr(ssGetSFcnParam(S,0)))[0])   // real_T
#define PWM_PERIOD      (real_T)((mxGetPr(ssGetSFcnParam(S,1)))[0])   // real_T
#define PULSE_PIN       (uint_T)((mxGetPr(ssGetSFcnParam(S,2)))[0])   // real_T
#define VSAT            (real_T)((mxGetPr(ssGetSFcnParam(S,3)))[0])   // real_T


// passed to TLC via model object field 'RTWdata':
// struct( 'pulsepinStr', 'pulsepinMask' ); 


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

   // not tunable during simulation : sampletime (P0), pulse period (P1), pulse pin (P2)
   ssSetSFcnParamNotTunable(S, 0);
   ssSetSFcnParamNotTunable(S, 1);
   ssSetSFcnParamNotTunable(S, 2);

   
   if(!ssSetNumInputPorts(S, 1))	abort_LED(18);
   ssSetInputPortWidth(S, 0, 1);
   ssSetInputPortDirectFeedThrough(S, 0, 1);	// direct feedthrough (only executs after update of inputs)
   ssSetInputPortRequiredContiguous(S, 0, 1);	// ports to be stored contiguously in memory
   ssSetInputPortDataType(S, 0, SS_DOUBLE);		/* input always taken as double  --  fw-03-05 */

   if(!ssSetNumOutputPorts(S, 0)) abort_LED(18);		// set number of outputs (none [sink])

   ssSetNumSampleTimes (S, 1);					// only 'one' sampletime in this S-Function

   ssSetNumContStates (S, 0);					// number of continuous states
   ssSetNumDiscStates (S, 0);					// number of discrete states

   /* work vectors  --  this information is used during the generation of model.rtw to add the respective data structures */
   /*                   TLC then generates entries in DWork; these can be accessed directly using LibBlockRWork(), etc.   */
   /* fw-03-05 */
   ssSetNumIWork (S, 1);						// number of integer work vector elements : , current duty cycle
   ssSetNumRWork (S, 1);						// number of real work vector elements  :  previous input value
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

	/* THIS SECTION IS NEVER USED -- USING TLC TO GENERATE TARGET CODE,  fw-03-05 */

#else /* MATLAB_MEX_FILE */

	/* not used here */

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
# error "Attempt to use servo_pwm_sfcn_9S12.c as non-inlined S-function"
#endif
