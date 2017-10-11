/*
 *********************************************************************************************************
 *
 * timer support functions, Freescale MC9S12
 *
 * (c) Frank Wörnle, 2010
 * 
 *********************************************************************************************************
 *
 * File              : bsp_timer.c
 * Version           : 1.00
 * Last modification : 29.07.2010, Frank Wörnle
 *
 *********************************************************************************************************
 */


/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */


#include "bsp_includes.h"                        /* all controler specific includes        */
#include "bsp_timer.h"                           /* core timer support macros              */
#include "bsp_err.h"                             /* error manager                          */

#include "mc_defines.h"                          /* CORE_RTI, CORE_T7ISR                   */
#include "mc_debugMsgs.h"                        /* PRINT_DEBUG_MSG_LVL1, etc.             */
#include "mc_main.h"                             /* model_run                              */
#include "mc_signal.h"                           /* abort_LED                              */
#include "mc_lcd.h"                              /* writeline                              */



/*
 *********************************************************************************************************
 *    MACROS
 *********************************************************************************************************
 */

#define  MIN_PERIOD        0.002730625           /* Timer 7 minimum period : 2.73 ms  (65536 * 42 ns = 2.73 ms) */
#define  MAX_PERIOD        MIN_PERIOD * 128      /* maximum period : 349.5 ms (MIN_PERIOD * 2^7 = 349.5 ms) */



/*
 *********************************************************************************************************
 *    EXTERN GLOBAL VARIABLES
 *********************************************************************************************************
 */

extern tINT16S volatile      startModel;         /* defined in ext_work.c                  */



/*
 *********************************************************************************************************
 *    VARIABLES
 *********************************************************************************************************
 */


/* 
 * TC7 timer control variables.
 *
 * Note: ectTimerTicks has to be declared 'volatile' to prevent the compiler from 'optimizing' away
 * variable 'ectTimerTicksReload' - in the eyes of the compiler, the latter is only initialized in 
 * TC7_Init and then never used again. The same holds for 'ectIsrOverrun'.
 *
 */
static volatile tINT32U      ectTimerTicks;      /* can be modified from outside the context (ISR) */
static          tINT32U      ectTimerTicksReload;

#if ( (BSP_ECT_ISR == 1) && (BSP_ECT_OVERRUN_CHECK == 1) )
static volatile tINT16U      ectIsrOverrun;      /* can be modified from outside the context (ISR) */
#endif


/* 
 * SCIxcommsTimeout counter values are set in 'SCIx_Init' based on 
 * the timout value 'APP_SCI0_TIMEOUT_SEC' defined in 'app_cfg.h'
 *
 * NOTE: The timeout system only active when timer is running! 
 */
#if ( (BSP_SCI0_TIMEOUT_SUPP == 1) && (BSP_SCI0_TIMEOUT_UNIT == CORE_T7ISR) )
static tINT32U               SCI0commsTimeout;
static tINT32U               SCI0commsTimeoutReload;
static tBOOLEAN              SCI0commsTimeoutFlag          = FALSE;
#endif

#if ( (BSP_SCI1_TIMEOUT_SUPP == 1) && (BSP_SCI1_TIMEOUT_UNIT == CORE_T7ISR) )
static tINT32U               SCI1commsTimeout;
static tINT32U               SCI1commsTimeoutReload;
static tBOOLEAN              SCI1commsTimeoutFlag          = FALSE;
#endif


/*
 * function pointer for the 'payload function' of the ISR (function defined externally)
 * this pointer should probably be in a NON_BANKED / NEAR segment... (todo, fw-06-09)
 */
#if  BSP_ECT_ISR == 1
static volatile tUsrFncISR  *app_ect_UsrFnc;
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
#if ( (BSP_SCI0_TIMEOUT_SUPP == 1) && (BSP_SCI0_TIMEOUT_UNIT == CORE_T7ISR) )

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
#if ( (BSP_SCI1_TIMEOUT_SUPP == 1) && (BSP_SCI1_TIMEOUT_UNIT == CORE_T7ISR) )

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

