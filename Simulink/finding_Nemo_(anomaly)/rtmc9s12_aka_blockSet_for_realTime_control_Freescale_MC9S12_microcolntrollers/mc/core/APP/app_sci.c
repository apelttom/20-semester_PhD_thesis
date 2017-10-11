/*
 *********************************************************************************************************
 *
 * SCI support functions, application dependent part, configured in "app_cfg.h" (& bsp_cfg.h)
 *
 * (c) Frank Wörnle, 2010
 * 
 *********************************************************************************************************
 *
 * File              : app_sci.c
 * Version           : 1.10
 * Last modification : 11.04.2010, Frank Wörnle, adapted for rtmc9s12-target
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


/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */

#include "bsp_includes.h"                        /* all controller specific includes         */
#include "bsp_pll.h"                             /* PLL_BUSCLK                               */
#include "bsp_rBuf.h"                            /* ring buffer support                      */
#include "bsp_sci.h"                             /* communication macros                     */
#include "bsp_rti.h"                             /* SCI0_TimeoutInit(), SCI1_TimeoutInit()   */
#include "bsp_err.h"                             /* error memory support                     */

#include "app_cfg.h"                             /* application specific configurations      */


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
 *    MODULE GLOBAL VARIABLES
 *********************************************************************************************************
 */

/* RX ring buffer ('inbuf') */
#if APP_SCI0_RX_ISR == 1

/* define i/p ring buffer control structure */
static rbAdminStructType  adminStruct_SCI0inBuf;

/* define i/p ring buffer */
static tINT8U   SCI0inBuf[APP_SCI0_RB_RX_BUF_SIZE];

#endif

/* TX ring buffer ('outbuf') */
#if APP_SCI0_TX_ISR == 1

/* define o/p ring buffer control structure */
static rbAdminStructType  adminStruct_SCI0outBuf;

/* define o/p ring buffer */
static tINT8U   SCI0outBuf[APP_SCI0_RB_TX_BUF_SIZE];

#endif


/* RX ring buffer ('inbuf') */
#if APP_SCI1_RX_ISR == 1

/* define i/p ring buffer control structure */
static rbAdminStructType  adminStruct_SCI1inBuf;

/* define i/p ring buffer */
static tINT8U   SCI1inBuf[APP_SCI1_RB_RX_BUF_SIZE];

#endif

/* TX ring buffer ('outbuf') */
#if APP_SCI1_TX_ISR == 1

/* define o/p ring buffer control structure */
static rbAdminStructType  adminStruct_SCI1outBuf;

/* define o/p ring buffer */
static tINT8U   SCI1outBuf[APP_SCI1_RB_TX_BUF_SIZE];

#endif



/*
 *********************************************************************************************************
 *    FUNCTION PROTOTYPES
 *********************************************************************************************************
 */



/*
 *********************************************************************************************************
 *    LOCAL FUNCTIONS
 *********************************************************************************************************
 */


/* using SCI0 as FreePort or ML port? */
#if SCI0_COMMS != idle

/*
 *********************************************************************************************************
 * Function      : Interrupt handler for RX and TX on SCI0
 *
 * Description   : upon the reception of a characters on SCI0, the character is stored in the (statically) 
 *                 global reception ring buffer. During the transmission of a character on SCI0, the 
 *                 character is fetched from the (statically) global transmission ring buffer and sent on SCI0.
 * Arguments     : none (ISR)
 * Return values : none (ISR)
 * Error memory  : ErrMem_SCI0_RX_BUF_FULL
 *********************************************************************************************************
 */

/* External Mode via SCI0 */
#if  APP_SCI0_ISR == 1

#define CPL_PRAGMA_ISR_START
#include "cpl_pragma.h"

CPL_INTERRUPT void SCI0_isr(void) {

    /* set sertime_pin high (timing -> scope) */
    #ifdef TIMING
    setSerTiPin;
    #endif


    /* transmission (TX) */
    #if APP_SCI0_TX_ISR == 1
    if((SCISR1 & SCISR1_TDRE_MASK) != 0) {
        
        /* Transmission Data Register Empty (TDRE) */
        
        /* disable SCI0 interrupt (TX) to avoid preemption then re-enable all interrupts */
        #if APP_SCI0_ISR_REENTRANT == 1
        InterruptDisable_SCI0_TX;
        CPL_ENABLE_IRQS;
        #endif
        
        /* -> send next byte... */
        if (!RB_EMPTY(&adminStruct_SCI0outBuf)) {
            
            /* initiate transmission of next character */
            SCIDRL = *RB_POPSLOT(&adminStruct_SCI0outBuf);
            
            /* remove the sent character from the ring buffer */
            RB_POPADVANCE(&adminStruct_SCI0outBuf);
            
            /* adjust number of elements currently held in the buffer */
            RB_DEC(&adminStruct_SCI0outBuf);
            
            /* provide some visual feedback */
            #if APP_SCI0_ISR_TX_LED == 1
            PORTB ^= 0x02;
            #endif
            
            /* re-enable SCI0 interrupts (TX) to continue transmission */
            #if APP_SCI0_ISR_REENTRANT == 1
            InterruptEnable_SCI0_TX;
            #endif

        } else {
            
            /* buffer empty -> disable TX interrupt, otherwise the system 'hangs' (continous interrupts) */
            InterruptDisable_SCI0_TX;
            
        }
        
    }
    #endif  /* APP_SCI0_TX_ISR */


    /* reception (RX) */
    #if APP_SCI0_RX_ISR == 1
    if ((SCISR1 & SCISR1_RDRF_MASK) != 0) {
        
        /* Reception Data Register Full (RDRF) */
        
        /* disable SCI1 interrupt (RX) to avoid preemption then re-enable all interrupts */
        #if APP_SCI0_ISR_REENTRANT == 1
        InterruptDisable_SCI0_RX;
        CPL_ENABLE_IRQS;
        #endif

        /* -> fetch character and store */
        if (!RB_FULL(&adminStruct_SCI0inBuf)) {
            
            /* store the value of SCI0DRL in the ring buffer */
            *RB_PUSHSLOT(&adminStruct_SCI0inBuf) = SCIDRL;
            
            /* adjust rb_in to next write position */
            RB_PUSHADVANCE(&adminStruct_SCI0inBuf);
            
            /* adjust number of elements currently held in the buffer */
            RB_INC(&adminStruct_SCI0inBuf);
            
        } else {
            
            /* buffer full -> indicate this condition in the error memory */
            #if BSP_SCI0_ERROR_SUPP == 1
            ErrMem_SCI0_RX_BUF_FULL = TRUE;
            #endif
            
        }
        
        /* provide some visual feedback */
        #if APP_SCI0_ISR_RX_LED == 1
        PORTB ^= 0x01;
        #endif
        
        /* re-enable SCI0 interrupts (RX) */
        #if APP_SCI0_ISR_REENTRANT == 1
        InterruptEnable_SCI0_RX;
        #endif

    }
    #endif  /* APP_SCI0_RX_ISR */


    /* reset sertime_pin (timing -> scope) */
    #ifdef TIMING
    clrSerTiPin;
    #endif

} /* SCI0_isr */

