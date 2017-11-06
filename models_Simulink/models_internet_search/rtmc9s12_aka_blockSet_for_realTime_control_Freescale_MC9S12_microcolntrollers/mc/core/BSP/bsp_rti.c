/*
 *********************************************************************************************************
 *
 * RTI support functions, Freescale MC9S12
 *
 * (c) Frank Wörnle, 2010
 * 
 *********************************************************************************************************
 *
 * File              : bsp_rti.c
 * Version           : 1.00
 * Last modification : 22.05.2010, Frank Wörnle, adapted for rtmc9s12-target
 *
 *********************************************************************************************************
 */



/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */

#include "bsp_includes.h"                        /* all controler specific includes        */
#include "bsp_rti.h"                             /* global macro definitions (interrupts)  */
#include "bsp_err.h"                             /* error memory support                   */

#include "mc_defines.h"                          /* CORE_RTI, CORE_T7ISR                   */



/*
 *********************************************************************************************************
 *    DEFINES
 *********************************************************************************************************
 */



/*
 *********************************************************************************************************
 *    CONSTANTS
 *********************************************************************************************************
 */



/*
 *********************************************************************************************************
 *    VARIABLES
 *********************************************************************************************************
 */


/* 
 * RTI timer control variables.
 *
 * Note: rtiTimerTicks has to be declared 'volatile' to prevent the compiler from 'optimizing' away
 * variable 'rtiTimerTicksReload' - in the eyes of the compiler, the latter is only initialized in 
 * RTI_Init and then never used again. The same holds for 'rtiIsrOverrun'.
 *
 */
static volatile tINT32U      rtiTimerTicks;      /* can be modified from outside the context (ISR) */
static          tINT32U      rtiTimerTicksReload;

#if ( (BSP_RTI_ISR == 1) && (BSP_RTI_OVERRUN_CHECK == 1) )
static volatile tINT16U      rtiIsrOverrun;      /* can be modified from outside the context (ISR) */
#endif


/* 
 * SCIxcommsTimeout counter values are set in 'SCIx_Init' based on 
 * the timout value 'APP_SCI0_TIMEOUT_SEC' defined in 'app_cfg.h'
 *
 * NOTE: The timeout system only active when timer is running! 
 */
#if ( (BSP_SCI0_TIMEOUT_SUPP == 1) && (BSP_SCI0_TIMEOUT_UNIT == CORE_RTI) )
static tINT32U               SCI0commsTimeout;
static tINT32U               SCI0commsTimeoutReload;
static tBOOLEAN              SCI0commsTimeoutFlag          = FALSE;
#endif

#if ( (BSP_SCI1_TIMEOUT_SUPP == 1) && (BSP_SCI1_TIMEOUT_UNIT == CORE_RTI) )
static tINT32U               SCI1commsTimeout;
static tINT32U               SCI1commsTimeoutReload;
static tBOOLEAN              SCI1commsTimeoutFlag          = FALSE;
#endif


/*
 * function pointer for the 'payload function' of the ISR (function defined externally)
 * this pointer should probably be in a NON_BANKED / NEAR segment... (todo, fw-06-09)
 */
#if  BSP_RTI_ISR == 1
static volatile tUsrFncISR  *app_rti_UsrFnc;
#endif



/*
 *********************************************************************************************************
 *    PRIVATE FUNCTIONS
 *********************************************************************************************************
 */

/*
 *********************************************************************************************************
 * Function      : rtiHandleTimeoutSCI0 (inlined)
 *
 * Description   : Inlined function to handle the mechanics of SCI0 timeouts
 * Arguments     : none
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

/* only inline SCI0 timeout support if configured */
#if ( (BSP_SCI0_TIMEOUT_SUPP == 1) && (BSP_SCI0_TIMEOUT_UNIT == CORE_RTI) )

#define  CPL_PRAGMA_INLINE_START
#include "cpl_pragma.h"