#if ( (BSP_SCI0_TIMEOUT_SUPP == 1) && (BSP_SCI0_TIMEOUT_UNIT == CORE_T7ISR) )
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

#if ( (BSP_SCI1_TIMEOUT_SUPP == 1) && (BSP_SCI1_TIMEOUT_UNIT == CORE_T7ISR) )
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

#if ( (BSP_SCI0_TIMEOUT_SUPP == 1) && (BSP_SCI0_TIMEOUT_UNIT == CORE_T7ISR) )
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

#if ( (BSP_SCI1_TIMEOUT_SUPP == 1) && (BSP_SCI1_TIMEOUT_UNIT == CORE_T7ISR) )
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

#if ( (BSP_SCI0_TIMEOUT_SUPP == 1) && (BSP_SCI0_TIMEOUT_UNIT == CORE_T7ISR) )
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

#if ( (BSP_SCI1_TIMEOUT_SUPP == 1) && (BSP_SCI1_TIMEOUT_UNIT == CORE_T7ISR) )
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
 * Function      : Interrupt handler for TC7 (used here as core timer)
 *
 * Description   : Everytime this ISR is run, the global variable TC7counter is increased by one. Upon
 *                 every overrun of TC7counter, the global variable TC7phase is toggled
 * Arguments     : none (ISR)
 * Return values : none (ISR)
 * Error memory  : ErrMem_TC7_OVERRUN
 *********************************************************************************************************
 */

#if  BSP_ECT_ISR == 1

#define CPL_PRAGMA_ISR_START
#include "cpl_pragma.h"

CPL_INTERRUPT tVOID ECT_isr(tVOID) {

    /* acknowledge, clear C7F flag */
    TFLG1 = 0x80;


    /* disable TC7 interrupt to avoid preemption then re-enable all interrupts */
    #if BSP_ECT_ISR_REENTRANT == 1
    InterruptDisable_TC7;
    CPL_ENABLE_IRQS;
    #endif


    /* determine if the base rate is too fast */
    #if BSP_ECT_OVERRUN_CHECK == 1
    if (ectIsrOverrun++) {

        /* overrun condition - base sample time too short */
        #if BSP_ECT_ERROR_SUPP == 1
        ErrMem_ECT_OVERRUN = TRUE;
        #endif

    }
    #endif


    /* check if sampletime interval has elapsed */
    if (--ectTimerTicks == 0) {

        /* yes -> reset 'ectTimerTicks' to reload value */
        ectTimerTicks = ectTimerTicksReload;


        /* check if SCI0 communication timeout interval has elapsed */
        #if ( (BSP_SCI0_TIMEOUT_SUPP == 1) && (BSP_SCI0_TIMEOUT_UNIT == CORE_T7ISR) )
        rtiHandleTimeoutSCI0();
        #endif
        
        /* check if SCI1 communication timeout interval has elapsed */
        #if ( (BSP_SCI1_TIMEOUT_SUPP == 1) && (BSP_SCI1_TIMEOUT_UNIT == CORE_T7ISR) )
        rtiHandleTimeoutSCI1();
        #endif


        /* -----------------------   payload section : start   ----------------------- */

        /* call 'TC7 payload function' -- if set */
        if (app_ect_UsrFnc != NULL) {

            /* user function definition: 'app_tc7.c' */
            app_ect_UsrFnc();

        }

        /* -----------------------   payload section : end     ----------------------- */

    }  /* ectTimerTicks == 0 */


    /* ISR overflow control */
    #if BSP_ECT_OVERRUN_CHECK == 1
    ectIsrOverrun--;
    #endif


    /* re-enable TC7 interrupts */
    #if BSP_ECT_ISR_REENTRANT == 1

    //#if EXT_MODE == 1
    //if (startModel) {
    //#endif
   
        InterruptEnable_TC7;

    //#if EXT_MODE == 1
    //}
    //#endif

    #endif  /* BSP_ECT_ISR_REENTRANT */

}  /* End of ECT_isr */

#define CPL_PRAGMA_ISR_STOP
#include "cpl_pragma.h"

#endif  /* BSP_ECT_ISR */


