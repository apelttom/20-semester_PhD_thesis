/*
 *********************************************************************************************************
 *
 * Board Support Package data types
 *
 * (c) Frank Wörnle, 2009
 * 
 *********************************************************************************************************
 *
 * File              : bsp_dtypes.h
 * Version           : 1.00
 * Last modification : 01.06.2009, fwoernle, definition of data types
 *
 *********************************************************************************************************
 */
 
#ifndef _BSP_DTYPES_H_
#define _BSP_DTYPES_H_



/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */



/*
 *********************************************************************************************************
 *    PUBLIC MACROS
 *********************************************************************************************************
 */

#ifndef TRUE
#define TRUE     1
#endif

#ifndef FALSE
#define FALSE    0
#endif

/* Definition of NULL Pointer */
#ifndef NULL
#define NULL     (void *)0
#endif



/*
 *********************************************************************************************************
 *    STANDARD DATA TYPES
 *********************************************************************************************************
 */

/* all variable definitions / declarations should use these data types (exclusively) */
typedef            void      tVOID;
typedef    signed  char      tCHAR;                        /*  8-bit character                            */
typedef  unsigned  char      tCHARU;                       /*  8-bit unsigned character                   */
typedef  unsigned  char      tBOOLEAN;                     /*  8-bit boolean or logical                   */
typedef  unsigned  char      tINT8U;                       /*  8-bit unsigned integer                     */
typedef    signed  char      tINT8S;                       /*  8-bit   signed integer                     */
typedef  unsigned  int       tINT16U;                      /* 16-bit unsigned integer                     */
typedef    signed  int       tINT16S;                      /* 16-bit   signed integer                     */
typedef  unsigned  long      tINT32U;                      /* 32-bit unsigned integer                     */
typedef    signed  long      tINT32S;                      /* 32-bit   signed integer                     */
typedef            float     tFP32;                        /* 32-bit floating point                       */

/* standard function type  --  used to encapsulate the functional part of ISRs */
typedef            void      tUsrFncISR(void);             /* ISR user function (void-void)               */


/*
 *********************************************************************************************************
 *    ERROR CHECKING
 *********************************************************************************************************
 */



#endif /* _BSP_DTYPES_H_ */