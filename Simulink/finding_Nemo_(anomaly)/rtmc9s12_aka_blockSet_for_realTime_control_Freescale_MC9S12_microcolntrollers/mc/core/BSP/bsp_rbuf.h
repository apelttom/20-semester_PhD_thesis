/*
 *********************************************************************************************************
 *
 * Board Support Package, ring buffer support
 *
 * (c) Frank Wörnle, 2009
 * 
 *********************************************************************************************************
 *
 * File              : bsp_rbuf.h
 * Version           : 1.00
 * Last modification : 18.04.2009, Frank Wörnle, initial definition of ring buffer macros
 *
 *********************************************************************************************************
 */
 
#ifndef _BSP_RBUF_H_
#define _BSP_RBUF_H_


/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */


/*
 *********************************************************************************************************
 *    PUBLIC TYPEDEFS
 *********************************************************************************************************
 */

/* 
 * Macro for the definition of the ring buffer administration structure  --  doing this via 
 * (yet) a(nother) macro allows for the definition of ring buffers of arbitrary data types
 */
#define RB_TYPEDEF(typename, type) \
    typedef    struct RB_AdminStruct_tag { \
                  type    *rb_start; \
                  type    *rb_end; \
                  type    *rb_in; \
                  type    *rb_out; \
                  tINT16U  rb_nElements; \
               } typename


/* 
 * typedef of the ring buffer admin structure for a buffer of element type 'tINT8U'.
 *
 * This definition might seem overly complicated, but this indirection is used below
 * to facilitate switching between 'macronized' ring buffer access (production code)
 * and regular access via function calls (development stage, debugging).
 *
 */
typedef tINT8U rbBufElType;
RB_TYPEDEF(rbAdminStructType, rbBufElType);



/*
 *********************************************************************************************************
 *    PUBLIC MACROS
 *********************************************************************************************************
 */

/* 
 * enable/disable macronized version of ring buffer access. During development, avoid using
 * the ring buffer macros.
 */
#define RB_USE_MACROS  1




/* To macro or not... ? */
#if RB_USE_MACROS == 1


/* ...to macro! */


/* 
 ************************************************************************
 * marcronized version of the ring buffer functionality (production code)
 ************************************************************************
 */


/* Initialization of the ring buffer administration structure */
#define RB_INIT(rb, start, number) \
    ( (rb)->rb_in = (rb)->rb_out = (rb)->rb_start = start, \
      (rb)->rb_end = &((rb)->rb_start[number]), \
      (rb)->rb_nElements = 0 )


/* 
 * Macro ensuring the buffer is wrapped when needed. Use this macro before
 * attempting to access the next slot of a buffer which fills in 'foreward'
 * direction (= usually).
 */
#define RB_SLOT(rb, slot) \
    ( (slot) == (rb)->rb_end ? (rb)->rb_start : (slot) )


/* 
 * Macro ensuring the buffer is wrapped when needed. Use this macro before
 * attempting to access the next slot of a buffer which fills in 'backward'
 * direction (= rarely).
 */
#define RB_SLOTBEG(rb, slot) \
    ( (slot) < (rb)->rb_start ? (rb)->rb_end-1 : (slot) )


/* 
 * Macro to determine if the buffer is empty. The buffer is empty when the
 * current read position (rb_out) coincides with the current write position (rb_in).
 */
#define RB_EMPTY(rb) \
    ( (rb)->rb_in == (rb)->rb_out )


/* 
 * Macro to determine if the buffer is full. The buffer is full when the 
 * next write position (rb_in + 1) coincides with the current read position (rb_out)
 */
#define RB_FULL(rb)  \
    ( RB_SLOT(rb, (rb)->rb_in + 1) == (rb)->rb_out )


/* Macro to purge all contents of the buffer */
#define RB_CLEAN(rb) \
    ( (rb)->rb_out = (rb)->rb_in, \
      (rb)->rb_nElements = 0 )


/* Macro accessing the next write (PUSH) position */
#define RB_PUSHSLOT(rb) \
    (rb)->rb_in
    

/* Macro accessing the next read (POP) position */
#define RB_POPSLOT(rb) \
    (rb)->rb_out
    

/* 
 * Macro advancing the current write (PUSH) position by one element (foreward).
 * This also increases the number of elements in the buffer by one (element).
 */
#define RB_PUSHADVANCE(rb) \
    (rb)->rb_in = RB_SLOT((rb), (rb)->rb_in + 1)


/* Macro advancing the current read (POP) position by one element (foreward) */
#define RB_POPADVANCE(rb) \
    (rb)->rb_out = RB_SLOT((rb), (rb)->rb_out + 1)


/* Macro increasing the current buffer element counter by one (element) */
#define RB_INC(rb) \
    (rb)->rb_nElements++


