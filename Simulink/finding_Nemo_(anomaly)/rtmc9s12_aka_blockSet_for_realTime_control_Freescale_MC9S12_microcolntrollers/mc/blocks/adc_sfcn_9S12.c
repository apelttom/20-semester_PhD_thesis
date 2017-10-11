/*
 *   ADC_SFCN_9S12 C-MEX S-function for 9S12 Analog to Digital Converter
 *   (supports vectored signals)
 *                  
 *  modified from The MathWorks example
 *  fw-03-05
 */

/*=====================================*
 * Required setup for C MEX S-Function *
 *=====================================*/

#define S_FUNCTION_NAME  adc_sfcn_9S12
#define S_FUNCTION_LEVEL 2


/* set DEBUG_LVL to 0 to suppress debug messages */
#define DEBUG_LVL  0


/*========================*
 * General Defines/macros *
 *========================*/

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h" 

#define TRUE    1
#define FALSE   0

/* Total number of block parameters */
#define N_PAR   6 

/* 
 *  CHANNELARRAY_ARG  - Array of ADC channels (one or more values between 0 and 7) 
 *                      Signal width is also determined from this list
 *  SAMPLETIME(S)     - Sample time
 *  ATDBANK(S)        - Bank 0, or Bank 1. Each bank provides 8 channels.
 *  USE8BITS(S)       - If (USE8BITS_ARGC==1), use 8-bits of ADC resolution
 *                      otherwise, use 10-bits ADC resolution
 *  NORMALIZE(S)      - If (NORMALIZE_ARGC==1) the result is normalized to 0 ... 1 (real_T),
 *                      otherwise a raw unsigned 16-bit integer is returned 
 */

enum {ATDBANK_ARGC=0, FIRST_CHANNEL, NUMBERofCHANNELS, USE8BITS_ARGC, NORMALIZE_ARGC, SAMPLETIME_ARGC};

#define ATDBANK           (uint_T)(mxGetScalar(ssGetSFcnParam(S, ATDBANK_ARGC)))
#define FIRST_CHANNEL     (uint_T)(mxGetScalar(ssGetSFcnParam(S, FIRST_CHANNEL)))
#define NUMBERofCHANNELS  (uint_T)(mxGetScalar(ssGetSFcnParam(S, NUMBERofCHANNELS)))
#define USE8BITS          (uint_T)(mxGetScalar(ssGetSFcnParam(S, USE8BITS_ARGC)))
#define NORMALIZE         (uint_T)(mxGetScalar(ssGetSFcnParam(S, NORMALIZE_ARGC)))
#define SAMPLETIME                (mxGetScalar(ssGetSFcnParam(S, SAMPLETIME_ARGC)))


/* global to this file: maxScale  (scaling factor) */
static real_T		maxScale;


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S) {
    
    #if DEBUG_LVL >= 1
	mexPrintf("Bank = %d\n", ATDBANK);
	mexPrintf("FirstChannel = %d\n", FIRST_CHANNEL);
	mexPrintf("numChannels = %d\n", NUMBERofCHANNELS);
	mexPrintf("Use8bits = %d\n", USE8BITS);
	mexPrintf("Normalize = %d\n", NORMALIZE);
	mexPrintf("Sampletime = %f\n", SAMPLETIME);
    #endif

	/* Set and Check parameter count  */
    ssSetNumSFcnParams(S, N_PAR);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;

    /* this is a source block... -> no inputs */
    if ( !ssSetNumInputPorts(S, 0) ) return;

    /* Single output port of width equal to nChannels */
    if ( !ssSetNumOutputPorts(S, 1) ) return;

    ssSetOutputPortWidth(S, 0, NUMBERofCHANNELS);

    /* set scaling factor */
	switch(NORMALIZE) {

	case 1:   /* 'raw values' */

		maxScale = 0;
		break;

	case 2:   /* 'max. output:  1' */

		maxScale = 5.0;
		break;

	case 3:   /* 'max. output:  5' */

		maxScale = 1.0;
		break;

	}

	// debug
	//mexPrintf("maxScale = %f\n", maxScale);
	
	/* Set datatypes on the output port relative
     * to users choice of 8-, or, 10-bit resolution and normalization
     */
	if (maxScale > 0) {
		
		/* scaled output signals -> make'em double as well  --  fw-03-05 */
		ssSetOutputPortDataType(S, 0, SS_DOUBLE);

	} else {

		/* raw data (unscaled) */
		if (USE8BITS) {
			
	       /* 
		    * Output datatype is uint8
			* when using 8-bit ADC resolution 
		    */
			ssSetOutputPortDataType(S, 0, SS_UINT8);
		
		} else {

	       /* 
		    * Output datatype is uint16
			* when using 10-bit ADC resolution 
	        */
			ssSetOutputPortDataType(S, 0, SS_UINT16);

		}

    }
    
    /* sample times */
    ssSetNumSampleTimes(S, 1);
    
    /* options */
    ssSetOptions(S, SS_OPTION_WORKS_WITH_CODE_REUSE | SS_OPTION_EXCEPTION_FREE_CODE);  

} /* end mdlInitializeSizes */


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Initialize the sample times array.
 */
