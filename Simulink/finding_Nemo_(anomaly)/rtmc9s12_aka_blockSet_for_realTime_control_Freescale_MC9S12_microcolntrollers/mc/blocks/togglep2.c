/******************************************************************************/
/*                                                                            */
/* Name: TOGGLEP2.C - S-Function which toggles a given pin of the MC 80C166   */
/*                    parallel port 2 (= changes the output value of it from  */
/*                    "high" to "low" and reverse) at every sampling step     */
/*                                                                            */
/* Note: All parts of this S-Function which have to be adapted when using     */
/*       another microcontroller are placed in the "#else" section of the     */
/*       "#ifdef __C166__" statements. Exchange the "#error" statements       */
/*       and the comments written there against code.                         */
/*                                                                            */
/* Author: Sven Rebeschiess                                                   */
/* Date: 17.10.1999                                                           */
/*                                                                            */
/******************************************************************************/

// =============================================================================
// adapted for the GNU compiler (HighTec) : (FW-06-01)
// register set: C167CR
// now a level 2 s-function
//
// note: recompilation as a MATLAB_MEX_FILE is only required if the number or
//       function of any of the call-up parameters has been changed. The resulting
//       DLL is not functional (it's an empty function...)
//
// =============================================================================

#define S_FUNCTION_NAME togglep2
#define S_FUNCTION_LEVEL 2


#include "simstruc.h"			// Simulink data types (SimStruct, etc.)

#ifdef MATLAB_MEX_FILE
#define abort_LED(x) return
#endif




// -------------------------------------------------------------------------------
// Number of S-function Parameters and macros to access from the SimStruct
// -------------------------------------------------------------------------------

#define SAMPLE_TIME_ARG		ssGetSFcnParam(S,0)	// Sample time in seconds
#define PIN_ARG				ssGetSFcnParam(S,1)	// Pin number

#define NUMBER_OF_ARG		2				// Number of s-function input arguments


// -------------------------------------------------------------------------------
// Macros to access the S-function parameter values
// -------------------------------------------------------------------------------

#define SAMPLE_TIME			((real_T)  mxGetPr (SAMPLE_TIME_ARG)[0])
#define PIN					((uint_T)  mxGetPr (PIN_ARG)[0])



// ----------------------------------------------------------------------------------------------------
// S-Function methods
// ----------------------------------------------------------------------------------------------------

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS)
static void mdlCheckParameters(SimStruct *S)
{
   // check common parameter (SAMPLE_TIME)
   if (mxGetNumberOfElements(SAMPLE_TIME_ARG) != 1)				abort_LED(61);	// parameter must be a scalar
   if ((SAMPLE_TIME < 0) && (SAMPLE_TIME != INHERITED_SAMPLE_TIME))	abort_LED(61);	// invalid negative sample time

   // check parameter: PIN
   if (mxGetNumberOfElements(PIN_ARG) != 1)					abort_LED(62);	// parameter must be a scalar
   if ((PIN < 0) || (PIN > 15))							abort_LED(62);	// invalid range
}
#endif /* MDL_CHECK_PARAMETERS */



/* Function: mdlInitializeSizes ===============================================
 *
 */
static void mdlInitializeSizes (SimStruct *S)
{
int		i;

   ssSetNumSFcnParams(S, NUMBER_OF_ARG);								// expected number of parameters
   if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))  abort_LED(60);		// incorrect number of parameters
   else
   {
	#ifdef MDL_CHECK_PARAMETERS
	mdlCheckParameters(S);										// check all parameters
	#endif
   }


   // None of this s-functions's parameters are tunable during simulation
   for (i=0; i < NUMBER_OF_ARG; i++) ssSetSFcnParamNotTunable(S, i);


   ssSetNumContStates (S, 0);						// number of continuous states
   ssSetNumDiscStates (S, 0);						// number of discrete states

   if(!ssSetNumInputPorts(S, 0))	abort_LED(63);
   if(!ssSetNumOutputPorts(S, 0))	abort_LED(63);

   ssSetNumSampleTimes (S, 1);					// only 'one' sampletime in this S-Function
   ssSetNumIWork (S, 0);						// number of integer work vector elements
   ssSetNumRWork (S, 0);						// number of real work vector elements
   ssSetNumPWork (S, 0);						// number of pointer work vector elements
}



/* Function: mdlInitializeSampleTimes =========================================
 *
 */
static void mdlInitializeSampleTimes (SimStruct *S)
{
   ssSetSampleTime(S, 0, SAMPLE_TIME);			// this S-Function only has 'one' sampletime -> index '0'
   ssSetOffsetTime(S, 0, 0.0);
}



/* Function: mdlStart =========================================================
 *
 */
#define MDL_START
static void mdlStart(SimStruct *S)
{
   #ifndef MATLAB_MEX_FILE

	// set selected pin as output
      DP2 |= (1<<PIN);

   #endif  /* MATLAB_MEX_FILE */
}


/*
 * mdlOutputs - compute the outputs
 *
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
   #ifndef MATLAB_MEX_FILE

      // toggle pin
      P2 ^= (1<<PIN);

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
# error "attempting to compile tobblep2.c for target..."
#endif