#define CPL_PRAGMA_ISR_STOP
#include "cpl_pragma.h"

#endif  /* APP_SCI0_ISR */

#endif  /* SCI0_COMMS != idle */



/* using SCI1 as FreePort or ML port? */
#if SCI1_COMMS != idle

/*
 *********************************************************************************************************
 * Function      : Interrupt handler for RX and TX on SCI1
 *
 * Description   : upon the reception of a characters on SCI1, the character is stored in the (statically) 
 *                 global reception ring buffer. During the transmission of a character on SCI1, the 
 *                 character is fetched from the (statically) global transmission ring buffer and sent on SCI1.
 * Arguments     : none (ISR)
 * Return values : none (ISR)
 * Error memory  : ErrMem_SCI1_RX_BUF_FULL
 *********************************************************************************************************
 */

/* External Mode via SCI1 */
#if  APP_SCI1_ISR == 1

#define CPL_PRAGMA_ISR_START
#include "cpl_pragma.h"
CPL_INTERRUPT void SCI1_isr(void) {

    /* set sertime_pin high (timing -> scope) */
    #ifdef TIMING
    setSerTiPin;
    #endif


    /* transmission (TX) */
    #if APP_SCI1_TX_ISR == 1
    if((SCI1SR1 & SCI1SR1_TDRE_MASK) != 0) {
        
        /* Transmission Data Register Empty (TDRE) */
        
        /* disable SCI1 interrupt (TX) to avoid preemption then re-enable all interrupts */
        #if APP_SCI1_ISR_REENTRANT == 1
        InterruptDisable_SCI1_TX;
        CPL_ENABLE_IRQS;
        #endif
        
        /* -> send next byte... */
        if (!RB_EMPTY(&adminStruct_SCI1outBuf)) {
            
            /* initiate transmission of next character */
            SCI1DRL = *RB_POPSLOT(&adminStruct_SCI1outBuf);
            
            /* remove the sent character from the ring buffer */
            RB_POPADVANCE(&adminStruct_SCI1outBuf);
            
            /* adjust number of elements currently held in the buffer */
            RB_DEC(&adminStruct_SCI1outBuf);

            /* provide some visual feedback */
            #if APP_SCI1_ISR_TX_LED == 1
            PORTB ^= 0x08;
            #endif
            
            /* re-enable SCI1 interrupts (TX) to continue transmission */
            #if APP_SCI1_ISR_REENTRANT == 1
            InterruptEnable_SCI1_TX;
            #endif

            /* done with TX -> skip RX - needs triggered separately! */
            goto EXIT_POINT;

        } else {
            
            /* buffer empty -> disable TX interrupt, otherwise the system 'hangs' (continous interrupts) */
            InterruptDisable_SCI1_TX;
            
        }

    }
    #endif  /* APP_SCI1_TX_ISR */


    /* reception (RX) */
    #if APP_SCI1_RX_ISR == 1
    if ((SCI1SR1 & SCI1SR1_RDRF_MASK) != 0) {
        
        /* Reception Data Register Full (RDRF) */
        
        /* disable SCI1 interrupt (RX) to avoid preemption then re-enable all interrupts */
        #if APP_SCI1_ISR_REENTRANT == 1
        InterruptDisable_SCI1_RX;
        CPL_ENABLE_IRQS;
        #endif

        /* -> fetch character and store */
        if (!RB_FULL(&adminStruct_SCI1inBuf)) {
            
            /* store the value of SCI1DRL in the ring buffer */
            *RB_PUSHSLOT(&adminStruct_SCI1inBuf) = SCI1DRL;
            
            /* adjust rb_in to next write position */
            RB_PUSHADVANCE(&adminStruct_SCI1inBuf);
            
            /* adjust number of elements currently held in the buffer */
            RB_INC(&adminStruct_SCI1inBuf);
            
        } else {
            
            /* buffer full -> indicate this condition in the error memory */
            #if BSP_SCI1_ERROR_SUPP == 1
            ErrMem_SCI1_RX_BUF_FULL = TRUE;
            #endif
            
        }
        
        /* provide some visual feedback */
        #if APP_SCI1_ISR_RX_LED == 1
        PORTB ^= 0x04;
        #endif
        
        /* re-enable SCI1 interrupts (RX) */
        #if APP_SCI1_ISR_REENTRANT == 1
        InterruptEnable_SCI1_RX;
        #endif

    }
    #endif  /* APP_SCI1_RX_ISR */


EXIT_POINT:

    /* need to do something at the EXIT_POINT to keep the compiler happy... */
    asm nop;

    /* reset sertime_pin (timing -> scope) */
    #ifdef TIMING
    clrSerTiPin;
    #endif

} /* SCI1_isr */

