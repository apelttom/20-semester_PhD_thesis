/*
 *********************************************************************************************************
 *
 * ISR vector definitions
 *
 * (c) Frank Wörnle, 2010
 * 
 *********************************************************************************************************
 *
 * File              : app_vectors.c
 * Version           : 1.12
 * Last modification : 30.08.2010, fwoernle, "bsp_includes.h" and "mc_defines.h" included from "app_cfg.h"
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

#include "app_cfg.h"                             /* application dependent configuration    */





/*
 *********************************************************************************************************
 *    DEFINES
 *********************************************************************************************************
 */

typedef tVOID (*near tIsrFunc)(tVOID);



 
/*
 *********************************************************************************************************
 *    ISR FUNCTION PROTOTYPES
 *********************************************************************************************************
 */

extern tVOID near _Startup(tVOID);                      /* Startup Routine                        */

/* SCIx interrupt service routines */
#if    APP_SCI0_ISR == 1
extern CPL_INTERRUPT tVOID SCI0_isr(tVOID);
#endif
#if    APP_SCI1_ISR == 1
extern CPL_INTERRUPT tVOID SCI1_isr(tVOID);
#endif

/* RTI interrupt service routine */
#if    APP_RTI_ISR == 1
  #if APP_RTOS_EN == 1
  extern CPL_INTERRUPT tVOID vPortTickInterrupt(tVOID);
  extern CPL_INTERRUPT tVOID vPortYield(tVOID);
  #else
  extern CPL_INTERRUPT tVOID RTI_isr(tVOID);
  #endif
#endif


/* CANx interrupt service routine */
#if    APP_CAN0_ISR == 1
extern CPL_INTERRUPT tVOID CAN0_RX_isr(tVOID);
extern CPL_INTERRUPT tVOID CAN0_TX_isr(tVOID);
#endif
#if    APP_CAN1_ISR == 1
extern CPL_INTERRUPT tVOID CAN1_RX_isr(tVOID);
extern CPL_INTERRUPT tVOID CAN1_TX_isr(tVOID);
#endif
#if    APP_CAN2_ISR == 1
extern CPL_INTERRUPT tVOID CAN2_RX_isr(tVOID);
extern CPL_INTERRUPT tVOID CAN2_TX_isr(tVOID);
#endif
#if    APP_CAN3_ISR == 1
extern CPL_INTERRUPT tVOID CAN3_RX_isr(tVOID);
extern CPL_INTERRUPT tVOID CAN3_TX_isr(tVOID);
#endif
#if    APP_CAN4_ISR == 1
extern CPL_INTERRUPT tVOID CAN4_RX_isr(tVOID);
extern CPL_INTERRUPT tVOID CAN4_TX_isr(tVOID);
#endif


/* ADC interrupt service routine, ATD bank #0 */
#if    APP_ATD0_ISR == 1
extern CPL_INTERRUPT tVOID ATD0_isr(tVOID);
#endif

#if    APP_ATD1_ISR == 1
extern CPL_INTERRUPT tVOID ATD1_isr(tVOID);
#endif


/* ECT interrupt service routines (timer) */
#if    APP_ECT_ISR == 1
extern CPL_INTERRUPT tVOID  ECT_isr                 (   tVOID                       );          /* main time base (TC7)   */
extern CPL_INTERRUPT tVOID  TOF_ISR                 (   tVOID                       );          /* bsp_timer.c */
extern CPL_INTERRUPT tVOID  T0_ISR                  (   tVOID                       );          /* block implementing T0_ISR */
extern CPL_INTERRUPT tVOID  T1_ISR                  (   tVOID                       );          /* block implementing T1_ISR */
extern CPL_INTERRUPT tVOID  T2_ISR                  (   tVOID                       );          /* block implementing T2_ISR */
extern CPL_INTERRUPT tVOID  T3_ISR                  (   tVOID                       );          /* block implementing T3_ISR */
extern CPL_INTERRUPT tVOID  T4_ISR                  (   tVOID                       );          /* block implementing T4_ISR */
extern CPL_INTERRUPT tVOID  T5_ISR                  (   tVOID                       );          /* block implementing T5_ISR */
extern CPL_INTERRUPT tVOID  T6_ISR                  (   tVOID                       );          /* block implementing T6_ISR */
extern CPL_INTERRUPT tVOID  T7_ISR                  (   tVOID                       );          /* block implementing T7_ISR */
#endif


/* other interrupt service routines */
extern CPL_INTERRUPT tVOID RadioServer_OnTick(tVOID);    /* radioServer_timer.c */
extern CPL_INTERRUPT tVOID RadioClient_OnTick(tVOID);    /* radioClient_timer.c */



/*
 *********************************************************************************************************
 *               DUMMY INTERRUPT SERVICE ROUTINES
 *
 * Description : When a spurious interrupt occurs, the processor will 
 *               jump to the dedicated default handler and stay there
 *               so that the source interrupt may be identified and
 *               debugged.
 *
 * Notes       : Do Not Modify
 *********************************************************************************************************
 */