/*
 *********************************************************************************************************
 * Function      : TC7_Start
 *
 * Description   : Activate ECT  --  Needs to follow a call to TC7_Init to start the RT unit
 * Arguments     : none
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

tVOID TC7_Start(tVOID) {

    /* acknowledge, clear C7F flag */
    TFLG1 = 0x80;

    /* enable ECT interrupt */
    InterruptEnable_TC7;

}


/*
 *********************************************************************************************************
 * Function      : TC7_Stop
 *
 * Description   : Deactivate ECT
 * Arguments     : none
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

tVOID TC7_Stop(tVOID) {

    /* disable ECT interrupt */
    InterruptDisable_TC7;

}


/*
 *********************************************************************************************************
 * Function      : TC7_SetPldFnc
 *
 * Description   : Set ECT payload function  --  the code is immediately active (next hit of the ISR)
 * Arguments     : function pointer (payload function):  void myPldFnct(void)
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

tVOID TC7_SetPldFnc(tUsrFncISR  *pFctAddress) {

    /* 
     * Install function 'app_ect_UsrFnc' as the ISR user function. The function is run 
     * as soon as the ECT interrupt service routine is called.
     */
    app_ect_UsrFnc = pFctAddress;

}


/*
 *********************************************************************************************************
 * Function      : TC7_GetPldFnc
 *
 * Description   : Return ECT payload function pointer
 * Arguments     : none
 * Return values : function pointer (payload function): tUsrFncISR *
 * Error memory  : none
 *********************************************************************************************************
 */

tUsrFncISR *TC7_GetPldFnc(tVOID) {

    /* 
     * return module global (static!) function pointer 'app_ect_UsrFnc'
     */
    return (tUsrFncISR *)app_ect_UsrFnc;

}


/*
 *********************************************************************************************************
 * Function      : TC7_ClrPldFnc
 *
 * Description   : Remove ECT payload function  --  the ECT continues to run until TC7_Stop is called
 * Arguments     : none
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

tVOID TC7_ClrPldFnc(tVOID) {

    /* 
     * Remove the currently installed ISR user function 'app_ect_UsrFnc'.
     */
    app_ect_UsrFnc = NULL;

}


/*
 *********************************************************************************************************
 * Function      : TC7_SetSampleTime
 *
 * Description   : setup ECT sample time in seconds - realized by decimation of the ECT base rate ticks
 * Arguments     : sample time in seconds
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

tVOID TC7_SetSampleTime(tFP32 sampleTime) {

    /* determine number of ECT ticks required to achieve requested sample time */
    ectTimerTicks = (tINT32U)(sampleTime * (tFP32)BSP_ECT_TICK_RATE_HZ + 0.5);
    ectTimerTicksReload = ectTimerTicks;
    
    /* requested sample time shorter than the ECT base period? */
    if (ectTimerTicks == 0) {
        
        /* yes -> set fastest rate (this should probably thrown an error - fw-05-10) */
        ectTimerTicks = 1;
        ectTimerTicksReload = ectTimerTicks;
        
    }

}


/*
 *********************************************************************************************************
 * Function      : TC7_Init
 *
 * Description   : Initialize core timer TC7 (ECT)
 * Arguments     : timer period in seconds - realized by decimating the ECT base rate
 *                                           (the latter is configured in 'bsp_cfg.h')
 * Return values : none
 * Error memory  : none
 *********************************************************************************************************
 */