static void mdlInitializeSampleTimes(SimStruct *S) {
    
	ssSetSampleTime(S, 0, SAMPLETIME); 
    
} /* end mdlInitializeSampleTimes */


/* Function: mdlOutputs =======================================================
 * Abstract:
 *   Compute the outputs of the S-function.
 */
static void mdlOutputs(SimStruct *S, int_T tid) {
    
	/* 
     * Get "uPtrs" for input port 0 and 1.  
     * uPtrs is essentially a vector of pointers because the input signal may 
     * not be contiguous.  
     */
    
    DTypeId       y0DataType;   /* SS_UINT8 or SS_UINT16 or SS_SINGLE */
    int_T         y0Width    = ssGetOutputPortWidth(S, 0);
    
    /* 
     * Get data type Identifier for output port 0. 
     * This matches the data type ID for input port 0.
     */
     
    y0DataType = ssGetOutputPortDataType(S, 0);
    y0Width    = ssGetOutputPortWidth(S, 0);

    /* 
     * Set output signals equal to input signals
     * for either 16 bit, or 8 bit signals.
     */
     
    switch (y0DataType)
    {
        case SS_UINT8:
        {
            uint8_T           *pY0 = (uint8_T *)ssGetOutputPortSignal(S, 0);
            int     i;

            /* Set all outputs equal to 'maxScale' (test) */
            for( i = 0; i < y0Width; ++i){
                pY0[i] = (uint8_T)maxScale;
            }
            break;
        }
        case SS_UINT16:
        {
            uint16_T          *pY0 = (uint16_T *)ssGetOutputPortSignal(S, 0);
            int     i; 
        
            for( i = 0; i < y0Width; ++i){              
                /* Set all outputs equal to 'maxScale' (test) */
                pY0[i] = (uint16_T)maxScale;
            }                                        
            break;
        }
        case SS_DOUBLE:
        {
            real_T             *pY0 = (real_T *)ssGetOutputPortSignal(S, 0);
            int     i; 

            for( i = 0; i < y0Width; ++i){              

                /* Set all outputs equal 'maxScale' (test) */
                pY0[i] = maxScale;
            }                                        
            break;
        }

    } /* end switch (y0DataType) */

} /* end mdlOutputs */


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    Called when the simulation is terminated.
 */
static void mdlTerminate(SimStruct *S)
{
} /* end mdlTerminate */


/*===============================================*
 * Enforce use of inlined S-function             * 
 * (e.g. must have TLC file adc_sfcn_9S12.tlc)   *
 *===============================================*/

#ifdef    MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file?    */
# include "simulink.c"     /* MEX-file interface mechanism                  */
#else                      /* Prevent usage by RTW if TLC file is not found */
# error "Attempt to use adc_sfcn_9S12.c as non-inlined S-function"
#endif

/* [EOF] adc_sfcn_9S12.c */