#pragma CODE_SEG __NEAR_SEG NON_BANKED 
CPL_INTERRUPT tVOID software_trap64 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap63 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap62 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap61 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap60 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap59 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap58 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap57 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap56 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap55 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap54 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap53 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap52 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap51 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap50 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap49 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap48 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap47 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap46 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap45 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap44 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap43 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap42 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap41 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap40 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap39 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap38 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap37 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap36 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap35 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap34 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap33 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap32 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap31 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap30 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap29 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap28 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap27 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap26 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap25 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap24 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap23 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap22 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap21 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap20 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap19 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap18 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap17 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap16 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap15 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap14 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap13 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap12 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap11 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap10 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap09 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap08 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap07 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap06 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap05 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap04 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap03 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap02 (tVOID) {for(;;);}
CPL_INTERRUPT tVOID software_trap01 (tVOID) {for(;;);}
#pragma CODE_SEG DEFAULT   



/*
 *********************************************************************************************************
 *    INTERRUPT VECTOR TABLE
 *********************************************************************************************************
 */

const tIsrFunc _vect[] @0xFF80 = {

    software_trap63,               /* 63 RESERVED                               */
    software_trap62,               /* 62 RESERVED                               */
    software_trap61,               /* 61 RESERVED                               */
    software_trap60,               /* 60 RESERVED                               */
    software_trap59,               /* 59 RESERVED                               */
    software_trap58,               /* 58 RESERVED                               */
    software_trap57,               /* 57 PWM Emergency Shutdown                 */
    software_trap56,               /* 56 Port P Interrupt                       */

    #if    APP_CAN4_ISR == 1
    CAN4_TX_isr,                   /* 55 CAN4 transmit                          */
    CAN4_RX_isr,                   /* 54 CAN4 receive                           */
    #else
    software_trap55,               /* 55 CAN4 transmit                          */
    software_trap54,               /* 54 CAN4 receive                           */
    #endif
    software_trap53,               /* 53 CAN4 errors                            */
    software_trap52,               /* 52 CAN4 wake-up                           */ 
    #if    APP_CAN3_ISR == 1
    CAN3_TX_isr,                   /* 51 CAN3 transmit                          */
    CAN3_RX_isr,                   /* 50 CAN3 receive                           */
    #else
    software_trap51,               /* 51 CAN3 transmit                          */
    software_trap50,               /* 50 CAN3 receive                           */
    #endif
    software_trap49,               /* 49 CAN3 errors                            */
    software_trap48,               /* 48 CAN3 wake-up                           */ 
    #if    APP_CAN2_ISR == 1
    CAN2_TX_isr,                   /* 47 CAN2 transmit                          */
    CAN2_RX_isr,                   /* 46 CAN2 receive                           */
    #else
    software_trap47,               /* 47 CAN2 transmit                          */
    software_trap46,               /* 46 CAN2 receive                           */
    #endif
    software_trap45,               /* 45 CAN2 errors                            */
    software_trap44,               /* 44 CAN2 wake-up                           */ 
    #if    APP_CAN1_ISR == 1
    CAN1_TX_isr,                   /* 43 CAN1 transmit                          */
    CAN1_RX_isr,                   /* 42 CAN1 receive                           */
    #else
    software_trap43,               /* 43 CAN1 transmit                          */
    software_trap42,               /* 42 CAN1 receive                           */
    #endif
    software_trap41,               /* 41 CAN1 errors                            */
    software_trap40,               /* 40 CAN1 wake-up                           */ 
    #if    APP_CAN0_ISR == 1
    CAN0_TX_isr,                   /* 39 CAN0 transmit                          */
    CAN0_RX_isr,                   /* 38 CAN0 receive                           */
    #else
    software_trap39,               /* 39 CAN0 transmit                          */
    software_trap38,               /* 38 CAN0 receive                           */
    #endif
    software_trap37,               /* 37 CAN0 errors                            */
    software_trap36,               /* 36 CAN0 wake-up                           */        

    software_trap35,               /* 35 FLASH                                  */
    software_trap34,               /* 34 EEPROM                                 */
    software_trap33,               /* 33 SPI2                                   */
    software_trap32,               /* 32 SPI1                                   */
    software_trap31,               /* 31 IIC Bus                                */
    software_trap30,               /* 30 BDLC                                   */
    software_trap29,               /* 29 CRG Self Clock Mode                    */
    software_trap28,               /* 28 CRG PLL lock                           */
    software_trap27,               /* 27 Pulse Accumulator B Overflow           */
    software_trap26,               /* 26 Modulus Down Counter underflow         */
    software_trap25,               /* 25 Port H                                 */
    software_trap24,               /* 24 Port J                                 */

    #if    APP_ATD1_ISR == 1
    ATD1_isr,                      /* 23 ATD1                                   */
    #else
    software_trap23,               /* 23 ATD1                                   */
    #endif
    #if    APP_ATD0_ISR == 1
    ATD0_isr,                      /* 22 ATD0                                   */
    #else
    software_trap22,               /* 22 ATD0                                   */
    #endif

    #if    APP_SCI1_ISR == 1
        #if SCI1_COMMS != idle
        SCI1_isr,                  /* 21 SCI1                                   */
        #else
        software_trap21,           /* 21 SC11                                   */
        #endif
    #else
    software_trap21,               /* 21 SC11                                   */
    #endif
    #if    APP_SCI0_ISR == 1
        #if SCI0_COMMS != idle
        SCI0_isr,                  /* 20 SCI0                                   */
        #else
        software_trap20,           /* 20 SC10                                   */
        #endif
    #else
    software_trap20,               /* 20 SCI0                                   */
    #endif

    software_trap19,               /* 19 SPI0                                   */
    software_trap18,               /* 18 Pulse accumulator input edge           */
    software_trap17,               /* 17 Pulse accumulator A overflow           */

    #if    (HAS_TIMERBLOCKS > 0) | (HAS_RFCOMMS > 0)
    TOF_ISR,                       /* 16 Enhanced Capture Timer Overflow        */
    #else
    software_trap16,               /* 16 Enhanced Capture Timer Overflow        */
    #endif

    #if CORE_TIMER == CORE_T7ISR
    ECT_isr,                       /* 15 ECT channel 7 as CORE_TIMER            */
    #else
      #if  T7_MODE > 0
      T7_ISR,                      /* 15 Enhanced Capture Timer channel 7       */        
      #else
      software_trap15,             /* 15 Enhanced Capture Timer channel 7       */        
      #endif
    #endif
    #if    T6_MODE > 0
    T6_ISR,                        /* 14 Enhanced Capture Timer channel 6       */
    #else
    software_trap14,               /* 14 Enhanced Capture Timer channel 6       */
    #endif
    #if    T5_MODE > 0
    T5_ISR,                        /* 13 Enhanced Capture Timer channel 5       */
    #else
    software_trap13,               /* 13 Enhanced Capture Timer channel 5       */
    #endif
    #if    T4_MODE > 0
    T4_ISR,                        /* 12 Enhanced Capture Timer channel 4       */
    #else
    software_trap12,               /* 12 Enhanced Capture Timer channel 4       */
    #endif
    #if    T3_MODE > 0
    T3_ISR,                        /* 11 Enhanced Capture Timer channel 3       */
    #else
    software_trap11,               /* 11 Enhanced Capture Timer channel 3       */
    #endif
    #if    T2_MODE > 0
    T2_ISR,                        /* 10 Enhanced Capture Timer channel 2       */
    #else
    software_trap10,               /* 10 Enhanced Capture Timer channel 2       */
    #endif
    #if    T1_MODE > 0
    T1_ISR,                        /* 09 Enhanced Capture Timer channel 1       */
    #else
    software_trap09,               /* 09 Enhanced Capture Timer channel 1       */
    #endif
    #if    T0_MODE > 0
    T0_ISR,                        /* 08 Enhanced Capture Timer channel 0       */
    #else
        #if HAS_RFCOMMS == 1
        RadioServer_OnTick,        /* 08 Enhanced Capture Timer channel 0       */
        #else
            #if HAS_RFCOMMS == 2
            RadioClient_OnTick,    /* 08 Enhanced Capture Timer channel 0       */
            #else
            software_trap08,       /* 08 Enhanced Capture Timer channel 0       */
            #endif
        #endif
    #endif

    #if    APP_RTI_ISR == 1
      #if  APP_RTOS_EN == 1
      vPortTickInterrupt,          /* 07 FreeRTOS timer tick function           */
      #else
      RTI_isr,                     /* 07 Real Time Interrupt as CORE_TIMER      */
      #endif
    #else
    software_trap07,               /* 07 Real Time Interrupt                    */
    #endif
    
    software_trap06,               /* 06 IRQ                                    */
    software_trap05,               /* 05 XIRQ                                   */

    #if    APP_RTOS_EN == 1
    vPortYield,                    /* 04 SWI - FreeRTOS manual context switch   */
    #else
    software_trap04,               /* 04 SWI - Breakpoint on HCS12 Serial Mon.  */
    #endif

    software_trap03,               /* 03 Unimplemented instruction trap         */
    software_trap02,               /* 02 COP failure reset                      */
    software_trap01,               /* 01 Clock monitor fail reset               */
    _Startup                       /* 00 Reset vector                           */

};