tVOID TC7_Init(tFP32 sampleTime) {

tINT16U     n       = 1;                /* base period multiplier: 1 = 2.73 ms, 2 = 5.46 ms, ... 128 = 349.5 ms */
tINT8U      PR0_2   = 0;                /* bits PR0, PR1, PR2 (see TSCR2) */


    // local function name... debugging only
    DEFINE_DEBUG_FNAME("TC7_Init")


    /* determine number of TC7 ticks required to achieve requested sample time */
    TC7_SetSampleTime(sampleTime);


    /* no ISR overrun detected yet */
    ectIsrOverrun = 0;

    /* 
     * setup core timer T7
     *
     * note these three lines have to precede the remaining initialisation to allow the code to run 
     * in release mode (otherwise only debug/monitor mode is possible... strangely! supposedly a timing 
     * timing issue.
     *
     * fw-03-05  (see /microcontroller/_work/_oddErrors/myOddTimer for further details)
     */
    TIOS  |=  0x80;      /* Configure channel 7 for output compare (OC) mode */
    TCTL1 &=  0x3F;      /* 00xx.xxxx -> OM7 = OM7 = 0 (disconnect pin 'IOC7' from o/p logic) */
    OC7M   =  0x00;      /* do not affect any of the linked output pins (IOC0 - IOC6) */


    /* check if variable 'ectTimerTicks' has to be used to extend range of timer */
    if (sampleTime >= MAX_PERIOD) {

        /* yes -> setup timer for a base resolution of 100 us */
        /* Bottom three bits of TSCR2 (PR2,PR1,PR0) determine TCNT period
                divider   resolution   maximum period  
            000      1          42ns         2.73ms
            001      2          84ns         5.46ms
            010      4         167ns         10.9ms
            011      8         333ns         21.8ms
            100     16         667ns         43.7ms
            101     32        1.33us         87.4ms
            110     64        2.67us        174.8ms
            111    128        5.33us        349.5ms    */ 
        TSCR2 = 0x08;    // Divide clock by 1, disable TOI (timer overflow interrupt)
        
        // TCRE = 1 (reset TCNT upon output compare match of channel 7)
        TC7 = 2400;       /* actual period : 2400 * 1/24e6 = 100 us */

        /* sample period in units of base resolution */
        ectTimerTicks = (uint32_T)(sampleTime * 10000);     //ectTimerTicks = (uint32_T)(sampleTime/1e - 4);
        ectTimerTicksReload = ectTimerTicks;

    } else {

        /* no -> program exact value */
        /* determine settings of the core timer T7 */
        while (sampleTime > ((tFP32)MIN_PERIOD) * n) {

            n <<= 1;            /* insufficiently long maximum period -> try next slower period */
            PR0_2++;            /* new value of PR0, PR1, PR2 */

        }

        /* 
         * Divide clock by 128, disable TOI (timer overflow interrupt).
         * TCRE = 1 (reset TCNT upon output compare match of channel 7)
         */
        TSCR2 = 0x08 | PR0_2;

        /* Calculate reload value for timer T7 */
        TC7 = (tINT16U)(65536 * sampleTime / ((tFP32)MIN_PERIOD * n));

        /* reset 'ectTimerTicks' -> every interrupt counts... */
        ectTimerTicks = 1;
        ectTimerTicksReload = ectTimerTicks;

    }

    TSCR1 = 0x80;      // enable timer 7 (set TEN bit)
    TFLG1 = 0x80;      // initially clear C7F (event flag for channel 7)
    
}




/* ===================================================================================== */





#if ((HAS_TIMERBLOCKS > 0) || (HAS_RFCOMMS > 0))
/* 
 * This section is only included if the block diagram has timer blocks or RFComms blocks.
 * In this case, the ECT unit is configured using 'ECT_Init' and each timer channel can 
 * be set up using 'TChannel_Conf' 
 *
 * fw-09-06 
 */

/* global variables: reload values */
#if T0_MODE == TMode_OC
static tINT16U   TC0_ReloadValue;
#endif

#if T1_MODE == TMode_OC
static tINT16U   TC1_ReloadValue;
#endif

#if T2_MODE == TMode_OC
static tINT16U   TC2_ReloadValue;
#endif

#if T3_MODE == TMode_OC
static tINT16U   TC3_ReloadValue;
#endif

#if T4_MODE == TMode_OC
static tINT16U   TC4_ReloadValue;
#endif

#if T5_MODE == TMode_OC
static tINT16U   TC5_ReloadValue;
#endif

#if T6_MODE == TMode_OC
static tINT16U   TC6_ReloadValue;
#endif

#if T7_MODE == TMode_OC
static tINT16U   TC7_ReloadValue;
#endif

#if T0_MODE == TMode_IC
static tINT16U   TC0_Capture_last;
static tINT16U   TC0_diff;
#endif

#if T1_MODE == TMode_IC
static tINT16U   TC1_Capture_last;
static tINT16U   TC1_diff;
#endif