#define CPL_PRAGMA_ISR_STOP
#include "cpl_pragma.h"

#endif  /* APP_SCI1_ISR */

#endif  /* SCI0_COMMS != idle */




/*
 *********************************************************************************************************
 *    PUBLIC FUNCTIONS
 *********************************************************************************************************
 */



/*
 *********************************************************************************************************
 *    Serial Communication Interface SCI0
 *********************************************************************************************************
 */

#if APP_SCI0_EN == 1

/*
 *********************************************************************************************************
 * Function      : SCI0_Init()
 *
 * Description   : This function initializes the first Serial Communication Interface (SCI0)
 * Arguments     : baudrate specifier (as per sci.h)
 * Return values : none
 *********************************************************************************************************
 */

tVOID SCI0_Init(tINT8U baudRate) {

tINT32U  BR = (PLL_BUSCLK * 1000000) >> 4;       /* /16 */

    /* determine baud rate factor */
    switch(baudRate) {
    
        case BAUD_300:
            
            /* @ 24 MHz : 300 bps -> SCIBDH =  19 */
            /* @ 24 MHz : 300 bps -> SCIBDL = 136 */
            BR = BR / 300;
            break;
        
        case BAUD_600:
            
            /* @ 24 MHz : 600 bps -> SCIBDH =   9 */
            /* @ 24 MHz : 600 bps -> SCIBDL = 196 */
            BR = BR / 600;
            break;
            
          case BAUD_1200:
            
            /* @ 24 MHz : 1200 bps -> SCIBDH =   4 */
            /* @ 24 MHz : 1200 bps -> SCIBDL = 226 */
            BR = BR / 1200;
            break;
        
          case BAUD_2400:
            
            /* @ 24 MHz : 2400 bps -> SCIBDH =   2 */
            /* @ 24 MHz : 2400 bps -> SCIBDL = 113 */
            BR = BR / 2400;
            break;

          case BAUD_4800:
            
            /* @ 24 MHz : 4800 bps -> SCIBDH =   1 */
            /* @ 24 MHz : 4800 bps -> SCIBDL =  56 */
            BR = BR / 4800;
            break;
            
          case BAUD_9600:
            
            /* @ 24 MHz : 9600 bps -> SCIBDH =   0 */
            /* @ 24 MHz : 9600 bps -> SCIBDL = 156 */
            BR = BR / 9600;
            break;

          case BAUD_19200:
            
            /* @ 24 MHz : 19200 bps -> SCIBDH =   0 */
            /* @ 24 MHz : 19200 bps -> SCIBDL =  78 */
            BR = BR / 19200;
            break;

          case BAUD_38400:
            
            /* @ 24 MHz : 38400 bps -> SCIBDH =   0 */
            /* @ 24 MHz : 38400 bps -> SCIBDL =  39 */
            BR = BR / 38400;
            break;

          case BAUD_57600:
            
            /* @ 24 MHz : 57600 bps -> SCIBDH =   0 */
            /* @ 24 MHz : 57600 bps -> SCIBDL =  26 */
            BR = BR / 57600;
            break;

          case BAUD_115200:
            
            /* @ 24 MHz : 115200 bps -> SCIBDH =   0 */
            /* @ 24 MHz : 115200 bps -> SCIBDL =  13 */
            BR = BR / 115200;
            break;
            
    } /* switch */
  
    /* set baud rate registers */
    SCIBDH = (tINT8U)(BR / 256);
    SCIBDL = (tINT8U)(BR % 256);
    
    /* 
     * SCICR1:
     * 7   0    LOOPS, no looping, normal
     * 6   0    WOMS, normal high/low outputs
     * 5   0    RSRC, not appliable with LOOPS=0
     * 4   0    M, 1 start, 8 data, 1 stop
     * 3   0    WAKE, wake by idle (not applicable)
     * 2   0    ILT, short idle time (not applicable)
     * 1   0    PE, no parity
     * 0   0    PT, parity type (not applicable with PE=0)
     */ 
    SCICR1 = 0;

    #if APP_SCI0_ISR == 0
    
    /* not using ring buffers on SCI0 */
    
    /* 
     * SCICR2:
     * 7   0    TIE, no transmit interrupts on TDRE
     * 6   0    TCIE, no transmit interrupts on TC
     * 5   0    RIE, no receive interrupts on RDRF
     * 4   0    ILIE, no interrupts on idle
     * 3   1    TE, enable transmitter
     * 2   1    RE, enable receiver
     * 1   0    RWU, no receiver wakeup
     * 0   0    SBK, no send break
     */ 
    SCICR2 = 0x0C; 
    
    #elif (APP_SCI0_RX_ISR == 1) && (APP_SCI0_TX_ISR == 0)

    /* using RX ring buffer (only) on SCI0 */

    /* 
     * SCICR2:
     * 7   0    TIE, no transmit interrupts on TDRE
     * 6   0    TCIE, no transmit interrupts on TC 
     * 5   1    RIE, receive interrupts on RDRF (always active)
     * 4   0    ILIE, no interrupts on idle
     * 3   1    TE, enable transmitter
     * 2   1    RE, enable receiver
     * 1   0    RWU, no receiver wakeup
     * 0   0    SBK, no send break
     */ 
    SCICR2 = 0x2C;

    /* set up input ring buffer */
    RB_INIT(&adminStruct_SCI0inBuf,  SCI0inBuf,  APP_SCI0_RB_RX_BUF_SIZE);            /* set up RX ring buffer */
    
    #elif (APP_SCI0_RX_ISR == 0) && (APP_SCI0_TX_ISR == 1)

    /* using TX ring buffer (only) on SCI0 */

    /* 
     * SCICR2:
     * 7   0    TIE, no transmit interrupts on TDRE (bit will be set/reset on demand by the TX functions)
     * 6   0    TCIE, no transmit interrupts on TC 
     * 5   0    RIE, no receive interrupts on RDRF
     * 4   0    ILIE, no interrupts on idle
     * 3   1    TE, enable transmitter
     * 2   1    RE, enable receiver
     * 1   0    RWU, no receiver wakeup
     * 0   0    SBK, no send break
     */ 
    SCICR2 = 0x0C;

    /* set up output ring buffer */
    RB_INIT(&adminStruct_SCI0outBuf, SCI0outBuf, APP_SCI0_RB_TX_BUF_SIZE);            /* set up TX ring buffer */
    
    #else

    /* using RX and TX ring buffers on SCI0 */

    /* 
     * SCICR2:
     * 7   0    TIE, no transmit interrupts on TDRE (bit will be set/reset on demand by the TX functions)
     * 6   0    TCIE, no transmit interrupts on TC 
     * 5   1    RIE, receive interrupts on RDRF (always active)
     * 4   0    ILIE, no interrupts on idle
     * 3   1    TE, enable transmitter
     * 2   1    RE, enable receiver
     * 1   0    RWU, no receiver wakeup
     * 0   0    SBK, no send break
     */ 
    SCICR2 = 0x2C;

    /* set up input and output ring buffers */
    RB_INIT(&adminStruct_SCI0inBuf,  SCI0inBuf,  APP_SCI0_RB_RX_BUF_SIZE);            /* set up RX ring buffer */
    RB_INIT(&adminStruct_SCI0outBuf, SCI0outBuf, APP_SCI0_RB_TX_BUF_SIZE);            /* set up TX ring buffer */
    
    #endif  /* APP_SCI0_ISR */

    /* setup target sided timeout mechanism for SCI0 */
    #if BSP_SCI0_TIMEOUT_SUPP == 1
    SCI0_TimeoutInit((tFP32)APP_SCI0_TIMEOUT_SEC);
    #endif

}