tVOID rtiHandleTimeoutSCI0(tVOID) {
  
    /* check if SCI0 communication timeout interval has elapsed */
    if (SCI0commsTimeoutFlag == FALSE) {
    
        /* timeout has not yet occurred */
      
        if (--SCI0commsTimeout == 0) {

            /* timeout -> reset 'SCI0commsTimeout' to reload value */
            SCI0commsTimeout = SCI0commsTimeoutReload;

            /* flag SCI0 timeout condition */
            SCI0commsTimeoutFlag = TRUE;

        }

    }

}

#define  CPL_PRAGMA_INLINE_STOP
#include "cpl_pragma.h"

#endif  /* BSP_SCI0_TIMEOUT_SUPP */


/*
 *********************************************************************************************************
 * Function      : rtiHandleTimeoutSCI1 (inlined)
 *
 * Description   : Inlined function to handle the mechanics of SCI1 timeouts
 * Arguments     : none
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

/* only inline SCI1 timeout support if configured */
#if ( (BSP_SCI1_TIMEOUT_SUPP == 1) && (BSP_SCI1_TIMEOUT_UNIT == CORE_RTI) )

#define  CPL_PRAGMA_INLINE_START
#include "cpl_pragma.h"

tVOID rtiHandleTimeoutSCI1(tVOID) {
  
    /* check if SCI1 communication timeout interval has elapsed */
    if (SCI1commsTimeoutFlag == FALSE) {
    
        /* timeout has not yet occurred */
      
        if (--SCI1commsTimeout == 0) {

            /* timeout -> reset 'SCI1commsTimeout' to reload value */
            SCI1commsTimeout = SCI1commsTimeoutReload;

            /* flag SCI1 timeout condition */
            SCI1commsTimeoutFlag = TRUE;

        }

    }

}

#define  CPL_PRAGMA_INLINE_STOP
#include "cpl_pragma.h"

#endif  /* BSP_SCI1_TIMEOUT_SUPP */




/*
 *********************************************************************************************************
 *    PUBLIC FUNCTIONS
 *********************************************************************************************************
 */

/*
 *********************************************************************************************************
 * Function      : timeoutSCI0
 *
 * Description   : Getter function for the SCI0 timout flag
 * Arguments     : none
 * Return values : current value of SCI0commsTimeoutFlag
 * Error memory  : none
 *********************************************************************************************************
 */

#if ( (BSP_SCI0_TIMEOUT_SUPP == 1) && (BSP_SCI0_TIMEOUT_UNIT == CORE_RTI) )
tBOOLEAN timeoutSCI0(tVOID) {

    return SCI0commsTimeoutFlag;

}
#endif


/*
 *********************************************************************************************************
 * Function      : timeoutSCI1
 *
 * Description   : Getter function for the SCI1 timout flag
 * Arguments     : none
 * Return values : current value of SCI1commsTimeoutFlag
 * Error memory  : none
 *********************************************************************************************************
 */

#if ( (BSP_SCI1_TIMEOUT_SUPP == 1) && (BSP_SCI1_TIMEOUT_UNIT == CORE_RTI) )
tBOOLEAN timeoutSCI1(tVOID) {

    return SCI1commsTimeoutFlag;

}
#endif


/*
 *********************************************************************************************************
 * Function      : resetTimeoutCounterSCI0
 *
 * Description   : Reset timeout mechanism for SCI0
 * Arguments     : none
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

#if ( (BSP_SCI0_TIMEOUT_SUPP == 1) && (BSP_SCI0_TIMEOUT_UNIT == CORE_RTI) )
tVOID resetTimeoutCounterSCI0(tVOID) {

    /* timeout counter reload value */
    SCI0commsTimeout     = SCI0commsTimeoutReload;
    SCI0commsTimeoutFlag = FALSE;

}
#endif


/*
 *********************************************************************************************************
 * Function      : resetTimeoutCounterSCI1
 *
 * Description   : Reset timeout mechanism for SCI1
 * Arguments     : none
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

#if ( (BSP_SCI1_TIMEOUT_SUPP == 1) && (BSP_SCI1_TIMEOUT_UNIT == CORE_RTI) )
tVOID resetTimeoutCounterSCI1(tVOID) {

    /* timeout counter reload value */
    SCI1commsTimeout     = SCI1commsTimeoutReload;
    SCI1commsTimeoutFlag = FALSE;

}
#endif