#if T2_MODE == TMode_IC
static tINT16U   TC2_Capture_last;
static tINT16U   TC2_diff;
#endif

#if T3_MODE == TMode_IC
static tINT16U   TC3_Capture_last;
static tINT16U   TC3_diff;
#endif

#if T4_MODE == TMode_IC
static tINT16U   TC4_Capture_last;
static tINT16U   TC4_diff;
#endif

#if T5_MODE == TMode_IC
static tINT16U   TC5_Capture_last;
static tINT16U   TC5_diff;
#endif

#if T6_MODE == TMode_IC
static tINT16U   TC6_Capture_last;
static tINT16U   TC6_diff;
#endif

#if T7_MODE == TMode_IC
static tINT16U   TC7_Capture_last;
static tINT16U   TC7_diff;
#endif


static tINT16U   TCx_latch;
static tINT32U   myTOFcounter;
static tFP32     myECTperiod        = MIN_ECT_PERIOD;  // initialize with smalles possible base period (2.73 ms)


/* timer unit initialization (base rate) */
tVOID ECT_Init(tVOID) {

    /* set ECT period (used in TChannel_Conf) */
    myECTperiod = (tFP32)(MIN_ECT_PERIOD * TIMER_PRESCALER);

    TSCR2 = 0x80 | TIMER_PRESCALER_MASK;  
    OC7M  = 0x00;           // OC mode: do not affect any of the linked output pins (IOC0 - IOC6)

    /* OC mode: output logic always disconnected -> everything is controlled from within the ISR */
    TCTL1 = 0x00;     /* channel 4 - 7 */
    TCTL2 = 0x00;     /* channel 0 - 3 */

}


/* start timer unit */
tVOID ECT_Start(tVOID) {

    /* activate ECT  */
    TSCR1 |=  0x80;                    // start timer (set TEN bit)
    
}

/* stop timer unit */
tVOID ECT_Stop(tVOID) {

    /* deactivate ECT  */
    TSCR1 &= ~0x80;                    // stop timer (clear TEN bit)
    
}


/* set period for individual channels (OC) */
tVOID TSetPeriod_OC(tINT16U channel, tINT16U reload_value) {

    switch (channel) {

        case 0:
        
            #if T0_MODE == TMode_OC
            TC0_ReloadValue = reload_value;
            TC0 = TC0_ReloadValue;
            #endif
            
            break;
            
        case 1:
        
            #if T1_MODE == TMode_OC
            TC1_ReloadValue = reload_value;
            TC1 = TC1_ReloadValue;
            #endif
            
            break;
            
        case 2:
        
            #if T2_MODE == TMode_OC
            TC2_ReloadValue = reload_value;
            TC2 = TC2_ReloadValue;
            #endif
            
            break;
            
        case 3:
        
            #if T3_MODE == TMode_OC
            TC3_ReloadValue = reload_value;
            TC3 = TC3_ReloadValue;
            #endif
            
            break;
            
        case 4:
        
            #if T4_MODE == TMode_OC
            TC4_ReloadValue = reload_value;
            TC4 = TC4_ReloadValue;
            #endif
            
            break;
            
        case 5:
        
            #if T5_MODE == TMode_OC
            TC5_ReloadValue = reload_value;
            TC5 = TC5_ReloadValue;
            #endif
            
            break;
            
        case 6:
        
            #if T6_MODE == TMode_OC
            TC6_ReloadValue = reload_value;
            TC6 = TC6_ReloadValue;
            #endif
            
            break;
            
        case 7:
        
            #if T7_MODE == TMode_OC
            TC7_ReloadValue = reload_value;
            TC7 = TC7_ReloadValue;
            #endif
            
            break;

    }  /* switch */

}


