/*
 *********************************************************************************************************
 *
 * Board Support Package, ring buffer support
 *
 * (c) Frank Wörnle, 2009
 * 
 *********************************************************************************************************
 *
 * File              : bsp_rbuf.c
 * Version           : 1.00
 * Last modification : 11.04.2010, Frank Wörnle, adapted for rtmc9s12-target
 *
 *********************************************************************************************************
 */
 

/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */

#include "bsp_dTypes.h"                            /* data typtes                        */
#include "bsp_rBuf.h"                              /* ring buffer support (typedefs)     */



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
 *    VARIABLES
 *********************************************************************************************************
 */



/*
 *********************************************************************************************************
 *    FUNCTION PROTOTYPES
 *********************************************************************************************************
 */



/*
 *********************************************************************************************************
 *    PUBLIC FUNCTIONS
 *********************************************************************************************************
 */


/* ... not to macro... (development stage) */
#if RB_USE_MACROS == 0

/* 
 ************************************************************************
 * non-macro version of the ring buffer functionality (development stage)
 ************************************************************************
 */

 
/* Initialization of the ring buffer (administration structure) */
tVOID RB_INIT(rbAdminStructType *rb, rbBufElType *start, tINT16U number) {
    
    rb->rb_in = rb->rb_out = rb->rb_start = start;
    rb->rb_end = &(rb->rb_start[number]);
    rb->rb_nElements = 0;
    
}


/* 
 * Macro ensuring the buffer is wrapped when needed. Use this macro before
 * attempting to access the next slot of a buffer which fills in 'foreward'
 * direction (= usually).
 */
rbBufElType *RB_SLOT(rbAdminStructType *rb, rbBufElType *slot) {
    
    return ( (slot == rb->rb_end) ? rb->rb_start : slot );
    
}


/* 
 * Macro to determine if the buffer is empty. The buffer is empty when the
 * current read position (rb_out) coincides with the current write position (rb_in).
 */
tBOOLEAN RB_EMPTY(rbAdminStructType *rb) {

    return ( rb->rb_in == rb->rb_out );
    
}


/* 
 * Macro to determine if the buffer is full. The buffer is full when the 
 * next write position (rb_in + 1) coincides with the current read position (rb_out)
 */
tBOOLEAN RB_FULL(rbAdminStructType *rb) {

    return ( RB_SLOT(rb, rb->rb_in + 1) == rb->rb_out );

}


/* Macro to purge all contents of the buffer */
tVOID RB_CLEAN(rbAdminStructType *rb) {

    rb->rb_out = rb->rb_in;
    rb->rb_nElements = 0;
    
}


/* Macro accessing the next write (PUSH) position */
rbBufElType *RB_PUSHSLOT(rbAdminStructType *rb) {

    return rb->rb_in;
    
}
    

/* Macro accessing the next read (POP) position */
rbBufElType *RB_POPSLOT(rbAdminStructType *rb) {

    return rb->rb_out;
    
}
    

/* Macro advancing the current write (PUSH) position by one element (foreward) */
tVOID RB_PUSHADVANCE(rbAdminStructType *rb) {

    rb->rb_in = RB_SLOT(rb, rb->rb_in + 1);
    
}


/* Macro advancing the current read (POP) position by one element (foreward) */
tVOID RB_POPADVANCE(rbAdminStructType *rb) {

    rb->rb_out = RB_SLOT(rb, rb->rb_out + 1);
    
}


/* Macro increasing the current buffer element counter by one (element) */
tVOID RB_INC(rbAdminStructType *rb) {

    rb->rb_nElements++;
    
}


/* Macro decreasing the current buffer element counter by one (element) */
tVOID RB_DEC(rbAdminStructType *rb) {

    rb->rb_nElements--;
    
}


/* Macro returning the current number of elements in the buffer */
tINT16U RB_ELEMENTS(rbAdminStructType *rb) {

    return rb->rb_nElements;
    
}


/* 
 * Macro writing (PUSHing) an element to the ring buffer. The write position is
 * advanced by one element and the number of elements is increased by one (element).
 * The macro returns '0' upon success, '-1' when the buffer is full.
 */
tINT16S RB_PUSH(rbAdminStructType *rb, rbBufElType v) {

    return ( RB_FULL(rb)  ? -1 : ( *RB_PUSHSLOT(rb) = (v), RB_PUSHADVANCE(rb), RB_INC(rb), 0 ) );
    
}


/* 
 * Macro reading (POPing) an element from the ring buffer. The read position is
 * advanced by one element (= the element is taken off the buffer) and the number
 * of elements is decreased by one (element). The macro returns '0' upon success, 
 * '-1' if the buffer is empty.
 */
tINT16S RB_POP(rbAdminStructType *rb, rbBufElType *v) {

    return ( RB_EMPTY(rb) ? -1 : ( *v = *RB_POPSLOT(rb), RB_POPADVANCE(rb), RB_DEC(rb), 0 ) );
    
}


/* 
 * Macro peeking at an element of the ring buffer. If the supplied tail offset is '0' the macro 
 * reads from the current tail position of the buffer. The updated tail offset is returned so 
 * that a subsequent call will return the next value from the buffer. The return value of this 
 * macro is the current number of bytes on the buffer.
 */
tINT16U RB_PEEK(rbAdminStructType *rb, rbBufElType *retVal, tINT16U *tailOffset) {

    if (!RB_EMPTY(rb)) {
    
        /* return peeked value */
        *retVal = (rbBufElType)*(RB_SLOT((rb), RB_POPSLOT(rb) + *tailOffset));
        
        /* update read position offset */
        (*tailOffset)++;
        
        /* return number of bytes on the buffer */
        return RB_ELEMENTS(rb);
        
    } else {
    
        /* empty buffer */
        return 0;
        
    }
    
}


/* 
 * Macro setting the tail pointer to a new value. This macro can be used to remove (erroneous) bytes
 * from the ring buffer. The offset (tailOffset) is assumed to be positive.
 */
tVOID RB_MOVETAIL(rbAdminStructType *rb, tINT16U tailOffset) {
    
    /* remove elements, one by one */
    while ((tailOffset > 0) && (tailOffset < RB_ELEMENTS(rb))) {
        
        RB_POPADVANCE(rb);
        RB_DEC(rb);
        tailOffset--;
        
    }

}


#endif  /* RB_USE_MACROS */
