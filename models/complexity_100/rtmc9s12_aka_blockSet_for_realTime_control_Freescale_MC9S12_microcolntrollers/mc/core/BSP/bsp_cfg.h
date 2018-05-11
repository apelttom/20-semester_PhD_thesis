/*
 *********************************************************************************************************
 *
 * Board Support Package configuration file
 *
 * (c) Frank Wörnle, 2010
 * 
 *********************************************************************************************************
 *
 * File              : bsp_cfg.h
 * Version           : 1.14
 * Last modification : 30.08.2010, fwoernle, added support for generic DG128 boards
 *
 *********************************************************************************************************
 */
 
#ifndef _BSP_CFG_H_
#define _BSP_CFG_H_



/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */

/* Model dependent constants */
#include "mc_defines.h"



/*
 *********************************************************************************************************
 *    EVB information
 *********************************************************************************************************
 */

#define  BSP_DRAGON12                       1                        /* Wytec Dragon12, revision B board       */
#define  BSP_DRAGON12PLUS                   2                        /* Wytec Dragon12plus, revision D board   */
#define  BSP_MINIDRAGONPLUS                 3                        /* Wytec MiniDragonPlus                   */
#define  BSP_MINIDRAGONPLUS2                4                        /* Wytec MiniDragonPlus2                  */
#define  BSP_DRAGONFLY12C128                5                        /* Wytec DragonFly12, MC9S12C128, 40 pin  */
#define  BSP_DRAGONFLY12C32                 6                        /* Wytec DragonFly12, MC9S12C32, 40 pin   */
#define  BSP_GENERIC_DG128                  7                        /* Unknown manufacturer, MC9S12DG128      */

/* define Evaluation Board */
#define  BSP_EVB                            TARGET_BOARD             /* chosen automatically (rtmc9s12_Target) */



/*
 *********************************************************************************************************
 *    CPU information
 *********************************************************************************************************
 */

#define  BSP_MC9S12DP256B                   1                        /* MC9S12DP256B                           */
#define  BSP_MC9S12DG256                    2                        /* MC9S12DG256                            */
#define  BSP_MC9S12C128                     3                        /* MC9S12C128                             */
#define  BSP_MC9S12C32                      4                        /* MC9S12C32                              */
#define  BSP_MC9S12DG128                    5                        /* MC9S12DG128                            */

/* define CPU */
#if      BSP_EVB == BSP_DRAGON12
#define  BSP_CPU                            BSP_MC9S12DP256B         /* Dragon12, revision B board             */
#elif    BSP_EVB == BSP_DRAGON12PLUS
#define  BSP_CPU                            BSP_MC9S12DG256          /* Dragon12plus, revision D board         */
#elif    BSP_EVB == BSP_MINIDRAGONPLUS
#define  BSP_CPU                            BSP_MC9S12DP256B         /* MiniDragonPlus                         */
#elif    BSP_EVB == BSP_MINIDRAGONPLUS2
#define  BSP_CPU                            BSP_MC9S12DG256          /* MiniDragonPlus, revision E board       */
#elif    BSP_EVB == BSP_DRAGONFLY12C128
#define  BSP_CPU                            BSP_MC9S12C128           /* DragonFly12, MC9S12C128                */
#elif    BSP_EVB == BSP_DRAGONFLY12C32
#define  BSP_CPU                            BSP_MC9S12C32            /* DragonFly12, MC9S12C32                 */
#elif    BSP_EVB == BSP_GENERIC_DG128
#define  BSP_CPU                            BSP_MC9S12DG128          /* Unknown manufacturer, MC9S12DG128      */
#endif



/*
 *********************************************************************************************************
 *    Oscillator frequency in MHz (crystal)
 *********************************************************************************************************
 */

/* define oscillator frequency (crystal) */
#ifdef   TARGET_OSCILLATOR
 #define  BSP_OSC_FREQ_MHZ                   TARGET_OSCILLATOR       /* oscillator frequency from user dialog  */
