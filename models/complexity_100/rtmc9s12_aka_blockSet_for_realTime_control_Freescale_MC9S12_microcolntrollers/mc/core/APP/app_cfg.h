/*
 *********************************************************************************************************
 *
 * Application configuration file
 *
 * (c) Frank Wörnle, 2009
 * 
 *********************************************************************************************************
 *
 * File              : app_cfg.h
 * Version           : 1.00
 * Last modification : 11.04.2010, fwoernle, adapted to rtmc9s12-target
 *
 *********************************************************************************************************
 */
 
#ifndef _APP_CFG_H_
#define _APP_CFG_H_



/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */

/* Model dependent constants */
#include "mc_defines.h"



/*
 *********************************************************************************************************
 *    RTOS support
 *********************************************************************************************************
 */

#define  APP_RTOS_EN                        RTOSSUPPORT              /* override RTI interrupt service routine */



/*
 *********************************************************************************************************
 *    Serial Communication Interface (SCI)
 *********************************************************************************************************
 */

/* SCI0 support */
#define  APP_SCI0_EN                        1

/* SCI1 support */
#if (TARGET_CPU == BSP_MC9S12DP256B) || (TARGET_CPU == BSP_MC9S12DG256) || (TARGET_CPU == BSP_MC9S12DG128)
#define  APP_SCI1_EN                        1
#define  APP_SCI1_TIMEOUT_EN                1                        /* enable SCI1 timeout mechanism                               */
#else
#define  APP_SCI1_EN                        0
#define  APP_SCI1_TIMEOUT_EN                0                        /* disable SCI1 timeout mechanism                              */
#endif

/* SCI0: configure ring buffer size, timeout behaviour, etc. */
#if (DEBUG_MSG_LVL > 0)
 #define APP_SCI0_RB_RX_EN                  0                        /* no ring buffered comms: RX (SCI0)                           */
 #define APP_SCI0_RB_TX_EN                  0                        /* no ring buffered comms: TX (SCI0)                           */
#else
 #define APP_SCI0_RB_RX_EN                  1                        /* ring buffered comms: RX (SCI0)                              */
 #define APP_SCI0_RB_TX_EN                  1                        /* ring buffered comms: TX (SCI0)                              */
#endif
#define  APP_SCI0_RB_RX_BUF_SIZE            512                      /* SCI0 RX ring buffer size                                    */
#define  APP_SCI0_RB_TX_BUF_SIZE            512                      /* SCI0 TX ring buffer size                                    */
#define  APP_SCI0_TIMEOUT_EN                1                        /* enable/disable SCI0 timeout mechanism                       */
#define  APP_SCI0_TIMEOUT_SEC               10.F                     /* SCI0 timeout value in seconds                               */
#define  APP_SCI0_ISR_RX_LED                0                        /* SCI0 ISR (RX) indicated on LED                              */
#define  APP_SCI0_ISR_TX_LED                0                        /* SCI0 ISR (TX) indicated on LED                              */
#define  APP_SCI0_ISR_REENTRANT             0                        /* enable (1) / disable (0) support for re-entrant SCI0 ISR    */

/* SCI1: configure ring buffer size, timeout behaviour, etc. */
#define  APP_SCI1_RB_RX_EN                  1                        /* ring buffered comms: RX (SCI1)                              */
#define  APP_SCI1_RB_TX_EN                  1                        /* ring buffered comms: TX (SCI1)                              */
#define  APP_SCI1_RB_RX_BUF_SIZE            1024                     /* SCI1 RX ring buffer size                                    */
#define  APP_SCI1_RB_TX_BUF_SIZE            1024                     /* SCI1 TX ring buffer size                                    */
#define  APP_SCI1_TIMEOUT_SEC               10.F                     /* SCI1 timeout value in seconds                               */
#define  APP_SCI1_ISR_RX_LED                0                        /* SCI1 ISR (RX) indicated on LED                              */
#define  APP_SCI1_ISR_TX_LED                0                        /* SCI1 ISR (TX) indicated on LED                              */
#define  APP_SCI1_ISR_REENTRANT             0                        /* enable (1) / disable (0) support for re-entrant SCI1 ISR    */



/*
 *********************************************************************************************************
 *    Real-Time Interrupt (RTI)
 *********************************************************************************************************
 */

#define  APP_RTI_EN                         1



/*
 *********************************************************************************************************
 *    Enhanced Capture Timer (ECT)
 *********************************************************************************************************
 */

#define  APP_ECT_EN                         1



/*
 *********************************************************************************************************
 *    CAN Interface (MSCAN)
 *********************************************************************************************************
 */

#define APP_CAN0_EN                         0
#define APP_CAN1_EN                         0
#define APP_CAN2_EN                         0
#define APP_CAN3_EN                         0
#define APP_CAN4_EN                         0



/*
 *********************************************************************************************************
 *    Analog To Digital Converter (ADC)
 *********************************************************************************************************
 */

/* ATD0 support (interrupt driven ADC)  --  currently not supported (fw-08-10) */
#define APP_ATD0_EN                         0                        /* enable/disable ATD bank #0 (channel 0 - 7)   */

/* ATD1 support (interrupt driven ADC)  --  currently not supported (fw-08-10) */
#if (TARGET_CPU == BSP_MC9S12DP256B) || (TARGET_CPU == BSP_MC9S12DG256) || (TARGET_CPU == BSP_MC9S12DG128)
#define APP_ATD1_EN                         0                        /* enable ATD bank #1 (channel 0 - 7)           */
#else
#define APP_ATD1_EN                         0                        /* disable ATD bank #1 (channel 0 - 7)          */
#endif



/*
 *********************************************************************************************************
 *    DERIVED MACRO DEFINITIONS AND ERROR CHECKING
 *********************************************************************************************************
 */

#include "app_cfg_check.h"                            /* centralized error checking             */


#endif /* _APP_CFG_H_ */
