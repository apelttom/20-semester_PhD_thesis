/*
 *********************************************************************************************************
 *
 * Application configuration validation file
 *
 * (c) Frank Wörnle, 2010
 * 
 *********************************************************************************************************
 *
 * File              : app_cfg_check.h
 * Version           : 1.10
 * Last modification : 28.05.2010, fwoernle, RTOS support added
 *
 *********************************************************************************************************
 */
 
/*
 *********************************************************************************************************
 *********************************************************************************************************
 *              !!!!!!!!!!!!    THIS FILE SHOULD NOT HAVE TO BE MODIFIFED     !!!!!!!!!!!               
 *********************************************************************************************************
 *********************************************************************************************************
 */


#ifndef _APP_CFG_CHECK_H_
#define _APP_CFG_CHECK_H_


/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */

 
/* none -- this file is always included at the end of "app_cfg.h" */
/* none -- this file is always included at the end of "app_cfg.h" */
/* none -- this file is always included at the end of "app_cfg.h" */



/*
 *********************************************************************************************************
 *    DERIVED MACRO DEFINITIONS
 *********************************************************************************************************
 */

/* derived RTI support due to RTOS support */
#if APP_RTOS_EN == 1
#undef  APP_RTI_EN
#define APP_RTI_EN                          1                        /* enable RTI support (RTOS)              */
#endif

/* derived RTI support due to SCI0 communication with timeouts */
#if ( (APP_SCI0_EN == 1) && (APP_SCI0_TIMEOUT_EN == 1) )
#undef   APP_RTI_EN
#define  APP_RTI_EN                         1                        /* enable RTI support (timeouts)          */
#endif

/* derived RTI support due to SCI1 communication with timeouts */
#if ( (APP_SCI1_EN == 1) && (APP_SCI1_TIMEOUT_EN == 1) )
#undef   APP_RTI_EN
#define  APP_RTI_EN                         1                        /* enable RTI support (timeouts)          */
#endif

/* derived ISR support for RTI (always) */
#if APP_RTI_EN  == 1
#define APP_RTI_ISR                         1
#else
#define APP_RTI_ISR                         0
#endif



/* derived ISR support for ECT (always) */
#if APP_ECT_EN  == 1
#define APP_ECT_ISR                         1
#else
#define APP_ECT_ISR                         0
#endif



/* SCI0 using ISR support for RX */
#if (APP_SCI0_EN == 1) && (APP_SCI0_RB_RX_EN == 1)
#define APP_SCI0_RX_ISR                     1
#else
#define APP_SCI0_RX_ISR                     0
#endif

/* SCI0 using ISR support for TX */
#if (APP_SCI0_EN == 1) && (APP_SCI0_RB_TX_EN == 1)
#define APP_SCI0_TX_ISR                     1
#else
#define APP_SCI0_TX_ISR                     0
#endif

/* SCI0 using ISR support (RX or TX) */
#if (APP_SCI0_RX_ISR == 1) || (APP_SCI0_TX_ISR == 1)
#define APP_SCI0_ISR                        1
#else
#define APP_SCI0_ISR                        0
#endif


/* SCI1 using ISR support for RX */
#if (APP_SCI1_EN  == 1) && (APP_SCI1_RB_RX_EN == 1)
#define APP_SCI1_RX_ISR                     1
#else
#define APP_SCI1_RX_ISR                     0
#endif

/* SCI1 using ISR support for TX */
#if (APP_SCI1_EN  == 1) && (APP_SCI1_RB_TX_EN == 1)
#define APP_SCI1_TX_ISR                     1
#else
#define APP_SCI1_TX_ISR                     0
#endif

/* SCI1 using ISR support (RX or TX) */
#if (APP_SCI1_RX_ISR == 1) || (APP_SCI1_TX_ISR == 1)
#define APP_SCI1_ISR                        1
#else
#define APP_SCI1_ISR                        0
#endif



/* CAN0 using ISR support */
#if (APP_CAN0_EN  == 1) && (BSP_CAN0_ISR == 1)
#define APP_CAN0_ISR                        1
#else
#define APP_CAN0_ISR                        0
#endif

/* CAN1 using ISR support */
#if (APP_CAN1_EN  == 1) && (BSP_CAN1_ISR == 1)
#define APP_CAN1_ISR                        1
#else
#define APP_CAN1_ISR                        0
#endif

/* CAN2 using ISR support */
#if (APP_CAN2_EN  == 1) && (BSP_CAN2_ISR == 1)
#define APP_CAN2_ISR                        1
#else
#define APP_CAN2_ISR                        0
#endif

/* CAN3 using ISR support */
#if (APP_CAN3_EN  == 1) && (BSP_CAN3_ISR == 1)
#define APP_CAN3_ISR                        1
#else
#define APP_CAN3_ISR                        0
#endif