#else
 #if      BSP_EVB == BSP_DRAGON12
 #define  BSP_OSC_FREQ_MHZ                   4                       /* Dragon12             :  4 MHZ          */
 #elif    BSP_EVB == BSP_DRAGON12PLUS
 #define  BSP_OSC_FREQ_MHZ                   8                       /* Dragon12plus         :  8 MHZ          */
 #elif    BSP_EVB == BSP_MINIDRAGONPLUS
 #define  BSP_OSC_FREQ_MHZ                  16                       /* MiniDragonPlus       : 16 MHZ          */
 #elif    BSP_EVB == BSP_MINIDRAGONPLUS2
 #define  BSP_OSC_FREQ_MHZ                  16                       /* MiniDragonPlus2      : 16 MHZ          */
 #elif    BSP_EVB == BSP_DRAGONFLY12C128
 #define  BSP_OSC_FREQ_MHZ                   8                       /* DragonFly12C128      :  8 MHZ          */
 #elif    BSP_EVB == BSP_DRAGONFLY12C32
 #define  BSP_OSC_FREQ_MHZ                   8                       /* DragonFly12C32       :  8 MHZ          */
 #elif    BSP_EVB == BSP_GENERIC_DG128
 #define  BSP_OSC_FREQ_MHZ                  16                       /* Unknown manufacturer : 16 MHZ          */
 #endif
#endif


/*
 *********************************************************************************************************
 *    Serial Communication Interface (SCI)
 *********************************************************************************************************
 */

/* hardware dependent settings  --  do not modify this section */

#if      BSP_CPU == BSP_MC9S12DP256B
#define  BSP_SCI0_SUPP                      1                        /* MC9S12DP256B     : SCI0, SCI1          */
#define  BSP_SCI1_SUPP                      1                        /* MC9S12DP256B     : SCI0, SCI1          */
#elif    BSP_CPU == BSP_MC9S12DG256     
#define  BSP_SCI0_SUPP                      1                        /* MC9S12DG256      : SCI0, SCI1          */
#define  BSP_SCI1_SUPP                      1                        /* MC9S12DG256      : SCI0, SCI1          */
#elif    BSP_CPU == BSP_MC9S12C128
#define  BSP_SCI0_SUPP                      1                        /* MC9S12C128       : SCI0                */
#define  BSP_SCI1_SUPP                      0                        /* MC9S12C128       : SCI0                */
#elif    BSP_CPU == BSP_MC9S12C32
#define  BSP_SCI0_SUPP                      1                        /* MC9S12C32        : SCI0                */
#define  BSP_SCI1_SUPP                      0                        /* MC9S12C32        : SCI0                */
#elif    BSP_CPU == BSP_MC9S12DG128
#define  BSP_SCI0_SUPP                      1                        /* MC9S12DG128      : SCI0, SCI1          */
#define  BSP_SCI1_SUPP                      1                        /* MC9S12DG128      : SCI0, SCI1          */
#else
#define  BSP_SCI0_SUPP                      0                        /* UNKNOWN          : no SCI support      */
#define  BSP_SCI1_SUPP                      0                        /* UNKNOWN          : no SCI support      */
#endif


/* application dependent BSP settings  --  adjust to suit application */

#define  BSP_SCI0_TIMEOUT_SUPP              1                        /* bsp support for SCI0 timeout mechanism */
#define  BSP_SCI0_TIMEOUT_MAX_SEC           10.F                     /* maximum SCI0 timeout value in seconds  */
#define  BSP_SCI0_TERM_ECHO                 0                        /* terminal mode: echo characters         */
#define  BSP_SCI0_ERROR_SUPP                1                        /* error memory (buffer full -> timeout)  */
#define  BSP_SCI0_TIMEOUT_UNIT              CORE_RTI                 /* timeout mechanism through RTI/T7ISR    */

#define  BSP_SCI1_TIMEOUT_SUPP              1                        /* bsp support for SCI1 timeout mechanism */
#define  BSP_SCI1_TIMEOUT_MAX_SEC           10.F                     /* maximum SCI1 timeout value in seconds  */
#define  BSP_SCI1_TERM_ECHO                 0                        /* terminal mode: echo characters         */
#define  BSP_SCI1_ERROR_SUPP                1                        /* error memory (buffer full -> timeout)  */
#define  BSP_SCI1_TIMEOUT_UNIT              CORE_RTI                 /* timeout mechanism through RTI/T7ISR    */



