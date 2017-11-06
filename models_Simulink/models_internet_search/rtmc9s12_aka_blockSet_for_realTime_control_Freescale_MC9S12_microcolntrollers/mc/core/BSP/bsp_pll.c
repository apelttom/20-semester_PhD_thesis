/*
 *********************************************************************************************************
 *
 * Board Support Package PLL support functions
 *
 * (c) Frank Wörnle, 2009
 * 
 *********************************************************************************************************
 *
 * File              : bsp_pll.c
 * Version           : 1.00
 * Last modification : 01.06.2009, fwoernle, definition PLL support functions
 *
 *********************************************************************************************************
 */

/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */

#include "bsp_includes.h"                        /* all controler specific includes        */
#include "bsp_pll.h"                             /* PLL_BUSCLK, PLL_Init()                 */



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
 *********************************************************************************************************
 *    FUNCTION PROTOTYPES
 *********************************************************************************************************
 */



/*
 *********************************************************************************************************
 * Function      : PLL_Init()
 *
 * Description   : This function boosts the clock frequency of the crystal oscillator to the value of 
 *                 PLL_BUSCLK (max. PLL_BUSCLK_MAX)
 *                 PLL_Init() should always be called at the beginning of main().
 * Arguments     : none
 * Return values : none
 * Comment       : function will block when the PLL does not stabilize
 *********************************************************************************************************
 */

tVOID PLL_Init(tVOID) {

tINT8U  cDesBusClk = PLL_BUSCLK;
tINT8U  cRefDiv    = 1;
tINT8U  cMult      = 1;


  /* Avoid MC9S12DP256B BDM Looses Sync errata when PLL on    */
  /* This errata can be avoided by not using a const clk src  */
  #if (BSP_CPU == BSP_MC9S12DP256B) || (BSP_CPU == BSP_MC9S12DG256)
  BDMSTS |=   BDMSTS_CLKSW_MASK;                                      
  #endif
  
  /*
   * Determine numerator and denominator of the PLLCLK equation:
   * PLLCLK = 2 * OSCCLK * (SYNR + 1) / (REFDV + 1)
     * (OSCCLK is the resonance frequency of the crystal oscillator circuit)
     */
  for( ; (cDesBusClk % (BSP_OSC_FREQ_MHZ / cRefDiv)) && (cRefDiv < 16) ; cRefDiv++);
  for( ; (cMult * BSP_OSC_FREQ_MHZ / cRefDiv < PLL_BUSCLK) && (cMult < 64) ; cMult++);

  /* program PLLCLK equation */
  REFDV = cRefDiv - 1;
  SYNR  = cMult   - 1;
  
  /*
   * set up CLKSEL:
   * Bit 7: PLLSEL = 0 Keep using OSCCLK until we are ready to switch to PLLCLK
   * Bit 6: PSTP   = 0 Do not need to go to Pseudo-Stop Mode
   * Bit 5: SYSWAI = 0 In wait mode system clocks stop.
   * Bit 4: ROAWAI = 0 Do not reduce oscillator amplitude in wait mode.
   * Bit 3: PLLWAI = 0 Do not turn off PLL in wait mode
   * Bit 2: CWAI   = 0 Do not stop the core during wait mode
   * Bit 1: RTIWAI = 0 Do not stop the RTI in wait mode
   * Bit 0: COPWAI = 0 Do not stop the COP in wait mode
   */
  CLKSEL = 0x00;
  
  /*
   * set up PLLCTL:
   * Bit 7: CME   = 1; Clock monitor enable - reset if bad clock when set
   * Bit 6: PLLON = 1; PLL On bit
   * Bit 5: AUTO  = 1; Automatic control of bandwidth, manual through ACQ
   * Bit 4: ACQ   = 0; 1 for high bandwidth filter (acquisition); 0 for low (tracking)
   * Bit 3:            (Not Used by 9s12c32)
   * Bit 2: PRE   = 0; RTI stops during Pseudo Stop Mode
   * Bit 1: PCE   = 0; COP diabled during Pseudo STOP mode
   * Bit 0: SCME  = 1; Crystal Clock Failure -> Self Clock mode NOT reset.
   */
  //PLLCTL = 0xC0;
  PLLCTL = 0xE1;
  
  /* wait for PLL to lock in (note: potential to be blocking!) */
  while(CRGFLG_LOCK != 1) {
      /* do nothing */
  }
  
  /* switch to PLL clock */
  CLKSEL_PLLSEL = 1;

}