/*
 *********************************************************************************************************
 * Function      : SCI0_InChar()
 *
 * Description   : Wait for next character on SCI0
 * Arguments     : pointer to the character to be returned
 * Return values : indicator of failure (-1) or success (0)
 * Comment       : function fetches a character from the input ring buffer (if used) and returns. If timeouts
 *                 are enabled, the function waits for a character to be received or a timeout to occurr, i. e.
 *                 the function returns after at most 'BSP_SCI0_TIMEOUT_MAX_SEC' seconds. If the timeout 
 *                 mechanism is inactive, (RTI not enabled) the function is blocking.
 *********************************************************************************************************
 */

tINT16S SCI0_InChar(tINT8U *cRet) {

    #if APP_SCI0_RX_ISR == 0
    
    /* not using RX ring buffer on SCI0 / not using ISR driven RX */
    
    /* reset SCI0 timeout counter */
    #if APP_SCI0_TIMEOUT_EN == 1
    resetTimeoutCounterSCI0();
    #endif

    /* wait for new character to arrive or timeout */
    while ((SCISR1 & SCISR1_RDRF_MASK) == 0) {
    
        /* has a timeout occurred? */
        #if APP_SCI0_TIMEOUT_EN == 1
        if (timeoutSCI0()) {
        
            /* yes -> signal failure */
            return -1;
            
        }
        #endif
        
    }
    
    /* -- if we reach this point, the character to be read has been received -- */

    /* return received character */
    *cRet = (tINT8U)SCIDRL;
    
    /* indicate success */
    return 0;
    

    #else

    
    /* using RX ring buffer on SCI0 / ISR driven RX */
    
    /* reset SCI0 timeout counter */
    #if APP_SCI0_TIMEOUT_EN == 1
    resetTimeoutCounterSCI0();
    #endif

    /* 
     * wait until there's at least one character in the ring buffer or until at SCI0 timeout has
     * occurred. If the timeout mechanism is not active, this call is blocking.
     */
    while (RB_POP(&adminStruct_SCI0inBuf, cRet) == -1) {

        /* has a timeout occurred? */
        #if APP_SCI0_TIMEOUT_EN == 1
        if (timeoutSCI0()) {
        
            /* yes -> signal failure */
            return -1;
            
        }
        #endif
        
    }


    /* -- if we reach this point, the character to be read has been fetched from the RX ring buffer -- */

    /* signal success */
    return 0;

    #endif  /* APP_SCI0_RX_ISR */

}



/*
 *********************************************************************************************************
 * Function      : SCI0_OutChar()
 *
 * Description   : Transmit next character on SCI0
 * Arguments     : character to be transmitted
 * Return values : indicator of failure (-1) or success (0)
 * Comment       : function stores the character to be transmitted on the output ring buffer (if used) and 
 *                 returns. If the timeout mechanism is active (RTI enabled), the function will return after 
 *                 at most 'BSP_SCI0_TIMEOUT_MAX_SEC' seconds. If the timeout mechanism is inactive, 
 *                 (RTI not enabled) the function is blocking.
 * Error memory  : ErrMem_SCI0_TX_BUF_FULL
 *********************************************************************************************************
 */

