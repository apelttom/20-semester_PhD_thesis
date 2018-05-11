/******************************************************************************/
/*                                                                            */
/* Debugging functions                                                        */
/*                                                                            */
/* Author: F. Wornle (FW-mn-yr)                                               */
/* Latest change: fw-07-07                                                    */
/*                                                                            */
/******************************************************************************/

// only include debug functions if requiredconst char *args
#if DEBUG_MSG_LVL > 0

#include <stdio.h>              /* fflush(stdio) */
#include "debugMsgs_host.h"     /* macros DEBUG_DYNAMIC etc. */

/********************/
/* Global variables */
/********************/

/* default function name (debugging only)const char *args this name is usually overridden locally  --  fw-07-07 */
#if DEBUG_MSG_LVL > 0
const char     *funct_name="Unknown Function";
#endif


/* dynamic debug level support */
#ifdef DEBUG_DYNAMIC
unsigned int   DynamicDbgMsgLvl = 0;         // 0: off, 1: level-1, 2: level-2, etc.
#endif


#ifdef DEBUG_MSGCOUNTER
// global message counter (debug)
unsigned int   msgCounter = 0;
#endif


/*=================*
 * Local functions *
 *=================*/

/* none */


/*===================*
 * Visible functions *
 *===================*/


// DEBUG_MSG_LVL 1 ========================================================
#if DEBUG_MSG_LVL >= 1

