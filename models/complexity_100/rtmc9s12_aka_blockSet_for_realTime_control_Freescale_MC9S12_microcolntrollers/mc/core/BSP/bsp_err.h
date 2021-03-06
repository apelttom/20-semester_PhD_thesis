/*
 *********************************************************************************************************
 *
 * Board Support Package - Error Memory
 *
 * (c) Frank W�rnle, 2009
 * 
 *********************************************************************************************************
 *
 * File              : bsp_err.h
 * Version           : 1.00
 * Author            : Frank W�rnle
 * Last modification : 18-Apr-2009 11:21:45, initial definition of error memory 
 *
 *********************************************************************************************************
 */
 
#ifndef _BSP_ERR_H_
#define _BSP_ERR_H_


/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */

#include "bsp_includes.h"                        /* all controler specific includes        */



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
 * SCI0 board support functions error memory 
 */
#if  BSP_SCI0_ERROR_SUPP == 1
extern tBOOLEAN        ErrMem_SCI0_RX_BUF_FULL;
extern tBOOLEAN        ErrMem_SCI0_TX_BUF_FULL;
#endif

/* 
 * SCI1 board support functions error memory 
 */
#if  BSP_SCI1_ERROR_SUPP == 1
extern tBOOLEAN        ErrMem_SCI1_RX_BUF_FULL;
extern tBOOLEAN        ErrMem_SCI1_TX_BUF_FULL;
#endif


/* 
 * RTI board support functions error memory 
 */
#if  BSP_RTI_ERROR_SUPP == 1
extern tBOOLEAN        ErrMem_RTI_OVERRUN;
#endif


/* 
 * ECT board support functions error memory 
 */
#if  BSP_ECT_ERROR_SUPP == 1
extern tBOOLEAN        ErrMem_ECT_OVERRUN;
#endif


/*
 *********************************************************************************************************
 *    DECLARATION OF PUBLIC FUNCTIONS
 *********************************************************************************************************
 */



/*
 *********************************************************************************************************
 *    ERROR CHECKING
 *********************************************************************************************************
 */



#endif /* _BSP_ERR_H_ */