tINT16S SCI0_OutChar(tINT8U transData) {

    #if APP_SCI0_TX_ISR == 0
    
    /* not using TX ring buffer on SCI0 / not using ISR driven TX */
    
    /* reset SCI0 timeout counter */
    #if APP_SCI0_TIMEOUT_EN == 1
    resetTimeoutCounterSCI0();
    #endif

    /* wait for ongoing transmission to finish or a timeout */
    while ((SCISR1 & SCISR1_TDRE_MASK) == 0) {
        
        /* has a timeout occurred? */
        #if APP_SCI0_TIMEOUT_EN == 1
        if (timeoutSCI0()) {
            
            /* yes -> signal failure */
            #if BSP_SCI0_ERROR_SUPP == 1
            ErrMem_SCI0_TX_BUF_FULL = TRUE;
            #endif
            
            return -1;
            
        }
        #endif
        
    }
    
    /* -- if we reach this point, there the TX data register is empty -- */

    /* send next character */
    SCIDRL = transData;

    /* signal success */
    return 0;

    
    #else
    

    /* using TX ring buffer on SCI0 / ISR driven TX */

    /* reset SCI0 timeout counter */
    #if APP_SCI0_TIMEOUT_EN == 1
    resetTimeoutCounterSCI0();
    #endif

    /* 
     * wait until there's space in the ring buffer or until at SCI0 timeout has
     * occurred. If the timeout mechanism is not active, this call is blocking.
     */
    while (RB_FULL(&adminStruct_SCI0outBuf)) {
        
        /* has a timeout occurred? */
        #if APP_SCI0_TIMEOUT_EN == 1
        if (timeoutSCI0()) {
            
            /* yes -> signal failure */
            #if BSP_SCI0_ERROR_SUPP == 1
            ErrMem_SCI0_TX_BUF_FULL = TRUE;
            #endif
            
            return -1;
            
        }
        #endif
        
    }


    /* -- if we reach this point, there is space on the TX ring buffer -- */

    /* place character to be sent in the buffer */
    *RB_PUSHSLOT(&adminStruct_SCI0outBuf) = transData;

    /* set write position for the next character to be sent */
    RB_PUSHADVANCE(&adminStruct_SCI0outBuf);

    /* adjust number of bytes held in the SCI0 TX buffer */
    RB_INC(&adminStruct_SCI0outBuf);

    /* (re-)enable transmission interrupt to send character */ 
    InterruptEnable_SCI0_TX;

    /* signal success */
    return 0;

    #endif  /* APP_SCI0_TX_ISR */

}



/*
 *********************************************************************************************************
 * Function      : SCI0_InStatus()
 *
 * Description   : Determine how many new characters have arrived
 * Arguments     : none
 * Return values : number of available characters
 *********************************************************************************************************
 */

tINT16U SCI0_InStatus(tVOID) {

    #if APP_SCI0_RX_ISR == 0
    
    /* not using RX ring buffer on SCI0 / not using ISR driven RX */
    
    /* determine if the reception data register is full (RDRF)*/
    if ((SCISR1 & SCISR1_RDRF_MASK) == SCISR1_RDRF_MASK) {
        
        /* a byte has arrived */
        return 1;
        
    } else {
        
        /* nothing has arrived yet */
        return 0;
        
    }

    #else
    
    /* using RX ring buffer on SCI0 / ISR driven RX */
    
    /* return number of elements in the buffer */
    return RB_ELEMENTS(&adminStruct_SCI0inBuf);
    
    #endif  /* APP_SCI0_RX_ISR */
    
}



/*
 *********************************************************************************************************
 * Function      : SCI0_InBufferPeek()
 *
 * Description   : Peek at values on the reception buffer without removing them
 * Arguments     : pointer to return value (cRet), 
 *                 offset to be added to the tail before reading (*tailOffset)
 * Return values : number of available characters
 *********************************************************************************************************
 */

tINT16U SCI0_InBufferPeek(tINT8U *cRet, tINT16U *tailOffset) {

    #if APP_SCI0_RX_ISR == 0
    
    /* not using RX ring buffer on SCI0 / not using ISR driven RX */
    
    /* determine if the reception data register is full (RDRF)*/
    if ((SCISR1 & SCISR1_RDRF_MASK) == SCISR1_RDRF_MASK) {
        
        /* return the received byte */
        *cRet = (tINT8U)SCIDRL;
        
        /* set tailOffset to '0' (not using a buffer here) */
        *tailOffset = 0;
        
        /* indicate that 'one byte is available' for collection */
        return 1;
        
    } else {
        
        /* nothing has arrived yet */
        return 0;
        
    }

    #else
    
    /* using RX ring buffer on SCI0 / ISR driven RX */
    
    /* return number of elements in the buffer */
    return RB_PEEK(&adminStruct_SCI0inBuf, cRet, tailOffset);
    
    #endif  /* APP_SCI0_RX_ISR */
    
}


/*
 *********************************************************************************************************
 * Function      : SCI0_InBufferMoveTail()
 *
 * Description   : Move tail to new position; used to remove (erroneous) elements from the RX ring buffer
 * Arguments     : offset to be added to the tail
 * Return values : none
 *********************************************************************************************************
 */