/*
 *********************************************************************************************************
 *    Real-Time Interrupt (RTI)
 *********************************************************************************************************
 */

/* application dependent BSP settings  --  adjust to suit application */

#define  BSP_RTI_SUPP                       1                        /* enable (1) / disable (0) RTI support                        */
#define  BSP_RTI_OVERRUN_CHECK              1                        /* enable (1) / disable (0) RTI interrupt overrun checking     */
#define  BSP_RTI_ISR_REENTRANT              1                        /* enable (1) / disable (0) support for re-entrant RTI ISR     */
#define  BSP_RTI_ERROR_SUPP                 1                        /* RTI ISR overrun -> error                                    */
#define  BSP_RTI_TICK_RATE_HZ               1000                     /* base rate of RTI timer (Hz)                                 */


/*
 *********************************************************************************************************
 *    Enhanced Capture Timer (ECT)
 *********************************************************************************************************
 */

/* application dependent BSP settings  --  adjust to suit application */

#define  BSP_ECT_SUPP                       1                        /* enable (1) / disable (0) ECT support                        */
#define  BSP_ECT_OVERRUN_CHECK              1                        /* enable (1) / disable (0) ECT interrupt overrun checking     */
#define  BSP_ECT_ISR_REENTRANT              1                        /* enable (1) / disable (0) support for re-entrant ECT ISR     */
#define  BSP_ECT_ERROR_SUPP                 1                        /* ECT ISR overrun -> error                                    */
#define  BSP_ECT_TICK_RATE_HZ               1000                     /* base rate of ECT timer (Hz)                                 */


/*
 *********************************************************************************************************
 *    CAN Interface (MSCAN)
 *********************************************************************************************************
 */

/* hardware dependent settings  --  do not modify this section */

#if      BSP_CPU == BSP_MC9S12DP256B
#define  BSP_MSCAN0_SUPP                    1                        /* MC9S12DP256B     : MSCAN0, MSCAN1, MSCAN2, MSCAN3, MSCAN4   */
#define  BSP_MSCAN1_SUPP                    1                        /* MC9S12DP256B     : MSCAN0, MSCAN1, MSCAN2, MSCAN3, MSCAN4   */
#define  BSP_MSCAN2_SUPP                    1                        /* MC9S12DP256B     : MSCAN0, MSCAN1, MSCAN2, MSCAN3, MSCAN4   */
#define  BSP_MSCAN3_SUPP                    1                        /* MC9S12DP256B     : MSCAN0, MSCAN1, MSCAN2, MSCAN3, MSCAN4   */
#define  BSP_MSCAN4_SUPP                    1                        /* MC9S12DP256B     : MSCAN0, MSCAN1, MSCAN2, MSCAN3, MSCAN4   */
#elif    BSP_CPU == BSP_MC9S12DG256
#define  BSP_MSCAN0_SUPP                    1                        /* MC9S12DG256      : MSCAN0, MSCAN4                           */
#define  BSP_MSCAN1_SUPP                    0                        /* MC9S12DG256      : MSCAN0, MSCAN4                           */
#define  BSP_MSCAN2_SUPP                    0                        /* MC9S12DG256      : MSCAN0, MSCAN4                           */
#define  BSP_MSCAN3_SUPP                    0                        /* MC9S12DG256      : MSCAN0, MSCAN4                           */
#define  BSP_MSCAN4_SUPP                    1                        /* MC9S12DG256      : MSCAN0, MSCAN4                           */
#elif    BSP_CPU == BSP_MC9S12C128
#define  BSP_MSCAN0_SUPP                    1                        /* MC9S12C128       : MSCAN0                                   */
#define  BSP_MSCAN1_SUPP                    0                        /* MC9S12C128       : MSCAN0                                   */
#define  BSP_MSCAN2_SUPP                    0                        /* MC9S12C128       : MSCAN0                                   */
#define  BSP_MSCAN3_SUPP                    0                        /* MC9S12C128       : MSCAN0                                   */
#define  BSP_MSCAN4_SUPP                    0                        /* MC9S12C128       : MSCAN0                                   */
#elif    BSP_CPU == BSP_MC9S12C32
#define  BSP_MSCAN0_SUPP                    1                        /* MC9S12C32        : MSCAN0                                   */
#define  BSP_MSCAN1_SUPP                    0                        /* MC9S12C32        : MSCAN0                                   */
#define  BSP_MSCAN2_SUPP                    0                        /* MC9S12C32        : MSCAN0                                   */
#define  BSP_MSCAN3_SUPP                    0                        /* MC9S12C32        : MSCAN0                                   */
#define  BSP_MSCAN4_SUPP                    0                        /* MC9S12C32        : MSCAN0                                   */
#elif    BSP_CPU == BSP_GENERIC_DG128
#define  BSP_MSCAN0_SUPP                    1                        /* MC9S12DG128      : MSCAN0                                   */
#define  BSP_MSCAN1_SUPP                    0                        /* MC9S12DG128      : MSCAN0                                   */
#define  BSP_MSCAN2_SUPP                    0                        /* MC9S12DG128      : MSCAN0                                   */
#define  BSP_MSCAN3_SUPP                    0                        /* MC9S12DG128      : MSCAN0                                   */
#define  BSP_MSCAN4_SUPP                    0                        /* MC9S12DG128      : MSCAN0                                   */
#else
#define  BSP_MSCAN0_SUPP                    0                        /* UNKNOWN          : no CAN support                           */
#define  BSP_MSCAN1_SUPP                    0                        /* UNKNOWN          : no CAN support                           */
#define  BSP_MSCAN2_SUPP                    0                        /* UNKNOWN          : no CAN support                           */
#define  BSP_MSCAN3_SUPP                    0                        /* UNKNOWN          : no CAN support                           */
#define  BSP_MSCAN4_SUPP                    0                        /* UNKNOWN          : no CAN support                           */
#endif



