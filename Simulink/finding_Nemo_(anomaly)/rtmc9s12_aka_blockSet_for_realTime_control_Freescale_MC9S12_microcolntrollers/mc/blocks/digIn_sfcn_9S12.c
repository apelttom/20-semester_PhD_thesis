/******************************************************************************/
/*                                                                            */
/* Name: digIn_sfcn_9S12 - S-Function which determines the state(s) of one or */
/*                         more pins on the chosen port of the MC9S12DP256B/C */
/*                                                                            */
/* fw-03-05                                                                   */
/******************************************************************************/

/*=====================================*
 * Required setup for C MEX S-Function *
 *=====================================*/

#define S_FUNCTION_NAME digIn_sfcn_9S12
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

#define NUMBER_OF_ARG        3                    // Number of s-function input arguments

#define SAMPLE_TIME     (real_T)((mxGetPr(ssGetSFcnParam(S,0)))[0])   // real_T
#define PORT            (uint_T)((mxGetPr(ssGetSFcnParam(S,1)))[0])   // real_T
#define PIN_ARRAY                          ssGetSFcnParam(S,2)         // real_T


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

uint_T        pins;

   ssSetNumSFcnParams(S, NUMBER_OF_ARG);                                        // expected number of parameters
   if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))  abort_LED(10);        // incorrect number of parameters

   // not tunable during simulation : sampletime (P0), port (P1), pin (P2)
   ssSetSFcnParamNotTunable(S, 0);
   ssSetSFcnParamNotTunable(S, 1);
   ssSetSFcnParamNotTunable(S, 2);

   
   if(!ssSetNumInputPorts(S, 0))    abort_LED(18);
   if(!ssSetNumOutputPorts(S, 1))    abort_LED(18);

   // set number of output pins serviced by this block
   pins = mxGetNumberOfElements( PIN_ARRAY );
   //mexPrintf("Setting input width to %d\n", pins);
   ssSetOutputPortWidth(S, 0, pins);

   ssSetOutputPortDataType(S, 0, SS_DOUBLE);        /* input always taken as double  --  fw-03-05 */

   ssSetNumSampleTimes (S, 1);                    // only 'one' sampletime in this S-Function

   ssSetNumContStates (S, 0);                    // number of continuous states
   ssSetNumDiscStates (S, 0);                    // number of discrete states
   ssSetNumIWork (S, 0);                        // number of integer work vector elements
   ssSetNumRWork (S, 0);                        // number of real work vector elements
   ssSetNumPWork (S, 0);                        // number of pointer work vector elements


   /* options */
   ssSetOptions(S,
       SS_OPTION_WORKS_WITH_CODE_REUSE |
       SS_OPTION_EXCEPTION_FREE_CODE);
}



/* Function: mdlInitializeSampleTimes =========================================
 *
 */
static void mdlInitializeSampleTimes (SimStruct *S) {

   ssSetSampleTime(S, 0, SAMPLE_TIME);            // this S-Function only has 'one' sampletime -> index '0'
   ssSetOffsetTime(S, 0, 0.0);

}

/* Function: mdlStart =========================================================
 *
 */
#define MDL_START
static void mdlStart(SimStruct *S) {

    /* debug only */
    #ifdef ERASE
    mexPrintf("Port = %d, pin = %d\n", PORT, PIN_ARRAY );
    #endif

}


/*
 * mdlOutputs - compute the outputs
 *
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */
static void mdlOutputs(SimStruct *S, int_T tid) {

    /* debug only */
    #ifdef ERASE

int_T     y0Width   = ssGetOutputPortWidth(S, 0);
real_T   *pY0       = (real_T *)ssGetOutputPortSignal(S,0);
const real_T  *pins = mxGetData(PIN_ARRAY);

int_T    i; 
uint8_T  value;

    // debug test pattern
    value = 0x55;
    
    // simulation signal level 'high'
    switch(PORT) {

        case 1:   mexPrintf("PORTA, value %d\n", value);              break;  // port A
        case 2:   mexPrintf("PORTB, value %d\n", value);              break;  // port B
        case 3:   mexPrintf("PTH, value %d\n", value);                break;  // port H
        case 4:   mexPrintf("PTJ, value %d\n", value);                break;  // port J
        case 5:   mexPrintf("PTM, value %d\n", value);                break;  // port M
        case 6:   mexPrintf("PTP, value %d\n", value);                break;  // port P
        case 7:   mexPrintf("PTS, value %d\n", value);                break;  // port S
        case 8:   mexPrintf("PTT, value %d\n", value);                break;  // port T

    }

    /* return state of selected pins */
    for(i = 0; i < y0Width; i++) {
        
        //debug
        mexPrintf("Mask : %x\n", (uint8_T)(0x01<<(uint_T)pins[i]));

        if((value & (uint8_T)(0x01<<(uint_T)pins[i])) > 0) {
            
            //debug
            mexPrintf("Pin %d : high\n", i);

            pY0[i] = 1.0;
        }
        else {
            
            //debug
            mexPrintf("Pin %d : low\n", i);

            pY0[i] = 0.0;
        }

    }

    #endif /* ERASE */

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
# error "Attempt to use digIn_sfcn_9S12.c as non-inlined S-function"
#endif