tVOID SCI0_InBufferMoveTail(tINT16U tailOffset) {

    #if APP_SCI0_RX_ISR == 0
    
    /* not using RX ring buffer on SCI0 / not using ISR driven RX */
    
    /* do nothing */
    (tVOID)tailOffset;


    #else
    
    /* using RX ring buffer on SCI0 / ISR driven RX */
    
    /* move tail by requested number of elements */
    RB_MOVETAIL(&adminStruct_SCI0inBuf, tailOffset);
    
    #endif  /* APP_SCI0_RX_ISR */
    
}


#endif /* APP_SCI0_EN */





/*
 *********************************************************************************************************
 *    Serial Communication Interface SCI1
 *********************************************************************************************************
 */

#if APP_SCI1_EN == 1

/*
 *********************************************************************************************************
 * Function      : SCI1_Init()
 *
 * Description   : This function initializes the first Serial Communication Interface (SCI1)
 * Arguments     : baudrate specifier (as per sci.h)
 * Return values : none
 *********************************************************************************************************
 */

tVOID SCI1_Init(tINT8U baudRate) {

tINT32U  BR = (PLL_BUSCLK * 1000000) >> 4;       /* /16 */

    /* determine baud rate factor */
    switch(baudRate) {
    
        case BAUD_300:
            
            /* @ 24 MHz : 300 bps -> SCIBDH =  19 */
            /* @ 24 MHz : 300 bps -> SCIBDL = 136 */
            BR = BR / 300;
            break;
        
        case BAUD_600:
            
            /* @ 24 MHz : 600 bps -> SCIBDH =   9 */
            /* @ 24 MHz : 600 bps -> SCIBDL = 196 */
            BR = BR / 600;
            break;
            
          case BAUD_1200:
            
            /* @ 24 MHz : 1200 bps -> SCIBDH =   4 */
            /* @ 24 MHz : 1200 bps -> SCIBDL = 226 */
            BR = BR / 1200;
            break;
        
          case BAUD_2400:
            
            /* @ 24 MHz : 2400 bps -> SCIBDH =   2 */
            /* @ 24 MHz : 2400 bps -> SCIBDL = 113 */
            BR = BR / 2400;
            break;

          case BAUD_4800:
            
            /* @ 24 MHz : 4800 bps -> SCIBDH =   1 */
            /* @ 24 MHz : 4800 bps -> SCIBDL =  56 */
            BR = BR / 4800;
            break;
            
          case BAUD_9600:
            
            /* @ 24 MHz : 9600 bps -> SCIBDH =   0 */
            /* @ 24 MHz : 9600 bps -> SCIBDL = 156 */
            BR = BR / 9600;
            break;

          case BAUD_19200:
            
            /* @ 24 MHz : 19200 bps -> SCIBDH =   0 */
            /* @ 24 MHz : 19200 bps -> SCIBDL =  78 */
            BR = BR / 19200;
            break;

          case BAUD_38400:
            
            /* @ 24 MHz : 38400 bps -> SCIBDH =   0 */
            /* @ 24 MHz : 38400 bps -> SCIBDL =  39 */
            BR = BR / 38400;
            break;

          case BAUD_57600:
            
            /* @ 24 MHz : 57600 bps -> SCIBDH =   0 */
            /* @ 24 MHz : 57600 bps -> SCIBDL =  26 */
            BR = BR / 57600;
            break;

          case BAUD_115200:
            
            /* @ 24 MHz : 115200 bps -> SCIBDH =   0 */
            /* @ 24 MHz : 115200 bps -> SCIBDL =  13 */
            BR = BR / 115200;
            break;
            
    } /* switch */
  
    /* set baud rate registers */
    SCI1BDH = (tINT8U)(BR / 256);
    SCI1BDL = (tINT8U)(BR % 256);
    
    /* 
     * SCI1CR1:
     * 7   0    LOOPS, no looping, normal
     * 6   0    WOMS, normal high/low outputs
     * 5   0    RSRC, not appliable with LOOPS=0
     * 4   0    M, 1 start, 8 data, 1 stop
     * 3   0    WAKE, wake by idle (not applicable)
     * 2   0    ILT, short idle time (not applicable)
     * 1   0    PE, no parity
     * 0   0    PT, parity type (not applicable with PE=0)
     */ 
    SCI1CR1 = 0;
     
    
    #if APP_SCI1_ISR == 0
    
    /* not using ring buffers on SCI1 */
    
    /* 
     * SCI1CR2:
     * 7   0    TIE, no transmit interrupts on TDRE
     * 6   0    TCIE, no transmit interrupts on TC
     * 5   0    RIE, no receive interrupts on RDRF
     * 4   0    ILIE, no interrupts on idle
     * 3   1    TE, enable transmitter
     * 2   1    RE, enable receiver
     * 1   0    RWU, no receiver wakeup
     * 0   0    SBK, no send break
     */ 
    SCI1CR2 = 0x0C; 
    
    #elif (APP_SCI1_RX_ISR == 1) && (APP_SCI1_TX_ISR == 0)

    /* using RX ring buffer (only) on SCI1 */

    /* 
     * SCI1CR2:
     * 7   0    TIE, no transmit interrupts on TDRE
     * 6   0    TCIE, no transmit interrupts on TC 
     * 5   1    RIE, receive interrupts on RDRF (always active)
     * 4   0    ILIE, no interrupts on idle
     * 3   1    TE, enable transmitter
     * 2   1    RE, enable receiver
     * 1   0    RWU, no receiver wakeup
     * 0   0    SBK, no send break
     */ 
    SCI1CR2 = 0x2C;

    /* set up input ring buffer */
    RB_INIT(&adminStruct_SCI1inBuf,  SCI1inBuf,  APP_SCI1_RB_RX_BUF_SIZE);            /* set up RX ring buffer */
    
    #elif (APP_SCI1_RX_ISR == 0) && (APP_SCI1_TX_ISR == 1)

    /* using TX ring buffer (only) on SCI1 */

    /* 
     * SCI1CR2:
     * 7   0    TIE, no transmit interrupts on TDRE (bit will be set/reset on demand by the TX functions)
     * 6   0    TCIE, no transmit interrupts on TC 
     * 5   0    RIE, no receive interrupts on RDRF
     * 4   0    ILIE, no interrupts on idle
     * 3   1    TE, enable transmitter
     * 2   1    RE, enable receiver
     * 1   0    RWU, no receiver wakeup
     * 0   0    SBK, no send break
     */ 
    SCI1CR2 = 0x0C;

    /* set up output ring buffer */
    RB_INIT(&adminStruct_SCI1outBuf, SCI1outBuf, APP_SCI1_RB_TX_BUF_SIZE);            /* set up TX ring buffer */
    
    #else

    /* using RX and TX ring buffers on SCI1 */

    /* 
     * SCI1CR2:
     * 7   0    TIE, no transmit interrupts on TDRE (bit will be set/reset on demand by the TX functions)
     * 6   0    TCIE, no transmit interrupts on TC 
     * 5   1    RIE, receive interrupts on RDRF (always active)
     * 4   0    ILIE, no interrupts on idle
     * 3   1    TE, enable transmitter
     * 2   1    RE, enable receiver
     * 1   0    RWU, no receiver wakeup
     * 0   0    SBK, no send break
     */ 
    SCI1CR2 = 0x2C;

    /* set up input and output ring buffers */
    RB_INIT(&adminStruct_SCI1inBuf,  SCI1inBuf,  APP_SCI1_RB_RX_BUF_SIZE);            /* set up RX ring buffer */
    RB_INIT(&adminStruct_SCI1outBuf, SCI1outBuf, APP_SCI1_RB_TX_BUF_SIZE);            /* set up TX ring buffer */
    
    #endif  /* APP_SCI1_ISR */

    /* setup target sided timeout mechanism for SCI1 */
    #if BSP_SCI1_TIMEOUT_SUPP == 1
    SCI1_TimeoutInit((tFP32)APP_SCI1_TIMEOUT_SEC);
    #endif

}



