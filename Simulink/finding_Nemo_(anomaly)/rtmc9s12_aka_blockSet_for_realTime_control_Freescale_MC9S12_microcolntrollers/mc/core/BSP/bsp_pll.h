/*
 *********************************************************************************************************
 *
 * Board Support Package PLL support functions
 *
 * (c) Frank Wörnle, 2009
 * 
 *********************************************************************************************************
 *
 * File              : bsp_pll.h
 * Version           : 1.00
 * Last modification : 01.06.2009, fwoernle, public export of PLL support functions
 *
 *********************************************************************************************************
 */
 
#ifndef _PLL_H_
#define _PLL_H_



/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */

#include "bsp_includes.h"                             /* all controler specific includes          */



/*
 *********************************************************************************************************
 *    Desired bus clock speed PLL_BUSCLK (can range from 0.5*BSP_OSC_FREQ_MHZ to PLL_BUSCLK_MAX)
 *********************************************************************************************************
 */
 
/*
 * Example: Dragon12 (MC9S12DP256B)
 * PLL off  (crystal) -> SYSCLK =  4 MHz  -> PLL_BUSCLK = 2 MHz
 * PLL on             -> SYSCLK = 48 MHz  -> PLL_BUSCLK = 24 MHz
 */
#define  PLL_BUSCLK                         24
#define  PLL_BUSCLK_MAX                     25



/*
 *********************************************************************************************************
 *    DECLARATION OF PUBLIC FUNCTIONS
 *********************************************************************************************************
 */

extern tVOID PLL_Init(tVOID);



/*
 *********************************************************************************************************
 *    ERROR CHECKING
 *********************************************************************************************************
 */

#if   ((PLL_BUSCLK < 0.5*BSP_OSC_FREQ_MHZ) || (PLL_BUSCLK > PLL_BUSCLK_MAX))
#error "PLL_BUSCLK is illegally defined in pll.h. Admissible values range from '0.5*BSP_OSC_FREQ_MHZ' to 'PLL_BUSCLK_MAX' MHz"
#endif



#endif /* _PLL_H_ */
