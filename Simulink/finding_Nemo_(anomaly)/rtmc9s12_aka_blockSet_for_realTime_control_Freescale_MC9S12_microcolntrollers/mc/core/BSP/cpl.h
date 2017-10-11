/*
 *********************************************************************************************************
 *
 * Compiler configuration file
 *
 * (c) Frank Wörnle, 2009
 * 
 *********************************************************************************************************
 *
 * File              : cpl.h
 * Version           : 1.00
 * Last modification : 17.05.2009, fwoernle, initial header file
 *
 *********************************************************************************************************
 */
 
#ifndef _CPL_H_
#define _CPL_H_



/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */



/*
 *********************************************************************************************************
 *    Compiler information
 *********************************************************************************************************
 */

#define  CPL_METROWERKS_CW                  1                        /* Metrowerks CodeWarrior                 */
#define  CPL_GNU_GCC                        2                        /* GNU GCC (not yet supported, fw-05-09)  */

/* define Compiler */
#define  CPL_COMPILER                       CPL_METROWERKS_CW        /* Metrowerks CodeWarrior                 */



/* 
 * === define special keywords for Metrowerks CodeWarrior ===
 */
#if CPL_COMPILER == CPL_METROWERKS_CW

/* inline assembly */
#define  CPL_IL_ASM                         asm

/* interrupts */
#define  CPL_INTERRUPT                      __interrupt

#define  CPL_ENABLE_IRQS                    asm cli
#define  CPL_DISABLE_IRQS                   asm sei


#endif  /* === Metrowerks CodeWarrior === */



/*
 *********************************************************************************************************
 *    ERROR CHECKING
 *********************************************************************************************************
 */

#if   ((CPL_COMPILER < 0) || (CPL_COMPILER > 1))
#error "CPL_COMPILER is incorrectly defined in CPL.h. Admissible values: 1"
#endif



#endif /* _CPL_H_ */