/* CAN4 using ISR support */
#if (APP_CAN4_EN  == 1) && (BSP_CAN4_ISR == 1)
#define APP_CAN4_ISR                        1
#else
#define APP_CAN4_ISR                        0
#endif


/* derived macro APP_CANx_EN (set to '1' if any CAN support is to be included) */
#if (APP_CAN0_EN == 1)||(APP_CAN1_EN == 1)||(APP_CAN2_EN == 1)||(APP_CAN3_EN == 1)||(APP_CAN4_EN == 1)
#define APP_CANx_EN                         1
#else
#define APP_CANx_EN                         0
#endif

/* derived macro APP_CANx_ISR (set to '1' if any CAN ISR support is enabled) */
#if (APP_CAN0_ISR == 1)||(APP_CAN1_ISR == 1)||(APP_CAN2_ISR == 1)||(APP_CAN3_ISR == 1)||(APP_CAN4_ISR == 1)
#define APP_CANx_ISR                        1
#else
#define APP_CANx_ISR                        0
#endif


/* derived ISR support for ATD bank #0 (currently always, fw-05-10) */
#if APP_ATD0_EN  == 1
#define APP_ATD0_ISR                        1
#else
#define APP_ATD0_ISR                        0
#endif

/* derived ISR support for ATD bank #1 (currently always, fw-05-10) */
#if APP_ATD1_EN  == 1
#define APP_ATD1_ISR                        1
#else
#define APP_ATD1_ISR                        0
#endif

/* derived macro APP_ATDx_ISR (set to '1' if any ATD ISR support is enabled) */
#if (APP_ATD0_ISR == 1)||(APP_ATD1_ISR == 1)
#define APP_ATDx_ISR                        1
#else
#define APP_ATDx_ISR                        0
#endif


/* derived macro APP_ISR_EN (set to '1' if the ISR support of any HW unit is enabled) */
#if (APP_RTI_ISR == 1)||(APP_ECT_ISR == 1)||(APP_SCI0_ISR == 1)||(APP_SCI1_ISR == 1)||(APP_CANx_ISR == 1)||(APP_ATDx_ISR == 1)
#define APP_ISR_EN                         1
#else
#define APP_ISR_EN                         0
#endif



/*
 *********************************************************************************************************
 *    ERROR CHECKING
 *********************************************************************************************************
 */

/* check validity of RTI settings */
#if APP_RTI_EN == 1
    #if BSP_RTI_SUPP != 1
    #error RTI not available on chosen microcontroller (should never happen).
    #endif
#endif
#if ( APP_RTI_EN == 0 ) && ( BSP_CORE_TIMER_UNIT == BSP_CORE_TIMER_RTI )
    #error "Core timer set to RTI, but RTI has not been enabled at application level (APP)"
#endif


/* check validity of ECT settings */
#if APP_ECT_EN == 1
    #if BSP_ECT_SUPP != 1
    #error ECT not available on chosen microcontroller (should never happen).
    #endif
#endif
#if ( APP_ECT_EN == 0 ) && ( BSP_CORE_TIMER_UNIT == BSP_CORE_TIMER_TC7 )
    #error "Core timer set to TC7, but ECT has not been enabled at application level (APP)"
#endif


/* check validity of SCI settings */
#if APP_SCI0_EN == 1
    #if BSP_SCI0_SUPP != 1
    #error SCI0 not available on chosen microcontroller.
    #endif
#endif
#if APP_SCI1_EN == 1
    #if BSP_SCI1_SUPP != 1
    #error SCI1 not available on chosen microcontroller.
    #endif
#endif
#if APP_SCI0_TIMEOUT_EN == 1
    #if BSP_SCI0_TIMEOUT_SUPP != 1
    #error Timeout support for SCI0 currently not configured in BSP library.
    #endif
#endif
#if APP_SCI1_TIMEOUT_EN == 1
    #if BSP_SCI1_TIMEOUT_SUPP != 1
    #error Timeout support for SCI1 currently not configured in BSP library.
    #endif
#endif


/* check validity of CAN settings */
#if APP_CAN0_EN == 1
    #if BSP_MSCAN0_SUPP != 1
    #error CAN0 not available on chosen microcontroller.
    #endif
#endif
#if APP_CAN1_EN == 1
    #if BSP_MSCAN1_SUPP != 1
    #error CAN1 not available on chosen microcontroller.
    #endif
#endif
#if APP_CAN2_EN == 1
    #if BSP_MSCAN2_SUPP != 1
    #error CAN2 not available on chosen microcontroller.
    #endif
#endif
#if APP_CAN3_EN == 1
    #if BSP_MSCAN3_SUPP != 1
    #error CAN3 not available on chosen microcontroller.
    #endif
#endif
#if APP_CAN4_EN == 1
    #if BSP_MSCAN4_SUPP != 1
    #error CAN4 not available on chosen microcontroller.
    #endif
#endif


#endif /* _APP_CFG_CHECK_H_ */
