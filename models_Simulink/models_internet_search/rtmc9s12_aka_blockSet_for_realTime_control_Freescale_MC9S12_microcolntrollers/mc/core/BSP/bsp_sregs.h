/*
 *********************************************************************************************************
 *
 * Microcontroller Special Function Registers
 *
 * (c) Frank Wörnle, 2010
 * 
 *********************************************************************************************************
 *
 * File              : bsp_sregs.h
 * Version           : 1.10
 * Last modification : 30.08.2010, fwoernle, extended to cover DG128 based targets
 *
 *********************************************************************************************************
 */
 
#ifndef _BSP_SREGS_H_
#define _BSP_SREGS_H_

/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */

/* 
 * Definition of all Special Function Registers (SFR, zero page) 
 */

/* Compiler: Metrowerks CodeWarrior */
#if CPL_COMPILER == CPL_METROWERKS_CW

#if      BSP_CPU == BSP_MC9S12DP256B
#include <mc9s12dp256.h>                              /* CPU: MC9S12DP256B                      */
#elif    BSP_CPU == BSP_MC9S12DG256
#include <mc9s12dg256.h>                              /* CPU: MC9S12DG256                       */
#elif    BSP_CPU == BSP_MC9S12C128
#include <mc9s12c128.h>                               /* CPU: MC9S12C128                        */
#elif    BSP_CPU == BSP_MC9S12C32
#include <mc9s12c32.h>                                /* CPU: MC9S12C32                         */
#elif    BSP_CPU == BSP_MC9S12DG128
#include <mc9s12dg128.h>                              /* CPU: MC9S12DG128                       */
#endif

#endif  /* === Metrowerks CodeWarrior === */


#endif  /* _BSP_SREGS_H_ */
