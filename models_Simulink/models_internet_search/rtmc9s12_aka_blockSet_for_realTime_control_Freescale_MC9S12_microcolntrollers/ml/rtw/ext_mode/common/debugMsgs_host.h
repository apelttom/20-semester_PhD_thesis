/* set verbosity of debugging messages (0, 1, 2, 3 or 4 -> set this to 0 in the release version) */
/* fw-06-07 */

#ifndef _DEBUG_MSGS_HOST_H_
#define _DEBUG_MSGS_HOST_H_

/* ================================================================================================== */

#include <mex.h>                    /* mexPrintf */

// define the following macro to enable the message counter (currently 'DEBUG_MSG_LVL == 1' only)
#undef DEBUG_MSGCOUNTER
#ifdef DEBUG_MSGCOUNTER
// globaler message counter, defined in mc_main
extern unsigned int    msgCounter;
#endif


// define the following macro to enable the use of interrupt driven TX during debugging
#define DEBUG_TX_IRQ


// define the following macro to enable dynamic debug messaging
//#define DEBUG_DYNAMIC
#ifdef DEBUG_DYNAMIC
// globale debug message level variable, defined in ext_comm (host) and in mc_main (target)
extern unsigned int    DynamicDbgMsgLvl;    // 0: off, 1: level-1, 2: level-2, etc.
#endif

/* switch off all types of debugging if DEBUG_MSG_LVL is '0' */
#if DEBUG_MSG_LVL == 0
#undef DEBUG_DYNAMIC
#undef DEBUG_MSGCOUNTER
#undef DEBUG_TX_IRQ
#endif

/* switch off IRQ based debugging whenever SCI0 is used otherwise */
#if SCI0_COMMS != 0
#undef DEBUG_TX_IRQ
#endif



#ifdef DEBUG_DYNAMIC
#define SWITCH_DYNAMIC_DBG_LVL(lvl)                                               \
{                                                                                 \
  if(lvl != DynamicDbgMsgLvl) {                                                    \
      DynamicDbgMsgLvl = lvl;                                                     \
      PRINT_DEBUG_MSG_LVL1("DEBUG_DYNAMIC: Switching DynamicDbgMsgLvl to ");      \
      PRINT_DEBUG_MSG_LVL1_UDec(DynamicDbgMsgLvl);                                \
      PRINT_DEBUG_MSG_NL1;                                                        \
  }                                                                               \
}
#else
#define SWITCH_DYNAMIC_DBG_LVL(lvl)  /* release version, do nothing */
#endif /* DEBUG_DYNAMIC */

/* ================================================================================================== */

/* default function name (defined in debugMsgs.c / debugMsgs_host.c)... this name is usually overridden locally  --  fw-07-07 */
extern const char *funct_name;


/* function declarations */

extern void funct_PRINT_DEBUG_MSG_LVL1(const char *funct_name, const char *args);
extern void funct_PRINT_DEBUG_MSG_LVL2(const char *funct_name, const char *args);
extern void funct_PRINT_DEBUG_MSG_LVL3(const char *funct_name, const char *args);
extern void funct_PRINT_DEBUG_MSG_LVL4(const char *funct_name, const char *args);
extern void funct_PRINT_DEBUG_MSG_LVL5(const char *funct_name, const char *args);
extern void funct_PRINT_DEBUG_MSG_LVL1_Raw(const char *args);
extern void funct_PRINT_DEBUG_MSG_LVL2_Raw(const char *args);
extern void funct_PRINT_DEBUG_MSG_LVL3_Raw(const char *args);
extern void funct_PRINT_DEBUG_MSG_LVL4_Raw(const char *args);
extern void funct_PRINT_DEBUG_MSG_LVL5_Raw(const char *args);
extern void funct_PRINT_DEBUG_MSG_LVL1_UDec(unsigned int args);
extern void funct_PRINT_DEBUG_MSG_LVL2_UDec(unsigned int args);
extern void funct_PRINT_DEBUG_MSG_LVL3_UDec(unsigned int args);
extern void funct_PRINT_DEBUG_MSG_LVL4_UDec(unsigned int args);
extern void funct_PRINT_DEBUG_MSG_LVL5_UDec(unsigned int args);
extern void funct_PRINT_DEBUG_MSG_LVL1_UHex(unsigned int args);
extern void funct_PRINT_DEBUG_MSG_LVL2_UHex(unsigned int args);
extern void funct_PRINT_DEBUG_MSG_LVL3_UHex(unsigned int args);
extern void funct_PRINT_DEBUG_MSG_LVL4_UHex(unsigned int args);
extern void funct_PRINT_DEBUG_MSG_LVL5_UHex(unsigned int args);
extern void funct_PRINT_DEBUG_MSG_NL1(void);
extern void funct_PRINT_DEBUG_MSG_NL2(void);
extern void funct_PRINT_DEBUG_MSG_NL3(void);
extern void funct_PRINT_DEBUG_MSG_NL4(void);
extern void funct_PRINT_DEBUG_MSG_NL5(void);


