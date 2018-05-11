/******************************************************************************/
/* mc_main.h : header file to mc_main.c     --   fw-02-05                     */
/******************************************************************************/

#ifndef    _MC_MAIN_
#define    _MC_MAIN_

extern void model_run(void);        /* called by the timer_ISR (mc_timer.c) */

extern unsigned int reInitMemory;   /* used by 'ExtModeMalloc' (mem_mgr.c) */

#endif    /* _MC_MAIN_ */
