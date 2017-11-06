/*
 *********************************************************************************************************
 *
 * Compiler pragma configuration file
 *
 * (c) Frank Wörnle, 2010
 * 
 *********************************************************************************************************
 *
 * File              : cpl_pragma.h
 * Version           : 1.00
 * Last modification : 30.05.2010, fwoernle, initial header file
 *
 *********************************************************************************************************
 */
 


/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */

#include "cpl.h"                            /* CPL_COMPILER                    */



/*
 *********************************************************************************************************
 *    Compiler information
 *********************************************************************************************************
 */

#if CPL_COMPILER == CPL_METROWERKS_CW

/* 
 * === define special keywords for Metrowerks CodeWarrior ===
 */


/*
 * inline functions -----------------------------------------
 */
 
/* begin inline function definition */
#ifdef CPL_PRAGMA_INLINE_START
    #pragma INLINE
    #undef CPL_PRAGMA_INLINE_START
#endif

/* end inline function definition */
#ifdef CPL_PRAGMA_INLINE_STOP
    #undef CPL_PRAGMA_INLINE_STOP
#endif


/*
 * code sections --------------------------------------------
 */
 
/* begin interrupt service routine section */
#ifdef CPL_PRAGMA_ISR_START
    #pragma CODE_SEG __NEAR_SEG NON_BANKED 
    #undef CPL_PRAGMA_ISR_START
#endif

/* end interrupt service routine section */
#ifdef CPL_PRAGMA_ISR_STOP
    #pragma CODE_SEG DEFAULT
    #undef CPL_PRAGMA_ISR_STOP
#endif


#else   /* CPL_COMPILER */


/* 
 * ================= all other compilers ====================
 */


/*
 * inline functions -----------------------------------------
 */
/* start inline function definition */
#ifdef CPL_PRAGMA_INLINE_START
    /* do nothing */
    #undef CPL_PRAGMA_INLINE_START
#endif

/* end inline function definition */
#ifdef CPL_PRAGMA_INLINE_STOP
    /* do nothing */
    #undef CPL_PRAGMA_INLINE_STOP
#endif


/*
 * code sections --------------------------------------------
 */
 
/* begin interrupt service routine section */
#ifdef CPL_PRAGMA_ISR_START
    /* do nothing */
    #undef CPL_PRAGMA_ISR_START
#endif

/* end interrupt service routine section */
#ifdef CPL_PRAGMA_ISR_STOP
    /* do nothing */
    #undef CPL_PRAGMA_ISR_STOP
#endif


#endif  /* CPL_COMPILER */