/*
 *********************************************************************************************************
 *    DERIVED MACRO DEFINITIONS
 *********************************************************************************************************
 */


/* derived RTI settings */
#if      BSP_RTI_SUPP == 0
#undef   BSP_RTI_OVERRUN_CHECK
#define  BSP_RTI_OVERRUN_CHECK              0                        /* no RTI support -> no RTI ISR overrun   */
#define  BSP_RTI_ISR                        0                        /* no RTI support -> no RTI ISR           */
#define  BSP_RTI_ERROR_SUPP                 0                        /* no error support (RTI ISR overrun)     */
#else
#define  BSP_RTI_ISR                        1                        /* RTI support always comes with an ISR   */
#endif


/* derived ECT settings */
#if      BSP_ECT_SUPP == 0
#undef   BSP_ECT_OVERRUN_CHECK
#define  BSP_ECT_OVERRUN_CHECK              0                        /* no ECT support -> no ECT ISR overrun   */
#define  BSP_ECT_ISR                        0                        /* no ECT support -> no ECT ISR           */
#define  BSP_ECT_ERROR_SUPP                 0                        /* no error support (ECT ISR overrun)     */
#else
#define  BSP_ECT_ISR                        1                        /* ECT support always comes with an ISR   */
#endif


/* derived SCI0 settings */
#if      BSP_SCI0_SUPP == 0
#undef   BSP_SCI0_TIMEOUT_SUPP
#define  BSP_SCI0_TIMEOUT_SUPP              0                        /* no bsp support for SCI0 timeouts       */
#undef   BSP_SCI0_TERM_ECHO
#define  BSP_SCI0_TERM_ECHO                 0                        /* no SCI0 echo (terminal mode)           */
#undef   BSP_SCI0_ERROR_SUPP
#define  BSP_SCI0_ERROR_SUPP                0                        /* no SCI0 error memory                   */
#else
#if     (BSP_SCI0_TIMEOUT_SUPP == 1) && (BSP_RTI_SUPP == 0)
 #define BSP_SCI0_TIMEOUT_UNIT              CORE_T7ISR               /* no RTI -> SCI0 timeout mechanism: ECT  */
#endif
#endif