/* configure channels (OC/IC) */
tVOID TChannel_Conf(tINT16U channel, tINT16U mode, tFP32 channelPeriod) {

tINT16U   reload_value = (tINT16U)(65535 * channelPeriod/myECTperiod);

    switch (mode) {

        /* Output Compare mode */      
        case TMode_OC:
        
            /* set period */
            TSetPeriod_OC(channel, reload_value);

            TIOS |=  (0x01 << channel);        // Configure channel for output compare (OC) mode
            DDRT |=  (0x01 << channel);        // Port T, pin 'channel' is output

            //TCNT   = 0;                      // restart timer from scratch
            //TFLG1  = 0xff;                   // clear all pending interrupt requests 

            break;


        /* Input Capture mode */      
        case TMode_IC:
        
            TIOS &= ~(0x01 << channel);        // Configure channel for input capture (IC) mode
            DDRT &= ~(0x01 << channel);        // Port T, pin 'channel' is input

            /* configure for 'capture on rising edge' */
            if (channel < 4) {

                /* channels 0 - 3 */
                TCTL4 |=  (0x0001 << 2 * channel);        // capture on rising edge (EDGxB | EDGxA = '01')
                TCTL4 &= ~(0x0002 << 2 * channel);        // capture on rising edge (EDGxB | EDGxA = '01')

            } else {

                /* channels 4 - 7 */
                TCTL3 |=  (0x0001 << 2 * (channel - 4));  // capture on rising edge (EDGxB | EDGxA = '01')
                TCTL3 &= ~(0x0002 << 2 * (channel - 4));  // capture on rising edge (EDGxB | EDGxA = '01')
                
            }

    }  /* switch (mode) */

}


/* enable o/p logic for individual channels (OC/IC) */
tVOID TChannel_Enable(tINT16U channel) {

    /* start timer 'x' by enabling its interrupt (used to reload TCx)  */
    TFLG1 |=  (0x01 << channel);           // clear event flag for channel 'x'
    TIE   |=  (0x01 << channel);           // enable channel 'x' interrupt
}


/* stop individual channels (OC/IC) */
tVOID TChannel_Disable(tINT16U channel) {

    /* stop timer 'x' by disabling the channel interrupt */
    TIE   &= ~(0x01 << channel);           // disable channel 'x' interrupt
    TFLG1 |=  (0x01 << channel);           // clear event flag for channel 'x'
    PTT   &= ~(0x01 << channel);           // Port T, pin 'channel' low
}


/* read out IC channel and scale to time */
tFP32 TChannel_ICresult(tINT16U channel) {

    switch (channel) {

        case 0:
        
            #if T0_MODE == TMode_IC
            return ((tFP32)TC0_diff) / 65535 * myECTperiod;
            #endif
            
            break;
            
        case 1:
        
            #if T1_MODE == TMode_IC
            return ((tFP32)TC1_diff) / 65535 * myECTperiod;
            #endif
            
            break;
            
        case 2:
        
            #if T2_MODE == TMode_IC
            return ((tFP32)TC2_diff) / 65535 * myECTperiod;
            #endif
            
            break;
            
        case 3:
        
            #if T3_MODE == TMode_IC
            return ((tFP32)TC3_diff) / 65535 * myECTperiod;
            #endif
            
            break;
            
        case 4:
        
            #if T4_MODE == TMode_IC
            return ((tFP32)TC4_diff) / 65535 * myECTperiod;
            #endif
            
            break;
            
        case 5:
        
            #if T5_MODE == TMode_IC
            return ((tFP32)TC5_diff) / 65535 * myECTperiod;
            #endif
            
            break;
            
        case 6:
        
            #if T6_MODE == TMode_IC
            return ((tFP32)TC6_diff) / 65535 * myECTperiod;
            #endif
            
            break;
            
        case 7:
        
            #if T7_MODE == TMode_IC
            return ((tFP32)TC7_diff) / 65535 * myECTperiod;
            #endif
            
            break;

    }  /* switch */

    /* should never be reached */
    return -1.0;

}




/* interrupt service handlers for timer blocks - RFComms ISR is defined in 'radioServer.c' or 'radioClient.c' */

#if HAS_TIMERBLOCKS > 0


/* interrupt handler, timer 0 (vector 8) */

#define CPL_PRAGMA_ISR_START
#include "cpl_pragma.h"

