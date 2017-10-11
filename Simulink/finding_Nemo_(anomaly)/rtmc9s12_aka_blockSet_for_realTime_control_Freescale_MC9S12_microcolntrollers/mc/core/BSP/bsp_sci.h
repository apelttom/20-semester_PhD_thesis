/*
 *********************************************************************************************************
 *
 * SCI support functions, Freescale MC9S12
 *                        adapted for rtmc9s12-target (reduced functionality, debug system, timeouts)
 *
 * (c) Frank Wörnle, 2010
 * 
 *********************************************************************************************************
 *
 * File              : bsp_sci.h
 * Version           : 1.00
 * Last modification : 11.04.2010, Frank Wörnle, adapted for rtmc9s12-target
 *
 *********************************************************************************************************
 */
 
#ifndef _BSP_SCI_H_
#define _BSP_SCI_H_



/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */

#include "bsp_cfg.h"                                  /* derivative information                 */
#include "bsp_dtypes.h"                               /* target specific data types             */



/*
 *********************************************************************************************************
 *    PUBLIC MACROS
 *********************************************************************************************************
 */

#if BSP_SCI0_SUPP == 1

/* 
 * rename registers to be consistent with the Freescale documentation:
 * on controllers with only one serial communication interface, the registers
 * of the (first) serial comms interface are called SCIxxx instead of SCI0xxx
 */
#if (BSP_CPU == BSP_MC9S12DP256B) || (BSP_CPU == BSP_MC9S12DG256) || (BSP_CPU == BSP_MC9S12DG128)

#define  SCIBDH                             SCI0BDH
#define  SCIBDL                             SCI0BDL
#define  SCICR1                             SCI0CR1
#define  SCICR2                             SCI0CR2
#define  SCISR1                             SCI0SR1
#define  SCIDRH                             SCI0DRH
#define  SCIDRL                             SCI0DRL

#define  SCICR2_RIE_MASK                    SCI0CR2_RIE_MASK
#define  SCICR2_SCTIE_MASK                  SCI0CR2_SCTIE_MASK
#define  SCICR2_TCIE_MASK                   SCI0CR2_TCIE_MASK
#define  SCISR1_RDRF_MASK                   SCI0SR1_RDRF_MASK
#define  SCISR1_TDRE_MASK                   SCI0SR1_TDRE_MASK

#endif /* MC9S12DP256B, MC9S12DG256 */

/* enable/disable SCI0 RX/TX interrupt */
#define InterruptEnable_SCI0       SCICR2 |=  (SCICR2_RIE_MASK|SCICR2_SCTIE_MASK|SCICR2_TCIE_MASK)
#define InterruptDisable_SCI0      SCICR2 &= ~(SCICR2_RIE_MASK|SCICR2_SCTIE_MASK|SCICR2_TCIE_MASK)

#define InterruptEnable_SCI0_RX    SCICR2 |=  SCICR2_RIE_MASK
#define InterruptDisable_SCI0_RX   SCICR2 &= ~SCICR2_RIE_MASK

#define InterruptEnable_SCI0_TX    SCICR2 |=  SCICR2_SCTIE_MASK
#define InterruptDisable_SCI0_TX   SCICR2 &= ~SCICR2_SCTIE_MASK

#define InterruptEnable_SCI0_TXc   SCICR2 |=  SCICR2_TCIE_MASK
#define InterruptDisable_SCI0_TXc  SCICR2 &= ~SCICR2_TCIE_MASK

#endif  /* BSP_SCI0_SUPP */



#if BSP_SCI1_SUPP == 1

/* enable/disable SCI1 RX/TX interrupt */
#define InterruptEnable_SCI1       SCI1CR2 |=  (SCI1CR2_RIE_MASK|SCI1CR2_SCTIE_MASK|SCI1CR2_TCIE_MASK)
#define InterruptDisable_SCI1      SCI1CR2 &= ~(SCI1CR2_RIE_MASK|SCI1CR2_SCTIE_MASK|SCI1CR2_TCIE_MASK)

#define InterruptEnable_SCI1_RX    SCI1CR2 |=  SCI1CR2_RIE_MASK
#define InterruptDisable_SCI1_RX   SCI1CR2 &= ~SCI1CR2_RIE_MASK

#define InterruptEnable_SCI1_TX    SCI1CR2 |=  SCI1CR2_SCTIE_MASK
#define InterruptDisable_SCI1_TX   SCI1CR2 &= ~SCI1CR2_SCTIE_MASK

#define InterruptEnable_SCI1_TXc   SCI1CR2 |=  SCI1CR2_TCIE_MASK
#define InterruptDisable_SCI1_TXc  SCI1CR2 &= ~SCI1CR2_TCIE_MASK

#endif  /* BSP_SCI1_SUPP */



/* baud rates (300 bps ... 115.2 kbps)                     */
#define  BAUD_300                           0
#define  BAUD_600                           1
#define  BAUD_1200                          2
#define  BAUD_2400                          3
#define  BAUD_4800                          4
#define  BAUD_9600                          5
#define  BAUD_19200                         6
#define  BAUD_38400                         7
#define  BAUD_57600                         8
#define  BAUD_115200                        9

/* common ASCII symbols                                    */
#define  CR                              0x0D
#define  LF                              0x0A
#define  BS                              0x08
#define  ESC                             0x1B
#define  SP                              0x20       
#define  DEL                             0x7F




/*
 *********************************************************************************************************
 *    DECLARATION OF PUBLIC FUNCTIONS
 *********************************************************************************************************
 */



#if BSP_SCI0_SUPP == 1

/* declare application dependent functions of SCI0 (defined in app_sci.c)  */
extern tVOID    SCI0_Init(tINT8U baudRate);
extern tINT16S  SCI0_InChar(tINT8U *cRet);
extern tINT16S  SCI0_OutChar(tINT8U transData);  

/* declare application independent functions of SCI0 (defined in bsp_sci.c)  */
#ifdef ERASE
extern tBOOLEAN SCI0_InString(tINT8U *buf, tINT16U);
#endif  /* ERASE */
extern tINT16U  SCI0_InStatus(tVOID);

extern tVOID    SCI0_OutString(const tCHAR *buf); 
extern tVOID    SCI0_OutUDec(tINT16U);    
extern tVOID    SCI0_OutUHex(tINT16U);    
extern tINT16U  SCI0_InBufferPeek(tINT8U *cRet, tINT16U *tailOffset);
extern tVOID    SCI0_InBufferMoveTail(tINT16U tailOffset);

#endif /* BSP_SCI0_SUPP */



#if BSP_SCI1_SUPP == 1

/* declare application dependent functions of SCI1 (defined in app_sci.c) */
extern tVOID    SCI1_Init(tINT8U baudRate);
extern tINT16S  SCI1_InChar(tINT8U *cRet);
extern tINT16S  SCI1_OutChar(tINT8U transData);  

/* declare application independent functions of SCI1 (defined in bsp_sci.c)  */
#ifdef ERASE
extern tBOOLEAN SCI1_InString(tINT8U *buf, tINT16U);
#endif  /* ERASE */
extern tINT16U  SCI1_InStatus(tVOID);

extern tVOID    SCI1_OutString(const tCHAR *buf);
extern tINT16U  SCI1_InBufferPeek(tINT8U *cRet, tINT16U *tailOffset);
extern tVOID    SCI1_InBufferMoveTail(tINT16U tailOffset);

#endif /* BSP_SCI1_SUPP */



/*
 *********************************************************************************************************
 *    ERROR CHECKING
 *********************************************************************************************************
 */



#endif /* _BSP_SCI_H_ */