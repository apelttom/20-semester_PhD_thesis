/*
 * File: rtwtypesdef.h
 *
 * Definitions required by Real-Time Workshop generated code.
 *
 * Real-Time Workshop version: 7.4
 * Generated on: 2010-05-30 10:28:11
 *
 * adapted for rtmc9s12  --  fw-05-10
 */

#ifndef __RTWTYPESDEF_H__
#define __RTWTYPESDEF_H__
#include "tmwtypes.h"

/* This ID is used to detect inclusion of an incompatible rtwtypes.h */
#define RTWTYPES_ID_C08S16I16L32N16F1
#include "simstruc_types.h"
#ifndef POINTER_T
# define POINTER_T

typedef void * pointer_T;

#endif

/*
 * Definitions supporting external data access
 */
typedef int32_T chunk_T;
typedef uint32_T uchunk_T;

#endif  /* __RTWTYPESDEF_H__ */