/*
 *********************************************************************************************************
 * Function      : SCI1_InChar()
 *
 * Description   : Wait for next character on SCI1
 * Arguments     : pointer to the character to be returned
 * Return values : indicator of failure (-1) or success (0)
 * Comment       : function fetches a character from the input ring buffer (if used) and returns. If timeouts
 *                 are enabled, the function waits for a character to be received or a timeout to occurr, i. e.
 *                 the function returns after at most 'BSP_SCI1_TIMEOUT_MAX_SEC' seconds. If the timeout 
 *                 mechanism is inactive, (RTI not enabled) the function is blocking.
 *********************************************************************************************************
 */

tINT16S SCI1_InChar(tINT8U *cRet) {

    #if APP_SCI1_RX_ISR == 0
    
    /* not using RX ring buffer on SCI1 / not using ISR driven RX */
    
    /* reset SCI1 timeout counter */
    #if APP_SCI1_TIMEOUT_EN == 1
    resetTimeoutCounterSCI1();
    #endif

    /* wait for new character to arrive or timeout */
    while((SCI1SR1 & SCI1SR1_RDRF_MASK) == 0) {
    
        /* has a timeout occurred? */
        #if APP_SCI1_TIMEOUT_EN == 1
        if (timeoutSCI1()) {
        
            /* yes -> signal failure */
            return -1;
            
        }
        #endif
        
    }
    
    /* -- if we reach this point, the character to be read has been received -- */

    /* return received character */
    *cRet = (tINT8U)SCI1DRL;
    
    /* indicate success */
    return 0;
    

    #else

    
    /* using RX ring buffer on SCI1 / ISR driven RX */

    /* reset SCI1 timeout counter */
    #if APP_SCI1_TIMEOUT_EN == 1
    resetTimeoutCounterSCI1();
    #endif

    /* 
     * wait until there's at least one character in the ring buffer or until at SCI1 timeout has
     * occurred. If the timeout mechanism is not active, this call is blocking.
     */
    while (RB_POP(&adminStruct_SCI1inBuf, cRet) == -1) {

        /* has a timeout occurred? */
        #if APP_SCI1_TIMEOUT_EN == 1
        if (timeoutSCI1()) {
        
            /* yes -> signal failure */
            return -1;
            
        }
        #endif
        
    }


    /* -- if we reach this point, the character to be read has been fetched from the RX ring buffer -- */

    /* signal success */
    return 0;

    #endif  /* APP_SCI1_RX_ISR */

}



/*
 *********************************************************************************************************
 * Function      : SCI1_OutChar()
 *
 * Description   : Transmit next character on SCI1
 * Arguments     : character to be transmitted
 * Return values : indicator of failure (-1) or success (0)
 * Comment       : function stores the character to be transmitted on the output ring buffer (if used) and 
 *                 returns. If the timeout mechanism is active (RTI enabled), the function will return after 
 *                 at most 'BSP_SCI1_TIMEOUT_MAX_SEC' seconds. If the timeout mechanism is inactive, 
 *                 (RTI not enabled) the function is blocking.
 * Error memory  : ErrMem_SCI1_TX_BUF_FULL
 *********************************************************************************************************
 */

