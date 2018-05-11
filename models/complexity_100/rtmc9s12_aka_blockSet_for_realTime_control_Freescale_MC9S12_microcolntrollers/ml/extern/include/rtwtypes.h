/* Copyright 2003 The MathWorks, Inc. */

/* 
 * Static rtwtypes.h to support non RTW based cases.
 *
 * adapted for rtmc9s12-target  (fw-08-10)
 */

#ifndef __RTWTYPES_H__
#define __RTWTYPES_H__

    #include "simstruc_types.h"  

    #ifndef POINTER_T
    # define POINTER_T
    typedef void * pointer_T;
    #endif
    
    /*
     * removed definition of TRUE and FALSE, as this would lead to a 
     * re-definition of these macros (stdtypes.h, included via hiware.h)
     * fw-08-10
     */

#endif  /* __RTWTYPES_H__ */
