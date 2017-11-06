/*
 *********************************************************************************************************
 *
 * timer support functions, Freescale MC9S12
 *
 * (c) Frank Wörnle, 2010
 * 
 *********************************************************************************************************
 *
 * File              : bsp_timer.h
 * Version           : 1.00
 * Last modification : 29.07.2010, Frank Wörnle
 *
 *********************************************************************************************************
 */
 
#ifndef _BSP_TIMER_H_
#define _BSP_TIMER_H_



/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */

#include "bsp_includes.h"                        /* all controler specific includes        */
#include "mc_defines.h"                          /* CORE_RTI, CORE_T7ISR                   */



/*
 *********************************************************************************************************
 *    PUBLIC MACROS
 *********************************************************************************************************
 */

/* disable TC7 interrupt */
#define InterruptDisable_TC7     (TIE &= ~0x80)

/* enable TC7 interrupt */
#define InterruptEnable_TC7      (TIE |=  0x80)

/* Core timer macros (TC7) ================================================ */
#if CORE_TIMER == CORE_T7ISR

#define CoreTimer_Stop            TC7_Stop()
#define CoreTimer_Start           TC7_Start()
#define CoreTimer_SetPldFnc(x)    TC7_SetPldFnc(x)
#define CoreTimer_GetPldFnc       TC7_GetPldFnc()
#define CoreTimer_ClrPldFnc       TC7_ClrPldFnc()
#define CoreTimer_Init(x)         TC7_Init(x)
#define CoreTimer_SetSmplTime(x)  TC7_SetSampleTime(x)

#endif  /* CORE_TIMER */

/* mode:  OC -> 1, IC -> 2 */
#define TMode_OC  1
#define TMode_IC  2

/* ECT settings */
#define MIN_ECT_PERIOD            0.002730625             // minimum period : 2.73 ms  (65536*42 ns = 2.73 ms)
#define MAX_ECT_PERIOD            MIN_ECT_PERIOD*128      // maximum period : 349.5 ms (MIN_PERIOD * 2^7 = 349.5 ms)


 
/*
 *********************************************************************************************************
 *    DECLARATION OF GLOBAL VARIABLES
 *********************************************************************************************************
 */

/* declare global ECT variables */
extern tINT32U      myTOFcounter;
extern tFP32        myECTperiod;



/*
 *********************************************************************************************************
 *    DECLARATION OF PUBLIC FUNCTIONS
 *********************************************************************************************************
 */
 
/* access functions for SCI0 timeouts */
#if ( (BSP_SCI0_TIMEOUT_SUPP == 1) && (BSP_SCI0_TIMEOUT_UNIT == CORE_T7ISR) )
extern tVOID                SCI0_TimeoutInit        (   tFP32        timeoutPeriod  );
extern tVOID                resetTimeoutCounterSCI0 (   tVOID                       );
extern tBOOLEAN             timeoutSCI0             (   tVOID                       );
#endif

/* access functions for SCI1 timeouts */ 
#if ( (BSP_SCI1_TIMEOUT_SUPP == 1) && (BSP_SCI1_TIMEOUT_UNIT == CORE_T7ISR) )
extern tVOID                SCI1_TimeoutInit        (   tFP32        timeoutPeriod  );
extern tVOID                resetTimeoutCounterSCI1 (   tVOID                       );
extern tBOOLEAN             timeoutSCI1             (   tVOID                       );
#endif


extern tVOID                ECT_Init                (   tVOID                       );
extern tVOID                ECT_Start               (   tVOID                       );
extern tVOID                ECT_Stop                (   tVOID                       );
extern tVOID                TSetPeriod_OC           (   tINT16U      channel, 
                                                        tINT16U      reload_value   );
extern tVOID                TChannel_Conf           (   tINT16U      channel, 
                                                        tINT16U      mode, 
                                                        tFP32        channelPeriod  );
extern tVOID                TChannel_Enable         (   tINT16U      channel        );
extern tVOID                TChannel_Disable        (   tINT16U      channel        );
extern tFP32                TChannel_ICresult       (   tINT16U      channel        );

extern tVOID                TC7_Init                (   tFP32        sampletime     );


#endif  /* _BSP_TIMER_H_ */