/*
 *********************************************************************************************************
 * Function      : SCI0_TimeoutInit
 *
 * Description   : Initialize SCI0 timeout counters
 * Arguments     : timeout period in seconds, RTI tick rate in Hz
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

#if ( (BSP_SCI0_TIMEOUT_SUPP == 1) && (BSP_SCI0_TIMEOUT_UNIT == CORE_RTI) )
tVOID SCI0_TimeoutInit(tFP32 timeoutPeriod) {

    /* setup target sided timeout mechanism for SCI0 */
    SCI0commsTimeoutFlag = FALSE;

    if (timeoutPeriod >= BSP_SCI0_TIMEOUT_MAX_SEC) {

        /* 
         * the RTI interrupt interval is longer than BSP_SCI0_TIMEOUT_MAX_SEC seconds
         * -> limit to BSP_BSP_SCI0_TIMEOUT_MAX_SEC
         */
        SCI0commsTimeout = (tINT32U)(BSP_SCI0_TIMEOUT_MAX_SEC * (tFP32)BSP_RTI_TICK_RATE_HZ + 0.5);

    } else {

        /* 
         * the RTI interrupt interval is shorter than BSP_SCI0_TIMEOUT_MAX_SEC seconds
         * -> trigger a timeout after 'timeoutPeriod / RTI period' ticks
         */
        SCI0commsTimeout = (tINT32U)(timeoutPeriod * (tFP32)BSP_RTI_TICK_RATE_HZ + 0.5);
        
        /* ensure that SCI0commsTimeout >= 1 */
        SCI0commsTimeout = (SCI0commsTimeout > 1UL ? SCI0commsTimeout : 1UL);

    }

    /* timeout counter reload value */
    SCI0commsTimeoutReload = SCI0commsTimeout;

}
#endif  /* BSP_SCI0_TIMEOUT_SUPP */


/*
 *********************************************************************************************************
 * Function      : SCI1_TimeoutInit
 *
 * Description   : Initialize SCI1 timeout counters
 * Arguments     : timeout period in seconds, RTI tick rate in Hz
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

#if ( (BSP_SCI1_TIMEOUT_SUPP == 1) && (BSP_SCI1_TIMEOUT_UNIT == CORE_RTI) )
tVOID SCI1_TimeoutInit(tFP32 timeoutPeriod) {

    /* setup target sided timeout mechanism for SCI1 */
    SCI1commsTimeoutFlag = FALSE;

    if (timeoutPeriod >= BSP_SCI1_TIMEOUT_MAX_SEC) {

        /* 
         * the RTI interrupt interval is longer than BSP_SCI1_TIMEOUT_MAX_SEC seconds
         * -> limit to BSP_BSP_SCI1_TIMEOUT_MAX_SEC
         */
        SCI1commsTimeout = (tINT32U)(BSP_SCI1_TIMEOUT_MAX_SEC * (tFP32)BSP_RTI_TICK_RATE_HZ + 0.5);

    } else {

        /* 
         * the RTI interrupt interval is shorter than BSP_SCI1_TIMEOUT_MAX_SEC seconds
         * -> trigger a timeout after 'timeoutPeriod / RTI period' ticks
         */
        SCI1commsTimeout = (tINT32U)(timeoutPeriod * (tFP32)BSP_RTI_TICK_RATE_HZ + 0.5);
        
        /* ensure that SCI1commsTimeout >= 1 */
        SCI1commsTimeout = (SCI1commsTimeout > 1UL ? SCI1commsTimeout : 1UL);

    }

    /* timeout counter reload value */
    SCI1commsTimeoutReload = SCI1commsTimeout;

}
#endif  /* BSP_SCI1_TIMEOUT_SUPP */


