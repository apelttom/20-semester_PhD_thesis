/******************************************************************************/
/*                                                                            */
/* Auxilliary functions, signalling of error codes                            */
/*                                                                            */
/* Author: F. Wornle (FW-mn-yr)                                               */
/* Latest change: FW-05-08                                                    */
/*                                                                            */
/******************************************************************************/

#ifndef _MC_SIGNAL_
#define _MC_SIGNAL_

extern void    wait(void);
extern void    blinky(unsigned long i);
extern void    sigLED (int ErrorNumber);
extern void    displayDigit(int dig);
extern void    dispLCD_uint(unsigned int n, const char *myText, int line);
extern void    abort_LED (int ErrorNumber);

#endif /* _MC_SIGNAL_ */
