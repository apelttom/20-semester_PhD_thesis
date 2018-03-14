#include "__cf_Mathematica_model.h"
#ifndef RTW_HEADER_Mathematica_model_acc_private_h_
#define RTW_HEADER_Mathematica_model_acc_private_h_
#include "rtwtypes.h"
#include "multiword_types.h"
#if !defined(ss_VALIDATE_MEMORY)
#define ss_VALIDATE_MEMORY(S, ptr)   if(!(ptr)) {\
  ssSetErrorStatus(S, RT_MEMORY_ALLOCATION_ERROR);\
  }
#endif
#if !defined(rt_FREE)
#if !defined(_WIN32)
#define rt_FREE(ptr)   if((ptr) != (NULL)) {\
  free((ptr));\
  (ptr) = (NULL);\
  }
#else
#define rt_FREE(ptr)   if((ptr) != (NULL)) {\
  free((void *)(ptr));\
  (ptr) = (NULL);\
  }
#endif
#endif
#ifndef __RTWTYPES_H__
#error This file requires rtwtypes.h to be included
#endif
void Mathematica_model_acc_BINARYSEARCH_real_T ( uint32_T * piLeft , uint32_T
* piRght , real_T u , const real_T * pData , uint32_T iHi ) ; void
Mathematica_model_acc_LookUp_real_T_real_T ( real_T * pY , const real_T *
pYData , real_T u , const real_T * pUData , uint32_T iHi ) ; extern real_T
look1_binlxpw ( real_T u0 , const real_T bp0 [ ] , const real_T table [ ] ,
uint32_T maxIndex ) ; extern uint32_T plook_u32d_bincka ( real_T u , const
real_T bp [ ] , uint32_T maxIndex ) ; extern uint32_T binsearch_u32d ( real_T
u , const real_T bp [ ] , uint32_T startIndex , uint32_T maxIndex ) ;
#endif