/*
 *********************************************************************************************************
 * Function      : Interrupt handler for RTI (used here as timeout timer)
 *
 * Description   : Everytime this ISR is run, the global variable RTIcounter is increased by one. Upon
 *                 every overrun of RTIcounter, the global variable RTIphase is toggled
 * Arguments     : none (ISR)
 * Return values : none (ISR)
 * Error memory  : ErrMem_RTI_OVERRUN
 *********************************************************************************************************
 */

#if  BSP_RTI_ISR == 1

#define CPL_PRAGMA_ISR_START
#include "cpl_pragma.h"

CPL_INTERRUPT tVOID RTI_isr(tVOID) {

    /* acknowledge, clear RTIF flag */
    CRGFLG = 0x80;


    /* disable RTI interrupt to avoid preemption then re-enable all interrupts */
    #if BSP_RTI_ISR_REENTRANT == 1
    InterruptDisable_RTI;
    CPL_ENABLE_IRQS;
    #endif


    /* determine if the base rate is too fast */
    #if BSP_RTI_OVERRUN_CHECK == 1
    if (rtiIsrOverrun++) {

        /* overrun condition - base sample time too short */
        #if BSP_RTI_ERROR_SUPP == 1
        ErrMem_RTI_OVERRUN = TRUE;
        #endif

    }
    #endif


    /* check if sampletime interval has elapsed */
    if (--rtiTimerTicks == 0) {

        /* yes -> reset 'rtiTimerTicks' to reload value */
        rtiTimerTicks = rtiTimerTicksReload;


        /* check if SCI0 communication timeout interval has elapsed */
        #if ( (BSP_SCI0_TIMEOUT_SUPP == 1) && (BSP_SCI0_TIMEOUT_UNIT == CORE_RTI) )
        rtiHandleTimeoutSCI0();
        #endif
        
        /* check if SCI1 communication timeout interval has elapsed */
        #if ( (BSP_SCI1_TIMEOUT_SUPP == 1) && (BSP_SCI1_TIMEOUT_UNIT == CORE_RTI) )
        rtiHandleTimeoutSCI1();
        #endif


        /* -----------------------   payload section : start   ----------------------- */

        /* call 'RTI payload function' -- if set */
        if (app_rti_UsrFnc != NULL) {

            /* user function definition: 'app_rti.c' */
            app_rti_UsrFnc();

        }

        /* -----------------------   payload section : end     ----------------------- */

    }  /* rtiTimerTicks == 0 */


    /* ISR overflow control */
    #if BSP_RTI_OVERRUN_CHECK == 1
    rtiIsrOverrun--;
    #endif


    /* re-enable RTI interrupts */
    #if BSP_RTI_ISR_REENTRANT == 1
    InterruptEnable_RTI;
    #endif

}

#define CPL_PRAGMA_ISR_STOP
#include "cpl_pragma.h"

#endif  /* BSP_RTI_ISR */


/*
 *********************************************************************************************************
 * Function      : RTI_Start
 *
 * Description   : Activate RTI  --  Needs to follow a call to RTI_Init to start the RT unit
 * Arguments     : none
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

tVOID RTI_Start(tVOID) {

  /* clear RTI request flag (by writing a '1' to RTIF) */
  CRGFLG = 0x80;
  
  /* enable RTI (by writing a '1' to RTIE) */
  InterruptEnable_RTI;
  
}


/*
 *********************************************************************************************************
 * Function      : RTI_Stop
 *
 * Description   : Deactivate RTI
 * Arguments     : none
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

tVOID RTI_Stop(tVOID) {

  /* disable RTI (by clearing RTIE) */
  InterruptDisable_RTI;
  
}


/*
 *********************************************************************************************************
 * Function      : RTI_SetPldFnc
 *
 * Description   : Set RTI payload function  --  the code is immediately active (next hit of the ISR)
 * Arguments     : function pointer (payload function):  void myPldFnct(void)
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

tVOID RTI_SetPldFnc(tUsrFncISR  *pFctAddress) {

    /* 
     * Install function 'app_rti_UsrFnc' as the ISR user function. The function is run 
     * as soon as the RTI interrupt service routine is called.
     */
    app_rti_UsrFnc = pFctAddress;

}