/* target specific function declarations */
#ifndef MATLAB_MEX_FILE

extern void SCI0_OutChar(char data);
extern void SCI0_OutString(const char *pt);
extern void SCI0_OutUDec(unsigned short n);
extern void SCI0_OutUHex(unsigned short number);

#endif /* MATLAB_MEX_FILE */


#if DEBUG_MSG_LVL > 0
#define DEFINE_DEBUG_FNAME(x)   const char *funct_name=(x);
#else
#define DEFINE_DEBUG_FNAME(x)   /* release -> do nothing */
#endif


#if DEBUG_MSG_LVL == 5
#define PRINT_DEBUG_MSG_LVL1(args) funct_PRINT_DEBUG_MSG_LVL1(funct_name, args)
#define PRINT_DEBUG_MSG_LVL2(args) funct_PRINT_DEBUG_MSG_LVL2(funct_name, args)
#define PRINT_DEBUG_MSG_LVL3(args) funct_PRINT_DEBUG_MSG_LVL3(funct_name, args)
#define PRINT_DEBUG_MSG_LVL4(args) funct_PRINT_DEBUG_MSG_LVL4(funct_name, args)
#define PRINT_DEBUG_MSG_LVL5(args) funct_PRINT_DEBUG_MSG_LVL5(funct_name, args)
#define PRINT_DEBUG_MSG_LVL1_Raw(args) funct_PRINT_DEBUG_MSG_LVL1_Raw(args)
#define PRINT_DEBUG_MSG_LVL2_Raw(args) funct_PRINT_DEBUG_MSG_LVL2_Raw(args)
#define PRINT_DEBUG_MSG_LVL3_Raw(args) funct_PRINT_DEBUG_MSG_LVL3_Raw(args)
#define PRINT_DEBUG_MSG_LVL4_Raw(args) funct_PRINT_DEBUG_MSG_LVL4_Raw(args)
#define PRINT_DEBUG_MSG_LVL5_Raw(args) funct_PRINT_DEBUG_MSG_LVL5_Raw(args)
#define PRINT_DEBUG_MSG_LVL1_UDec(args) funct_PRINT_DEBUG_MSG_LVL1_UDec(args)
#define PRINT_DEBUG_MSG_LVL2_UDec(args) funct_PRINT_DEBUG_MSG_LVL2_UDec(args)
#define PRINT_DEBUG_MSG_LVL3_UDec(args) funct_PRINT_DEBUG_MSG_LVL3_UDec(args)
#define PRINT_DEBUG_MSG_LVL4_UDec(args) funct_PRINT_DEBUG_MSG_LVL4_UDec(args)
#define PRINT_DEBUG_MSG_LVL5_UDec(args) funct_PRINT_DEBUG_MSG_LVL5_UDec(args)
#define PRINT_DEBUG_MSG_LVL1_UHex(args) funct_PRINT_DEBUG_MSG_LVL1_UHex(args)
#define PRINT_DEBUG_MSG_LVL2_UHex(args) funct_PRINT_DEBUG_MSG_LVL2_UHex(args)
#define PRINT_DEBUG_MSG_LVL3_UHex(args) funct_PRINT_DEBUG_MSG_LVL3_UHex(args)
#define PRINT_DEBUG_MSG_LVL4_UHex(args) funct_PRINT_DEBUG_MSG_LVL4_UHex(args)
#define PRINT_DEBUG_MSG_LVL5_UHex(args) funct_PRINT_DEBUG_MSG_LVL5_UHex(args)
#define PRINT_DEBUG_MSG_NL1  funct_PRINT_DEBUG_MSG_NL1()
#define PRINT_DEBUG_MSG_NL2  funct_PRINT_DEBUG_MSG_NL2()
#define PRINT_DEBUG_MSG_NL3  funct_PRINT_DEBUG_MSG_NL3()
#define PRINT_DEBUG_MSG_NL4  funct_PRINT_DEBUG_MSG_NL4()
#define PRINT_DEBUG_MSG_NL5  funct_PRINT_DEBUG_MSG_NL5()
#elif DEBUG_MSG_LVL == 4
#define PRINT_DEBUG_MSG_LVL1(args) funct_PRINT_DEBUG_MSG_LVL1(funct_name, args)
#define PRINT_DEBUG_MSG_LVL2(args) funct_PRINT_DEBUG_MSG_LVL2(funct_name, args)
#define PRINT_DEBUG_MSG_LVL3(args) funct_PRINT_DEBUG_MSG_LVL3(funct_name, args)
#define PRINT_DEBUG_MSG_LVL4(args) funct_PRINT_DEBUG_MSG_LVL4(funct_name, args)
#define PRINT_DEBUG_MSG_LVL5(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL1_Raw(args) funct_PRINT_DEBUG_MSG_LVL1_Raw(args)
#define PRINT_DEBUG_MSG_LVL2_Raw(args) funct_PRINT_DEBUG_MSG_LVL2_Raw(args)
#define PRINT_DEBUG_MSG_LVL3_Raw(args) funct_PRINT_DEBUG_MSG_LVL3_Raw(args)
#define PRINT_DEBUG_MSG_LVL4_Raw(args) funct_PRINT_DEBUG_MSG_LVL4_Raw(args)
#define PRINT_DEBUG_MSG_LVL5_Raw(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL1_UDec(args) funct_PRINT_DEBUG_MSG_LVL1_UDec(args)
#define PRINT_DEBUG_MSG_LVL2_UDec(args) funct_PRINT_DEBUG_MSG_LVL2_UDec(args)
#define PRINT_DEBUG_MSG_LVL3_UDec(args) funct_PRINT_DEBUG_MSG_LVL3_UDec(args)
#define PRINT_DEBUG_MSG_LVL4_UDec(args) funct_PRINT_DEBUG_MSG_LVL4_UDec(args)
#define PRINT_DEBUG_MSG_LVL5_UDec(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL1_UHex(args) funct_PRINT_DEBUG_MSG_LVL1_UHex(args)
#define PRINT_DEBUG_MSG_LVL2_UHex(args) funct_PRINT_DEBUG_MSG_LVL2_UHex(args)
#define PRINT_DEBUG_MSG_LVL3_UHex(args) funct_PRINT_DEBUG_MSG_LVL3_UHex(args)
#define PRINT_DEBUG_MSG_LVL4_UHex(args) funct_PRINT_DEBUG_MSG_LVL4_UHex(args)
#define PRINT_DEBUG_MSG_LVL5_UHex(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_NL1  funct_PRINT_DEBUG_MSG_NL1()
#define PRINT_DEBUG_MSG_NL2  funct_PRINT_DEBUG_MSG_NL2()
#define PRINT_DEBUG_MSG_NL3  funct_PRINT_DEBUG_MSG_NL3()
#define PRINT_DEBUG_MSG_NL4  funct_PRINT_DEBUG_MSG_NL4()
#define PRINT_DEBUG_MSG_NL5 /* release version, do nothing */
#elif DEBUG_MSG_LVL == 3
#define PRINT_DEBUG_MSG_LVL1(args) funct_PRINT_DEBUG_MSG_LVL1(funct_name, args)
#define PRINT_DEBUG_MSG_LVL2(args) funct_PRINT_DEBUG_MSG_LVL2(funct_name, args)
#define PRINT_DEBUG_MSG_LVL3(args) funct_PRINT_DEBUG_MSG_LVL3(funct_name, args)
#define PRINT_DEBUG_MSG_LVL4(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL1_Raw(args) funct_PRINT_DEBUG_MSG_LVL1_Raw(args)
#define PRINT_DEBUG_MSG_LVL2_Raw(args) funct_PRINT_DEBUG_MSG_LVL2_Raw(args)
#define PRINT_DEBUG_MSG_LVL3_Raw(args) funct_PRINT_DEBUG_MSG_LVL3_Raw(args)
#define PRINT_DEBUG_MSG_LVL4_Raw(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5_Raw(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL1_UDec(args) funct_PRINT_DEBUG_MSG_LVL1_UDec(args)
#define PRINT_DEBUG_MSG_LVL2_UDec(args) funct_PRINT_DEBUG_MSG_LVL2_UDec(args)
#define PRINT_DEBUG_MSG_LVL3_UDec(args) funct_PRINT_DEBUG_MSG_LVL3_UDec(args)
#define PRINT_DEBUG_MSG_LVL4_UDec(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5_UDec(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL1_UHex(args) funct_PRINT_DEBUG_MSG_LVL1_UHex(args)
#define PRINT_DEBUG_MSG_LVL2_UHex(args) funct_PRINT_DEBUG_MSG_LVL2_UHex(args)
#define PRINT_DEBUG_MSG_LVL3_UHex(args) funct_PRINT_DEBUG_MSG_LVL3_UHex(args)
#define PRINT_DEBUG_MSG_LVL4_UHex(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5_UHex(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_NL1  funct_PRINT_DEBUG_MSG_NL1()
#define PRINT_DEBUG_MSG_NL2  funct_PRINT_DEBUG_MSG_NL2()
#define PRINT_DEBUG_MSG_NL3  funct_PRINT_DEBUG_MSG_NL3()
#define PRINT_DEBUG_MSG_NL4 /* release version, do nothing */
#define PRINT_DEBUG_MSG_NL5 /* release version, do nothing */
#elif DEBUG_MSG_LVL == 2
#define PRINT_DEBUG_MSG_LVL1(args) funct_PRINT_DEBUG_MSG_LVL1(funct_name, args)
#define PRINT_DEBUG_MSG_LVL2(args) funct_PRINT_DEBUG_MSG_LVL2(funct_name, args)
#define PRINT_DEBUG_MSG_LVL3(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL4(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL1_Raw(args) funct_PRINT_DEBUG_MSG_LVL1_Raw(args)
#define PRINT_DEBUG_MSG_LVL2_Raw(args) funct_PRINT_DEBUG_MSG_LVL2_Raw(args)
#define PRINT_DEBUG_MSG_LVL3_Raw(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL4_Raw(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5_Raw(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL1_UDec(args) funct_PRINT_DEBUG_MSG_LVL1_UDec(args)
#define PRINT_DEBUG_MSG_LVL2_UDec(args) funct_PRINT_DEBUG_MSG_LVL2_UDec(args)
#define PRINT_DEBUG_MSG_LVL3_UDec(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL4_UDec(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5_UDec(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL1_UHex(args) funct_PRINT_DEBUG_MSG_LVL1_UHex(args)
#define PRINT_DEBUG_MSG_LVL2_UHex(args) funct_PRINT_DEBUG_MSG_LVL2_UHex(args)
#define PRINT_DEBUG_MSG_LVL3_UHex(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL4_UHex(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5_UHex(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_NL1  funct_PRINT_DEBUG_MSG_NL1()
#define PRINT_DEBUG_MSG_NL2  funct_PRINT_DEBUG_MSG_NL2()
#define PRINT_DEBUG_MSG_NL3 /* release version, do nothing */
#define PRINT_DEBUG_MSG_NL4 /* release version, do nothing */
#define PRINT_DEBUG_MSG_NL5 /* release version, do nothing */
#elif DEBUG_MSG_LVL == 1
#define PRINT_DEBUG_MSG_LVL1(args) funct_PRINT_DEBUG_MSG_LVL1(funct_name, args)
#define PRINT_DEBUG_MSG_LVL2(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL3(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL4(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL1_Raw(args) funct_PRINT_DEBUG_MSG_LVL1_Raw(args)
#define PRINT_DEBUG_MSG_LVL2_Raw(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL3_Raw(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL4_Raw(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5_Raw(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL1_UDec(args) funct_PRINT_DEBUG_MSG_LVL1_UDec(args)
#define PRINT_DEBUG_MSG_LVL2_UDec(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL3_UDec(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL4_UDec(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5_UDec(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL1_UHex(args) funct_PRINT_DEBUG_MSG_LVL1_UHex(args)
#define PRINT_DEBUG_MSG_LVL2_UHex(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL3_UHex(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL4_UHex(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5_UHex(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_NL1  funct_PRINT_DEBUG_MSG_NL1()
#define PRINT_DEBUG_MSG_NL2 /* release version, do nothing */
#define PRINT_DEBUG_MSG_NL3 /* release version, do nothing */
#define PRINT_DEBUG_MSG_NL4 /* release version, do nothing */
#define PRINT_DEBUG_MSG_NL5 /* release version, do nothing */
#else
#define PRINT_DEBUG_MSG_LVL1(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL2(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL3(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL4(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5(args) /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL1_Raw(args)  /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL2_Raw(args)  /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL3_Raw(args)  /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL4_Raw(args)  /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5_Raw(args)  /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL1_UDec(args)  /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL2_UDec(args)  /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL3_UDec(args)  /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL4_UDec(args)  /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5_UDec(args)  /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL1_UHex(args)  /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL2_UHex(args)  /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL3_UHex(args)  /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL4_UHex(args)  /* release version, do nothing */
#define PRINT_DEBUG_MSG_LVL5_UHex(args)  /* release version, do nothing */
#define PRINT_DEBUG_MSG_NL1   /* release version, do nothing */
#define PRINT_DEBUG_MSG_NL2   /* release version, do nothing */
#define PRINT_DEBUG_MSG_NL3   /* release version, do nothing */
#define PRINT_DEBUG_MSG_NL4   /* release version, do nothing */
#define PRINT_DEBUG_MSG_NL5   /* release version, do nothing */
#endif

#endif /* _DEBUG_MSGS_HOST_H_ */
