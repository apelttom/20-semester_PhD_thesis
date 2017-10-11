/*
 *********************************************************************************************************
 *
 * All controller specific includes
 *
 * (c) Frank Wörnle, 2008
 * 
 *********************************************************************************************************
 *
 * File              : bsp_includes.h
 * Version           : 1.00
 * Last modification : 17.05.2009, fwoernle, added compiler switch (CPL_METROWERKS_CW)
 *
 *********************************************************************************************************
 */
 
#ifndef _BSP_INCLUDES_H_
#define _BSP_INCLUDES_H_



/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */

#include "cpl.h"                                      /* define compiler to be used             */
#include <hidef.h>                                    /* common defines and macros              */
#include "bsp_cfg.h"                                  /* derivative information                 */
#include "bsp_dtypes.h"                               /* target specific data types             */

/* 
 * declaration of all Special Function Registers (SFR, zero page) 
 */
#include "bsp_sregs.h"



/*
 *********************************************************************************************************
 *    DEFINES
 *********************************************************************************************************
 */

/* 
 * missing special function register definitions 
 */

/* Compiler: Metrowerks CodeWarrior */
#if CPL_COMPILER == CPL_METROWERKS_CW

#if      BSP_CPU == BSP_MC9S12DP256B
#ifndef  BDMSTS
#define  BDMSTS             (*((tINT8U *)0xFF01))     /* BDM Status register                    */
#define  BDMSTS_CLKSW_MASK                   (4)      /* Bit mask for CLKSW in BDMSTS           */
#endif
#elif    BSP_CPU == BSP_MC9S12DG256
#ifndef  BDMSTS
#define  BDMSTS             (*((tINT8U *)0xFF01))     /* BDM Status register                    */
#define  BDMSTS_CLKSW_MASK                   (4)      /* Bit mask for CLKSW in BDMSTS           */
#endif
#elif    BSP_CPU == BSP_MC9S12DG256
#ifndef  BDMSTS
#define  BDMSTS             (*((tINT8U *)0xFF01))     /* BDM Status register                    */
#define  BDMSTS_CLKSW_MASK                   (4)      /* Bit mask for CLKSW in BDMSTS           */
#endif
#elif    BSP_CPU == BSP_MC9S12DG256
#ifndef  BDMSTS
#define  BDMSTS             (*((tINT8U *)0xFF01))     /* BDM Status register                    */
#define  BDMSTS_CLKSW_MASK                   (4)      /* Bit mask for CLKSW in BDMSTS           */
#endif
#elif    BSP_CPU == BSP_MC9S12C128
/* BDMSTS and BDMSTS_CLKSW_MASK are not defined for MC9S12C128 based targets  */
#elif    BSP_CPU == BSP_MC9S12C32
/* BDMSTS and BDMSTS_CLKSW_MASK are not defined for MC9S12C32 based targets   */
#elif    BSP_CPU == BSP_MC9S12DG128
/* BDMSTS and BDMSTS_CLKSW_MASK are not defined for MC9S12DG128 based targets */
#endif

#endif  /* CPL_METROWERKS_CW */



#endif /* _BSP_INCLUDES_H_ */