/*
 *********************************************************************************************************
 * Function      : RTI_GetPldFnc
 *
 * Description   : Return RTI payload function pointer
 * Arguments     : none
 * Return values : function pointer (payload function): tUsrFncISR *
 * Error memory  : none
 *********************************************************************************************************
 */

tUsrFncISR *RTI_GetPldFnc(tVOID) {

    /* 
     * return module global (static!) function pointer 'app_rti_UsrFnc'
     */
    return (tUsrFncISR *)app_rti_UsrFnc;

}


/*
 *********************************************************************************************************
 * Function      : RTI_ClrPldFnc
 *
 * Description   : Remove RTI payload function  --  the RTI continues to run until RTI_Stop is called
 * Arguments     : none
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

tVOID RTI_ClrPldFnc(tVOID) {

    /* 
     * Remove the currently installed ISR user function 'app_rti_UsrFnc'.
     */
    app_rti_UsrFnc = NULL;

}


/*
 *********************************************************************************************************
 * Function      : RTI_SetSampleTime
 *
 * Description   : setup RTI sample time in seconds - realized by decimation of the RTI base rate ticks
 * Arguments     : sample time in seconds
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

tVOID RTI_SetSampleTime(tFP32 sampleTime) {

    /* determine number of RTI ticks required to achieve requested sample time */
    rtiTimerTicks = (tINT32U)(sampleTime * (tFP32)BSP_RTI_TICK_RATE_HZ + 0.5);
    rtiTimerTicksReload = rtiTimerTicks;
    
    /* requested sample time shorter than the RTI base period? */
    if (rtiTimerTicks == 0) {
        
        /* yes -> set fastest rate (this should probably thrown an error - fw-05-10) */
        rtiTimerTicks = 1;
        rtiTimerTicksReload = rtiTimerTicks;
        
    }

}


/*
 *********************************************************************************************************
 * Function      : RTI_Init
 *
 * Description   : Initialize RTI
 * Arguments     : timer period in seconds - realized by decimating the RTI base rate
 *                                           (the latter is configured in 'bsp_cfg.h')
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

tVOID RTI_Init(tFP32 sampleTime) {

tINT32S  lError;
tINT32U  lLastError;
tINT32U  lPreScalar = 14;
tINT32U  lDivisor;
tINT32U  pTickRateHz;
  

    /* determine number of RTI ticks required to achieve requested sample time */
    RTI_SetSampleTime(sampleTime);


    /* calculate the smallest prescalar that will ba able to achieve the configured tick rate */
    for( pTickRateHz = BSP_RTI_TICK_RATE_HZ; 
         (pTickRateHz < ((BSP_OSC_FREQ_MHZ * 1000000) / (1UL << (tINT8U)lPreScalar))) && (lPreScalar <= 20);
         lPreScalar++ ) {

        /* do nothing */

    }

    /* adjust prescale value */
    lPreScalar -= 4;

    /* determine the appropriate divisor */
    lDivisor   = 1;
    lLastError = 1000000;
    
    /* loop until the best suited divisor has been found */
    while (1) {

        /* calculate current rate error (Hz) */
        lError = pTickRateHz - (BSP_OSC_FREQ_MHZ * 1000000) / (lDivisor * (1UL << (tINT8U)lPreScalar));
        
        /* current rate can be too fast or too slow */
        if (lError < 0) {
        
            /* too fast */
            lError = -lError;
            
        }
        
        /* maximum divisor reached? */
        if (lDivisor >= 16) {
        
            /* yes -> exit while loop */
            break;
            
        }

        /* best approximation reached? */
        if (lError > lLastError) {

            /* yep -> adjust divisor to previous value and exit */
            lDivisor--;
            break;
            
        }
        
        /* store current rate error and try next bigger divisor */
        lLastError = lError;
        lDivisor++;

    }  /* while */
    
    /* adjust divisor */
    lDivisor--;

    /* set the RTI control register */
    RTICTL = (tINT8U)((lPreScalar - 9) << 4) + (tINT8U)lDivisor; 

}