CPL_INTERRUPT tVOID T0_ISR(tVOID) {

    #if T0_MODE == TMode_OC
    /* OC mode */
    PTT ^= 0x01;    // toggle timer pin
    TC0  = (tINT16U)(TC0 + TC0_ReloadValue);
    #endif

    #if T0_MODE == TMode_IC
    /* IC mode */
    TCx_latch = TC0;

    if (TC0_Capture_last < TCx_latch) {

        TC0_diff = TCx_latch - TC0_Capture_last;

    } else {

        TC0_diff = 65535 - TC0_Capture_last + TCx_latch;

    }

    TC0_Capture_last = TCx_latch;
    #endif

    TFLG1 = 0x01;          // acknowledge interrupt (clears C0F)

}

#define CPL_PRAGMA_ISR_STOP
#include "cpl_pragma.h"


/* interrupt handler, timer 1 (vector 9) */

#define CPL_PRAGMA_ISR_START
#include "cpl_pragma.h"

CPL_INTERRUPT tVOID T1_ISR(tVOID) {

    #if T1_MODE == TMode_OC
    /* OC mode */
    PTT ^= 0x02;    // toggle timer pin
    TC1  = (tINT16U)(TC1 + TC1_ReloadValue);
    #endif

    #if T1_MODE == TMode_IC
    /* IC mode */
    TCx_latch = TC1;

    if (TC1_Capture_last < TCx_latch) {

        TC1_diff = TCx_latch - TC1_Capture_last;

    } else {

        TC1_diff = 65535 - TC1_Capture_last + TCx_latch;

    }

    TC1_Capture_last = TCx_latch;
    #endif

    TFLG1 = 0x02;          // acknowledge interrupt (clears C1F)

}

#define CPL_PRAGMA_ISR_STOP
#include "cpl_pragma.h"



/* interrupt handler, timer 2 (vector 10) */

#define CPL_PRAGMA_ISR_START
#include "cpl_pragma.h"

CPL_INTERRUPT tVOID T2_ISR(tVOID) {

    #if T2_MODE == TMode_OC
    /* OC mode */
    PTT ^= 0x04;    // toggle timer pin
    TC2  = (tINT16U)(TC2 + TC2_ReloadValue);
    #endif

    #if T2_MODE == TMode_IC
    /* IC mode */
    TCx_latch = TC2;

    if (TC2_Capture_last < TCx_latch) {

        TC2_diff = TCx_latch - TC2_Capture_last;

    } else {

        TC2_diff = 65535 - TC2_Capture_last + TCx_latch;

    }

    TC2_Capture_last = TCx_latch;
    #endif

    TFLG1 = 0x04;          // acknowledge interrupt (clears C2F)

}

#define CPL_PRAGMA_ISR_STOP
#include "cpl_pragma.h"


/* interrupt handler, timer 3 (vector 11) */

#define CPL_PRAGMA_ISR_START
#include "cpl_pragma.h"

CPL_INTERRUPT tVOID T3_ISR(tVOID) {

    #if T3_MODE == TMode_OC
    /* OC mode */
    PTT ^= 0x08;    // toggle timer pin
    TC3  = (tINT16U)(TC3 + TC3_ReloadValue);
    #endif

    #if T3_MODE == TMode_IC
    /* IC mode */
    TCx_latch = TC3;

    if (TC3_Capture_last < TCx_latch) {

        TC3_diff = TCx_latch - TC3_Capture_last;

    } else {

        TC3_diff = 65535 - TC3_Capture_last + TCx_latch;

    }

    TC3_Capture_last = TCx_latch;
    #endif

    TFLG1 = 0x08;          // acknowledge interrupt (clears C3F)

}

#define CPL_PRAGMA_ISR_STOP
#include "cpl_pragma.h"


/* interrupt handler, timer 4 (vector 12) */

#define CPL_PRAGMA_ISR_START
#include "cpl_pragma.h"

CPL_INTERRUPT tVOID T4_ISR(tVOID) {

    #if T4_MODE == TMode_OC
    /* OC mode */
    PTT ^= 0x10;    // toggle timer pin
    TC4  = (tINT16U)(TC4 + TC4_ReloadValue);
    #endif

    #if T4_MODE == TMode_IC
    /* IC mode */
    TCx_latch = TC4;

    if (TC4_Capture_last < TCx_latch) {

        TC4_diff = TCx_latch - TC4_Capture_last;

    } else {

        TC4_diff = 65535 - TC4_Capture_last + TCx_latch;

    }

    TC4_Capture_last = TCx_latch;
    #endif

    TFLG1 = 0x10;          // acknowledge interrupt (clears C4F)

}