//------------------------PRINT_DEBUG_MSG_LVL1--------------------------
void funct_PRINT_DEBUG_MSG_LVL1(const char *funct_name, const char *args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=1) {

      (void)mexPrintf("[1] %s: %s", funct_name, args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("[1] %s: %s", funct_name, args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//----------------------PRINT_DEBUG_MSG_LVL1_Raw-----------------------
void funct_PRINT_DEBUG_MSG_LVL1_Raw(const char *args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=1) {

      (void)mexPrintf(args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf(args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//----------------------PRINT_DEBUG_MSG_LVL1_UDec-----------------------
void funct_PRINT_DEBUG_MSG_LVL1_UDec(unsigned int args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=1) {

      (void)mexPrintf("%u", args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("%u", args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//----------------------PRINT_DEBUG_MSG_LVL1_UHex-----------------------
void funct_PRINT_DEBUG_MSG_LVL1_UHex(unsigned int args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=1) {

      (void)mexPrintf("0x%x", args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("0x%x", args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//-------------------------PRINT_DEBUG_MSG_NL1--------------------------
void funct_PRINT_DEBUG_MSG_NL1(void) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=1) {

      (void)mexPrintf("\n");

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("\n");
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}


// DEBUG_MSG_LVL 2 ========================================================
#if DEBUG_MSG_LVL >= 2

//------------------------PRINT_DEBUG_MSG_LVL2--------------------------
void funct_PRINT_DEBUG_MSG_LVL2(const char *funct_name, const char *args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=2) {

      (void)mexPrintf("-[2] %s: %s", funct_name, args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("-[2] %s: %s", funct_name, args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//----------------------PRINT_DEBUG_MSG_LVL2_Raw-----------------------
void funct_PRINT_DEBUG_MSG_LVL2_Raw(const char *args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=2) {

      (void)mexPrintf(args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf(args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//----------------------PRINT_DEBUG_MSG_LVL2_UDec-----------------------
void funct_PRINT_DEBUG_MSG_LVL2_UDec(unsigned int args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=2) {

      (void)mexPrintf("%u", args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("%u", args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//----------------------PRINT_DEBUG_MSG_LVL2_UHex-----------------------
void funct_PRINT_DEBUG_MSG_LVL2_UHex(unsigned int args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=2) {

      (void)mexPrintf("0x%x", args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("0x%x", args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//-------------------------PRINT_DEBUG_MSG_NL2--------------------------
void funct_PRINT_DEBUG_MSG_NL2(void) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=2) {

      (void)mexPrintf("\n");

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("\n");
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}


// DEBUG_MSG_LVL 3 ========================================================
#if DEBUG_MSG_LVL >= 3

//------------------------PRINT_DEBUG_MSG_LVL3--------------------------
void funct_PRINT_DEBUG_MSG_LVL3(const char *funct_name, const char *args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=3) {

      (void)mexPrintf("--[3] %s: %s", funct_name, args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("--[3] %s: %s", funct_name, args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//----------------------PRINT_DEBUG_MSG_LVL3_Raw-----------------------
void funct_PRINT_DEBUG_MSG_LVL3_Raw(const char *args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=3) {

      (void)mexPrintf(args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf(args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//----------------------PRINT_DEBUG_MSG_LVL3_UDec-----------------------
void funct_PRINT_DEBUG_MSG_LVL3_UDec(unsigned int args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=3) {

      (void)mexPrintf("%u", args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("%u", args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//----------------------PRINT_DEBUG_MSG_LVL3_UHex-----------------------
void funct_PRINT_DEBUG_MSG_LVL3_UHex(unsigned int args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=3) {

      (void)mexPrintf("0x%x", args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("0x%x", args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//-------------------------PRINT_DEBUG_MSG_NL3--------------------------
void funct_PRINT_DEBUG_MSG_NL3(void) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=3) {

      (void)mexPrintf("\n");

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("\n");
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}


// DEBUG_MSG_LVL 4 ========================================================
#if DEBUG_MSG_LVL >= 4

//------------------------PRINT_DEBUG_MSG_LVL4--------------------------
void funct_PRINT_DEBUG_MSG_LVL4(const char *funct_name, const char *args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=4) {

      (void)mexPrintf("---[4] %s: %s", funct_name, args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("---[4] %s: %s", funct_name, args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//----------------------PRINT_DEBUG_MSG_LVL4_Raw-----------------------
void funct_PRINT_DEBUG_MSG_LVL4_Raw(const char *args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=4) {

      (void)mexPrintf(args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf(args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//----------------------PRINT_DEBUG_MSG_LVL4_UDec-----------------------
void funct_PRINT_DEBUG_MSG_LVL4_UDec(unsigned int args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=4) {

      (void)mexPrintf("%u", args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("%u", args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//----------------------PRINT_DEBUG_MSG_LVL4_UHex-----------------------
void funct_PRINT_DEBUG_MSG_LVL4_UHex(unsigned int args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=4) {

      (void)mexPrintf("0x%x", args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("0x%x", args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//-------------------------PRINT_DEBUG_MSG_NL4--------------------------
void funct_PRINT_DEBUG_MSG_NL4(void) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=4) {

      (void)mexPrintf("\n");

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("\n");
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}


// DEBUG_MSG_LVL 5 ========================================================
#if DEBUG_MSG_LVL >= 5

//------------------------PRINT_DEBUG_MSG_LVL5--------------------------
void funct_PRINT_DEBUG_MSG_LVL5(const char *funct_name, const char *args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=5) {

      (void)mexPrintf("----[5] %s: %s", funct_name, args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("----[5] %s: %s", funct_name, args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//----------------------PRINT_DEBUG_MSG_LVL5_Raw-----------------------
void funct_PRINT_DEBUG_MSG_LVL5_Raw(const char *args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=5) {

      (void)mexPrintf(args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf(args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//----------------------PRINT_DEBUG_MSG_LVL5_UDec-----------------------
void funct_PRINT_DEBUG_MSG_LVL5_UDec(unsigned int args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=5) {

      (void)mexPrintf("%u", args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("%u", args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//----------------------PRINT_DEBUG_MSG_LVL5_UHex-----------------------
void funct_PRINT_DEBUG_MSG_LVL5_UHex(unsigned int args) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=5) {

      (void)mexPrintf("0x%x", args);

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("0x%x", args);
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

//-------------------------PRINT_DEBUG_MSG_NL5--------------------------
void funct_PRINT_DEBUG_MSG_NL5(void) {

   #ifdef DEBUG_DYNAMIC
   if(DynamicDbgMsgLvl>=5) {

      (void)mexPrintf("\n");

   }
   #else /* DEBUG_DYNAMIC */
   (void)mexPrintf("\n");
   #endif  /* DEBUG_DYNAMIC */

   /* force display */
   fflush(stdout);

}

#endif /* DEBUG_MSG_LVL 5 */
#endif /* DEBUG_MSG_LVL 4 */
#endif /* DEBUG_MSG_LVL 3 */
#endif /* DEBUG_MSG_LVL 2 */
#endif /* DEBUG_MSG_LVL 1 */


#endif /* DEBUG_MSG_LVL */

