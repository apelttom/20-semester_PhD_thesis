/*
 *********************************************************************************************************
 *
 * RTI support functions, Freescale MC9S12
 *
 * (c) Frank Wörnle, 2009
 * 
 *********************************************************************************************************
 *
 * File              : bsp_rti.h
 * Version           : 1.00
 * Last modification : 18.04.2009, Frank Wörnle
 *
 *********************************************************************************************************
 */
 
#ifndef _BSP_RTI_H_
#define _BSP_RTI_H_



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

/* disable RTI interrupt */
#define InterruptDisable_RTI      CRGINT_RTIE = 0

/* enable RTI interrupt */
#define InterruptEnable_RTI       CRGINT_RTIE = 1

/* Core timer macros (RTI) ================================================ */
#if CORE_TIMER == CORE_RTI

#define CoreTimer_Stop            RTI_Stop()
#define CoreTimer_Start           RTI_Start()
#define CoreTimer_SetPldFnc(x)    RTI_SetPldFnc(x)
#define CoreTimer_GetPldFnc       RTI_GetPldFnc()
#define CoreTimer_ClrPldFnc       RTI_ClrPldFnc()
#define CoreTimer_Init(x)         RTI_Init(x)
#define CoreTimer_SetSmplTime(x)  RTI_SetSampleTime(x)

#endif  /* CORE_TIMER */

 
/*
 *********************************************************************************************************
 *    DECLARATION OF PUBLIC FUNCTIONS
 *********************************************************************************************************
 */
 
/* access functions for SCI0 timeouts */
#if ( (BSP_SCI0_TIMEOUT_SUPP == 1) && (BSP_SCI0_TIMEOUT_UNIT == CORE_RTI) )
extern tVOID                SCI0_TimeoutInit        (   tFP32        timeoutPeriod  );
extern tVOID                resetTimeoutCounterSCI0 (   tVOID                       );
extern tBOOLEAN             timeoutSCI0             (   tVOID                       );
#endif

/* access functions for SCI1 timeouts */ 
#if ( (BSP_SCI1_TIMEOUT_SUPP == 1) && (BSP_SCI1_TIMEOUT_UNIT == CORE_RTI) )
extern tVOID                SCI1_TimeoutInit        (   tFP32        timeoutPeriod  );
extern tVOID                resetTimeoutCounterSCI1 (   tVOID                       );
extern tBOOLEAN             timeoutSCI1             (   tVOID                       );
#endif


/* initialize RTI unit */
extern tVOID                RTI_SetSampleTime       (   tFP32        sampleTime     );
extern tVOID                RTI_Init                (   tFP32        sampleTime     );

/* activate and deactive RTI  (Note: A call to RTI_Init will not start the RT unit) */
extern tVOID                RTI_Start               (   tVOID                       );
extern tVOID                RTI_Stop                (   tVOID                       );

/* install/remove RTI user playload function */
extern tVOID                RTI_SetPldFnc           (   tUsrFncISR  *pFctAddress    );
extern tUsrFncISR          *RTI_GetPldFnc           (   tVOID                       );
extern tVOID                RTI_ClrPldFnc           (   tVOID                       );


/*
 *********************************************************************************************************
 *    ERROR CHECKING
 *********************************************************************************************************
 */



#endif /* _BSP_RTI_H_ */