tINT16S SCI1_OutChar(tINT8U transData) {

    #if APP_SCI1_TX_ISR == 0
    
    /* not using TX ring buffer on SCI1 / not using ISR driven TX */
    
    /* reset SCI1 timeout counter */
    #if APP_SCI1_TIMEOUT_EN == 1
    resetTimeoutCounterSCI1();
    #endif

    /* wait for ongoing transmission to finish or a timeout */
    while((SCI1SR1 & SCI1SR1_TDRE_MASK) == 0) {
        
        /* has a timeout occurred? *//* wait for ongoing transmission to finish or a timeout */
        #if APP_SCI1_TIMEOUT_EN == 1
        if (timeoutSCI1()) {
            
            /* yes -> signal failure */
            #if BSP_SCI1_ERROR_SUPP == 1
            ErrMem_SCI1_TX_BUF_FULL = TRUE;
            #endif
            
            return -1;
            
        }
        #endif
        
    }
    
    /* -- if we reach this point, the TX dat register is empty -- */

    /* send next character */
    SCI1DRL = transData;

    /* signal success */
    return 0;

    
    #else
    

    /* using TX ring buffer on SCI1 / ISR driven TX */
    
    /* reset SCI1 timeout counter */
    #if APP_SCI1_TIMEOUT_EN == 1
    resetTimeoutCounterSCI1();
    #endif

    /* 
     * wait until there's space in the ring buffer or until at SCI1 timeout has
     * occurred. If the timeout mechanism is not active, this call is blocking.
     */
    while (RB_FULL(&adminStruct_SCI1outBuf)) {
        
        /* has a timeout occurred? */
        #if APP_SCI1_TIMEOUT_EN == 1
        if (timeoutSCI1()) {
            
            /* yes -> signal failure */
            #if BSP_SCI1_ERROR_SUPP == 1
            ErrMem_SCI1_TX_BUF_FULL = TRUE;
            #endif
            
            return -1;
            
        }
        #endif
        
    }


    /* -- if we reach this point, there is space on the TX ring buffer -- */

    /* place character to be sent in the buffer */
    *RB_PUSHSLOT(&adminStruct_SCI1outBuf) = transData;

    /* set write position for the next character to be sent */
    RB_PUSHADVANCE(&adminStruct_SCI1outBuf);

    /* adjust number of bytes held in the SCI1 TX buffer */
    RB_INC(&adminStruct_SCI1outBuf);

    /* (re-)enable transmission interrupt to send character */ 
    InterruptEnable_SCI1_TX;

    /* signal success */
    return 0;

    #endif  /* APP_SCI1_TX_ISR */

}



/*
 *********************************************************************************************************
 * Function      : SCI1_InStatus()
 *
 * Description   : Determine how many new characters have arrived
 * Arguments     : none
 * Return values : number of available characters
 *********************************************************************************************************
 */

tINT16U SCI1_InStatus(tVOID) {

    #if APP_SCI1_RX_ISR == 0
    
    /* not using RX ring buffer on SCI1 / not using ISR driven RX */
    
    /* determine if the reception data register is full (RDRF)*/
    if ((SCI1SR1 & SCI1SR1_RDRF_MASK) == SCI1SR1_RDRF_MASK) {
        
        /* a byte has arrived */
        return 1;
        
    } else {
        
        /* nothing has arrived yet */
        return 0;
        
    }

    #else
    
    /* using RX ring buffer on SCI1 / ISR driven RX */
    
    /* return number of elements in the buffer */
    return RB_ELEMENTS(&adminStruct_SCI1inBuf);
    
    #endif  /* APP_SCI1_RX_ISR */
    
}



/*
 *********************************************************************************************************
 * Function      : SCI1_InBufferPeek()
 *
 * Description   : Peek at values on the reception buffer without removing them
 * Arguments     : pointer to return value (cRet),
 *                 pointer to the pointer to the read position to be used (pReadFrom)
 * Return values : number of available characters
 *********************************************************************************************************
 */

tINT16U SCI1_InBufferPeek(tINT8U *cRet, tINT16U *tailOffset) {

    #if APP_SCI1_RX_ISR == 0
    
    /* not using RX ring buffer on SCI1 / not using ISR driven RX */
    
    /* determine if the reception data register is full (RDRF)*/
    if ((SCI1SR1 & SCI1SR1_RDRF_MASK) == SCI1SR1_RDRF_MASK) {
        
        /* return the received byte */
        *cRet = (tINT8U)SCI1DRL;
        
        /* set tailOffset to '0' (not using a buffer here) */
        *tailOffset = 0;
        
        /* indicate that 'one byte is available' for collection */
        return 1;
        
    } else {
        
        /* nothing has arrived yet */
        return 0;
        
    }

    #else
    
    /* using RX ring buffer on SCI1 / ISR driven RX */
    
    /* return number of elements in the buffer */
    return RB_PEEK(&adminStruct_SCI1inBuf, cRet, tailOffset);
    
    #endif  /* APP_SCI1_RX_ISR */
    
}


/*
 *********************************************************************************************************
 * Function      : SCI1_InBufferMoveTail()
 *
 * Description   : Move tail to new position; used to remove (erroneous) elements from the RX ring buffer
 * Arguments     : offset to be added to the tail
 * Return values : none
 *********************************************************************************************************
 */

tVOID SCI1_InBufferMoveTail(tINT16U tailOffset) {

    #if APP_SCI1_RX_ISR == 0
    
    /* not using RX ring buffer on SCI1 / not using ISR driven RX */
    
    /* do nothing */
    (tVOID)tailOffset;

    #else
    
    /* using RX ring buffer on SCI1 / ISR driven RX */
    
    /* move tail by requested number of elements */
    RB_MOVETAIL(&adminStruct_SCI1inBuf, tailOffset);
    
    #endif  /* APP_SCI1_RX_ISR */
    
}


#endif /* APP_SCI1_EN */

