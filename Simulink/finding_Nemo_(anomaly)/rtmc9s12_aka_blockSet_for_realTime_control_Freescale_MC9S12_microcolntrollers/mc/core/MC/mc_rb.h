#ifndef _RB_H_
#define _RB_H_

/** 
 * Define the rb struct.
 * Note that it's expecting an array of length 256.
 */
typedef struct {
  unsigned char *start;
  unsigned char in;
  unsigned char out;
  unsigned char nElements;    /* keep a counter of how many elements are currently available... fw-09-06 */
} rbType;

#define RB_INIT(b, s) \
( (b)->in = (b)->out = 0, (b)->nElements = 0, \
  (b)->start = s )

#define RB_EMPTY(b) ( (b)->in == (b)->out )

#define RB_FULL(b)  ( (b)->in + 1 == (b)->out )

#define RB_PUSH(b, v) \
	(RB_FULL(b) ? 1 : \
	 ((b)->start[(b)->in++] = (v), (b)->nElements++, 0) \
	)

#define RB_POP(b, v) \
	(RB_EMPTY(b) ? 1: \
	 (*v = (b)->start[(b)->out++], (b)->nElements--, 0) \
	)

#define RB_PEEK(b, v) \
	(RB_EMPTY(b) ? 1: \
	 (*v = (b)->start[(b)->out], 0) \
	)

#define RB_CLEAN(b) ( (b)->out = (b)->in = (b)->nElements = 0 )

#define RB_SET_OUT(b, o) ( (b)->out = o )

#define RB_ELEMENTS(b) ( (b)->nElements )

#endif // #define _RB_H_
