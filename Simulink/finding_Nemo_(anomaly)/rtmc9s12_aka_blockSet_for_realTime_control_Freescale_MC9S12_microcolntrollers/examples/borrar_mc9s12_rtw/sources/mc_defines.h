/* automatically generated defines      */
/* 04-Sep-2010 14:44:01                 */

#ifndef _MC_DEFINES_H_
#define _MC_DEFINES_H_

/* 
 * hardware selection and debugging
 * 
 * #define                  TARGET_BOARD  BSP_DRAGON12PLUS
 * #define             TARGET_OSCILLATOR  8
 * #define                    TARGET_CPU  BSP_MC9S12DG256
 * #define             TARGET_CPU_FAMILY  BSP_MC9S12
 * #define                 DEBUG_MSG_LVL  0
 * #define                 DEBUG_MSG_LVL  0
 */
#include "mc_hw_defines.h"

/* general defines */
#define                          MODEL   borrar
#define                            ERT   1
#define                          NUMST   2
#define                        TID01EQ   0
#define                             MT   0
#define                   MULTITASKING   0
#define                       MAT_FILE   0
#define                       NCSTATES   0
#define                   INTEGER_CODE   0
#define            MULTI_INSTANCE_CODE   0
#define                      HAVESTDIO   0
#define                    USE_RTMODEL   1
#define                             RT   1
#define                       EXT_MODE   1

/* model dependent defines */
#define            USE_TARGET_TIMEOUTS   1
#define                RUN_IMMEDIATELY   0
#define                    CIRCBUFSIZE   2000
#define              DISP_CIRCBUF_FREE   1
#define                    FIFOBUFSIZE   300
#define                     FIFOBUFNUM   2
#define               COMMSTATE_ON_PTT   0
#define                 EXTMODE_STATIC   1
#define            EXTMODE_STATIC_SIZE   6500
#define                       RBUFSIZE   1000
#define                       BAUDRATE   BAUD_115200
#define                           idle   0
#define                           MCOM   1
#define                           frPT   2
#define                     SCI0_COMMS   idle
#define                     SCI1_COMMS   MCOM
#define         SCI0_FREEPORT_CHANNELS   0
#define         SCI1_FREEPORT_CHANNELS   0
#define                  LCDUSE4ERRORS   1
#define                       MODELSTR   "borrar"
#define                    RTOSSUPPORT   0
#define                       CORE_RTI   1
#define                     CORE_T7ISR   2
#define                     CORE_TIMER   CORE_RTI
#define               TIMER_BASEPERIOD   0
#define                TIMER_PRESCALER   0
#define           TIMER_PRESCALER_MASK   0
#define                HAS_TIMERBLOCKS   0x00000000
#define                     TIMINGSIGS   0
#define              setCycTiPinOutput   DDRH |=  (0x01<<5) | (0x01<<6)
#define                    setCycTiPin   PTH  |=  (0x01<<5)
#define                    clrCycTiPin   PTH  &= ~(0x01<<5)
#define                    setSerTiPin   PTH  |=  (0x01<<6)
#define                    clrSerTiPin   PTH  &= ~(0x01<<6)
#define                        T0_MODE   (HAS_TIMERBLOCKS&0x0000000F)/0x00000001
#define                        T1_MODE   (HAS_TIMERBLOCKS&0x000000F0)/0x00000010
#define                        T2_MODE   (HAS_TIMERBLOCKS&0x00000F00)/0x00000100
#define                        T3_MODE   (HAS_TIMERBLOCKS&0x0000F000)/0x00001000
#define                        T4_MODE   (HAS_TIMERBLOCKS&0x000F0000)/0x00010000
#define                        T5_MODE   (HAS_TIMERBLOCKS&0x00F00000)/0x00100000
#define                        T6_MODE   (HAS_TIMERBLOCKS&0x0F000000)/0x01000000
#define                        T7_MODE   (HAS_TIMERBLOCKS&0xF0000000)/0x10000000
#define                    HAS_RFCOMMS   0
#define                   CLIENT_COUNT   0
#define                        HAS_SPI   0

/* eliminate preprocessor warnings */
#define                   __BORLANDC__   0
#define                    __WATCOMC__   0


/*
 * central include file for system definitions such as the 
 * - useful global macros (hidef.h) 
 * - configuration of the board support package (bsp_cfg.h) 
 * - taget specific data types (bsp_dtypes.h)
 * - special function registers for the chosen micro (e.g. mc9s12dp256.h)
 */
#include "bsp_includes.h"

#endif /* _MC_DEFINES_H_ */