/* Macro decreasing the current buffer element counter by one (element) */
#define RB_DEC(rb) \
    (rb)->rb_nElements--


/* Macro returning the current number of elements in the buffer */
#define RB_ELEMENTS(rb) \
    (rb)->rb_nElements


/* 
 * Macro writing (PUSHing) an element to the ring buffer. The write position is
 * advanced by one element and the number of elements is increased by one (element).
 * The macro returns '0' upon success, '-1' when the buffer is full.
 */
#define RB_PUSH(rb, v) \
    RB_FULL(rb) ? -1 : ( *RB_PUSHSLOT(rb) = (v), RB_PUSHADVANCE(rb), RB_INC(rb), 0 )

/* 
 * Macro reading (POPing) an element from the ring buffer. The read position is
 * advanced by one element (= the element is taken off the buffer) and the number
 * of elements is decreased by one (element). The macro returns '0' upon success, 
 * '-1' if the buffer is empty.
 */
#define RB_POP(rb, v) \
    RB_EMPTY(rb) ? -1 : ( *v = *RB_POPSLOT(rb), RB_POPADVANCE(rb), RB_DEC(rb), 0 )



/* 
 * Macro writing (PUSHing) an element to the ring buffer. The write position is
 * then decreased by one element (i. e. the buffer fills in backward direction).
 * The macro returns '0' upon success, '-1' when the buffer is full.
 * ... note: this macro is rarely used.
 */
#define RB_PUSHMINUS(rb, v) \
    RB_EMPTY(rb) ? -1 : ( (rb)->rb_in = RB_SLOTBEG((rb), (rb)->rb_in - 1), *v = *(rb)->rb_in, RB_INC(rb), 0 )


/* 
 * Macro peeking at an element of the ring buffer. If the supplied tail offset is '0' the macro 
 * reads from the current tail position of the buffer. The updated tail offset is returned so 
 * that a subsequent call will return the next value from the buffer. The return value of this 
 * macro is the current number of bytes on the buffer.
 */
#define RB_PEEK(rb, retVal, tailOffset) \
    RB_EMPTY(rb) ? 0 : ( *retVal = (rbBufElType)*(RB_SLOT((rb), RB_POPSLOT(rb) + *tailOffset)), (*tailOffset)++, RB_ELEMENTS(rb) )


/* 
 * Macro setting the tail pointer to a new value. This macro can be used to remove (erroneous) bytes
 * from the ring buffer. The offset (tailOffset) is assumed to be positive.
 */
#define RB_MOVETAIL(rb, tailOffset) \
    while ((tailOffset > 0) && (tailOffset < RB_ELEMENTS(rb))) { RB_POPADVANCE(rb); RB_DEC(rb); tailOffset--; }

#endif  /* RB_USE_MACROS */





/*
 *********************************************************************************************************
 *    DECLARATION OF PUBLIC FUNCTIONS
 *********************************************************************************************************
 */


/* To macro or not... ? */
#if RB_USE_MACROS == 0


/* ... not to macro! */


/* 
 ************************************************************************
 * non-macro version of the ring buffer functionality (development stage)
 ************************************************************************
 */

extern tVOID         RB_INIT(rbAdminStructType *rb, rbBufElType *start, tINT16U number);
extern rbBufElType  *RB_SLOT(rbAdminStructType *rb, rbBufElType *slot);
extern tBOOLEAN      RB_EMPTY(rbAdminStructType *rb);
extern tBOOLEAN      RB_FULL(rbAdminStructType *rb);
extern tVOID         RB_CLEAN(rbAdminStructType *rb);
extern rbBufElType  *RB_PUSHSLOT(rbAdminStructType *rb);
extern rbBufElType  *RB_POPSLOT(rbAdminStructType *rb);
extern tVOID         RB_PUSHADVANCE(rbAdminStructType *rb);
extern tVOID         RB_POPADVANCE(rbAdminStructType *rb);
extern tVOID         RB_INC(rbAdminStructType *rb);
extern tVOID         RB_DEC(rbAdminStructType *rb);
extern tINT16U       RB_ELEMENTS(rbAdminStructType *rb);
extern tINT16S       RB_PUSH(rbAdminStructType *rb, rbBufElType v);
extern tINT16S       RB_POP(rbAdminStructType *rb, rbBufElType *v);
extern tINT16U       RB_PEEK(rbAdminStructType *rb, rbBufElType *v, tINT16U *tailOffset);
extern tVOID         RB_MOVETAIL(rbAdminStructType *rb, tINT16U tailOffset);

#endif  /* RB_USE_MACROS */



/*
 *********************************************************************************************************
 *    ERROR CHECKING
 *********************************************************************************************************
 */



#endif /* _BSP_RBUF_H_ */