#define CPL_PRAGMA_ISR_STOP
#include "cpl_pragma.h"


/* interrupt handler, timer 5 (vector 13) */

#define CPL_PRAGMA_ISR_START
#include "cpl_pragma.h"

CPL_INTERRUPT tVOID T5_ISR(tVOID) {

    #if T5_MODE == TMode_OC
    /* OC mode */
    PTT ^= 0x20;    // toggle timer pin
    TC5  = (tINT16U)(TC5 + TC5_ReloadValue);
    #endif

    #if T5_MODE == TMode_IC
    /* IC mode */
    TCx_latch = TC5;

    if (TC5_Capture_last < TCx_latch) {

        TC5_diff = TCx_latch - TC5_Capture_last;

    } else {

        TC5_diff = 65535 - TC5_Capture_last + TCx_latch;

    }

    TC5_Capture_last = TCx_latch;
    #endif

    TFLG1 = 0x20;          // acknowledge interrupt (clears C5F)

}

#define CPL_PRAGMA_ISR_STOP
#include "cpl_pragma.h"


/* interrupt handler, timer 6 (vector 14) */

#define CPL_PRAGMA_ISR_START
#include "cpl_pragma.h"

CPL_INTERRUPT tVOID T6_ISR(tVOID) {

    #if T6_MODE == TMode_OC
    /* OC mode */
    PTT ^= 0x40;    // toggle timer pin
    TC6  = (tINT16U)(TC6 + TC6_ReloadValue);
    #endif

    #if T6_MODE == TMode_IC
    /* IC mode */
    TCx_latch = TC6;

    if (TC6_Capture_last < TCx_latch) {

        TC6_diff = TCx_latch - TC6_Capture_last;

    } else {

        TC6_diff = 65535 - TC6_Capture_last + TCx_latch;

    }

    TC6_Capture_last = TCx_latch;
    #endif

    TFLG1 = 0x40;          // acknowledge interrupt (clears C6F)

}

#define CPL_PRAGMA_ISR_STOP
#include "cpl_pragma.h"


/* interrupt handler, timer 7 (vector 15) */

#define CPL_PRAGMA_ISR_START
#include "cpl_pragma.h"

CPL_INTERRUPT tVOID T7_ISR(tVOID) {

    #if T7_MODE == TMode_OC
    /* OC mode */
    PTT ^= 0x80;    // toggle timer pin
    TC7  = (tINT16U)(TC7 + TC7_ReloadValue);
    #endif

    #if T7_MODE == TMode_IC
    /* IC mode */
    TCx_latch = TC7;

    if (TC7_Capture_last < TCx_latch) {

        TC7_diff = TCx_latch - TC7_Capture_last;

    } else {

        TC7_diff = 65535 - TC7_Capture_last + TCx_latch;

    }

    TC7_Capture_last = TCx_latch;
    #endif

    TFLG1 = 0x80;          // acknowledge interrupt (clears C7F)

}

#define CPL_PRAGMA_ISR_STOP
#include "cpl_pragma.h"


#endif  /* HAS_TIMERBLOCKS */



/* the TOF interrupt handler is included whenever HAS_TIMERBLOCKS or HAS_RFCOMMS are non - zero */
/* timer overflow interrupt handler (vector 16) */

#define CPL_PRAGMA_ISR_START
#include "cpl_pragma.h"

CPL_INTERRUPT tVOID TOF_ISR(tVOID) {

    /* count TOF interrupts */
    myTOFcounter++;

    TFLG2 = 0x80;          // acknowledge interrupt (clears TOF)

}

#define CPL_PRAGMA_ISR_STOP
#include "cpl_pragma.h"

/* end of interrupt service handler section ===================================   */


#endif  /* HAS_TIMERBLOCKS | HAS_RFCOMMS*/