/* derived SCI1 settings */
#if      BSP_SCI1_SUPP == 0
#undef   BSP_SCI1_TIMEOUT_SUPP
#define  BSP_SCI1_TIMEOUT_SUPP              0                        /* no bsp support for SCI1 timeouts       */
#undef   BSP_SCI1_TERM_ECHO
#define  BSP_SCI1_TERM_ECHO                 0                        /* no SCI1 echo (terminal mode)           */
#undef   BSP_SCI1_ERROR_SUPP
#define  BSP_SCI1_ERROR_SUPP                0                        /* no SCI1 error memory                   */
#else
#if     (BSP_SCI1_TIMEOUT_SUPP == 1) && (BSP_RTI_SUPP == 0)
 #define BSP_SCI1_TIMEOUT_UNIT              CORE_T7ISR               /* no RTI -> SCI1 timeout mechanism: ECT  */
#endif
#endif           


/* derived definition of macros BSP_CANx_ISR */
#if      BSP_MSCAN0_SUPP == 0
#define  BSP_CAN0_ISR                       0                        /* no CAN0 support -> no CAN0 ISR (RX/TX) */
#else
#define  BSP_CAN0_ISR                       1                        /* CAN0 support always comes with 2 ISRs  */
#endif
#if      BSP_MSCAN1_SUPP == 0
#define  BSP_CAN1_ISR                       0                        /* no CAN1 support -> no CAN1 ISR (RX/TX) */
#else
#define  BSP_CAN1_ISR                       1                        /* CAN1 support always comes with 2 ISRs  */
#endif
#if      BSP_MSCAN2_SUPP == 0
#define  BSP_CAN2_ISR                       0                        /* no CAN2 support -> no CAN2 ISR (RX/TX) */
#else
#define  BSP_CAN2_ISR                       1                        /* CAN2 support always comes with 2 ISRs  */
#endif
#if      BSP_MSCAN3_SUPP == 0
#define  BSP_CAN3_ISR                       0                        /* no CAN3 support -> no CAN3 ISR (RX/TX) */
#else
#define  BSP_CAN3_ISR                       1                        /* CAN3 support always comes with 2 ISRs  */
#endif
#if      BSP_MSCAN4_SUPP == 0
#define  BSP_CAN4_ISR                       0                        /* no CAN4 support -> no CAN4 ISR (RX/TX) */
#else
#define  BSP_CAN4_ISR                       1                        /* CAN4 support always comes with 2 ISRs  */
#endif


/*
 *********************************************************************************************************
 *    ERROR CHECKING
 *********************************************************************************************************
 */

#if   ((BSP_EVB < 0) || (BSP_EVB > 7))
#error "BSP_EVB is incorrectly defined in bsp_cfg.h. Admissible values: 1, 2, 3, 4, 5, 6, 7"
#endif

#if   ((BSP_CPU < 0) || (BSP_CPU > 5))
#error "BSP_CPU is incorrectly defined in bsp_cfg.h. Admissible values: 1, 2, 3, 4, 5"
#endif

#if   ((BSP_OSC_FREQ_MHZ != 4) && (BSP_OSC_FREQ_MHZ != 8) && (BSP_OSC_FREQ_MHZ != 16))
#error "BSP_OSC_FREQ_MHZ is incorrectly defined in bsp_cfg.h. Admissible values: 4, 8, 16 (MHz)"
#endif

#if   ((BSP_RTI_TICK_RATE_HZ < 0.1) || (BSP_RTI_TICK_RATE_HZ > 10000))
#error "RTI tick rate should be between 0.1 Hz and 10000 Hz (TODO: check validity of these limits, fw-05-10)"
#endif

#if   ((BSP_ECT_TICK_RATE_HZ < 0.1) || (BSP_ECT_TICK_RATE_HZ > 10000))
#error "ECT tick rate should be between 0.1 Hz and 10000 Hz (TODO: check validity of these limits, fw-05-10)"
#endif

#if   (( BSP_RTI_SUPP == 0 ) && ( BSP_CORE_TIMER_UNIT == BSP_CORE_TIMER_RTI ))
#error "Core timer set to RTI, but RTI has not been enabled"
#endif

#if   (( BSP_ECT_SUPP == 0 ) && ( BSP_CORE_TIMER_UNIT == BSP_CORE_TIMER_TC7 ))
#error "Core timer set to TC7, but ECT has not been enabled"
#endif


#endif /* _BSP_CFG_H_ */

