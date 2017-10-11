/*
 *********************************************************************************************************
 *
 * freeport communication routines
 *
 * (c) Frank Wörnle, 2010
 * 
 *********************************************************************************************************
 *
 * File              : mc_freePortComms.h
 * Version           : 1.01
 * Last modification : 24.07.2010, Frank Wörnle
 *
 *********************************************************************************************************
 */

#ifndef _MC_FREEPORTCOMMS_H_
#define _MC_FREEPORTCOMMS_H_



/*
 *********************************************************************************************************
 *    DEFINES
 *********************************************************************************************************
 */

/* maximum number of user communication channels */
#define MAX_FREECOM_CHANNELS          5

/* currently limited to 50 data bytes (FW-08-06) */
#define MAX_FREECOM_BUF_SIZE          50

/* COM1, COM2, COM3, COM4 */
#define MAX_NUM_COM_PORTS             4

/* size of host sided freeport communication buffer */
#define FREEPORT_HOST_BUF_SIZE        (MAX_FREECOM_CHANNELS * MAX_FREECOM_BUF_SIZE + 200)



/*
 *********************************************************************************************************
 *    DATA TYPES
 *********************************************************************************************************
 */

#ifndef _S0_USERTEL_
#ifndef _MC_RADIOCOMMS_H_

/* 
 * freeport/radiocomms/usertels buffer variables all use the following admin structure:
 */
typedef struct myUsrBuf_tag {

        tINT16U    buffer_full;
        tINT16U    header_received;
        tINT16U    access_count;
        tINT16U    buf_size;
        tINT8U    *buf;

        } myUsrBuf;

#endif  /* _MC_RADIOCOMMS_H_ */
#endif  /* _S0_USERTEL_ */



/*
 *********************************************************************************************************
 *    HOST SIDED FREEPORT COMMUNICATION DATA TYPES
 *********************************************************************************************************
 */

#ifdef MATLAB_MEX_FILE

#ifdef EXTERN_C
    /* compiler 'lcc' runs into errors when macro 'EXTERN_C' is defined... */
    #undef EXTERN_C
#endif

#include <windows.h>                   /* HANDLE */

/* port access - host only (COM) */
typedef struct myCOMPort_tag {

        tINT8U     access_count;
        HANDLE     hCom;
        
        } myCOMPort;


#endif  /* MATLAB_MEX_FILE */



/*
 *********************************************************************************************************
 *    DECLARATION OF GLOBAL VARIABLES
 *********************************************************************************************************
 */

/* 
 * global freeport communication admin variables
 * (defined in 'mc_main.c')
 */
extern myUsrBuf   *freecomTelBuf[];



/*
 *********************************************************************************************************
 *    DECLARATION OF PUBLIC FUNCTIONS
 *********************************************************************************************************
 */

extern tVOID       FreePort_Init       (tINT16U port, tINT8U baudrate);
extern tVOID       process_fpdata_SCI0 (tINT16U raw_data);
extern tVOID       process_fpdata_SCI1 (tINT16U raw_data);
extern tVOID       put_fpdata_SCI0     (tINT8U channel, tINT8U size, tINT8U dtype, tINT8U *src, tINT8U raw_data);
extern tVOID       put_fpdata_SCI1     (tINT8U channel, tINT8U size, tINT8U dtype, tINT8U *src, tINT8U raw_data);



#endif  /* _MC_FREEPORTCOMMS_H_ */
