/*
 *********************************************************************************************************
 *
 * radio module communication support routines
 *
 * (c) Frank Wörnle, 2010
 * 
 *********************************************************************************************************
 *
 * File              : mc_radioComms.h
 * Version           : 1.01
 * Last modification : 24.07.2010, Frank Wörnle
 *
 *********************************************************************************************************
 */

#ifndef _MC_RADIOCOMMS_H_
#define _MC_RADIOCOMMS_H_



/*
 *********************************************************************************************************
 *    DEFINES
 *********************************************************************************************************
 */

/* maximum number of radio communication channels */
#define MAX_RADIOCOM_CHANNELS         10 * CLIENT_COUNT

/* currently limited to 32 data bytes (FW-09-06) */
#define MAX_RADIOCOM_BUF_SIZE         32



/*
 *********************************************************************************************************
 *    DATA TYPES
 *********************************************************************************************************
 */

#ifndef _S0_USERTEL_
#ifndef _MC_FREEPORTCOMMS_H_

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

#endif  /* _MC_FREEPORTCOMMS_H_ */
#endif  /* _S0_USERTEL_ */



/*
 *********************************************************************************************************
 *    DECLARATION OF GLOBAL VARIABLES
 *********************************************************************************************************
 */

/* 
 * declare global radio communication admin variables
 * (defined in 'mc_main.c')
 */
extern myUsrBuf   *radiocomTelBuf[];



/*
 *********************************************************************************************************
 *    DECLARATION OF PUBLIC FUNCTIONS
 *********************************************************************************************************
 */

/* client */
extern tVOID        process_RadioCommData_client  ( tINT16U    raw_data, 
                                                    tINT8U     client        );

extern tVOID        put_RFdata_client             ( tINT8U     channel, 
                                                    tINT8U     size, 
                                                    tINT8U     dtype, 
                                                    tINT8U    *src, 
                                                    tINT8U     raw_data      );

/* server */
extern tVOID        process_RadioCommData_server  ( tINT16U    raw_data, 
                                                    tINT8U     client        );

extern tVOID        put_RFdata_server             ( tINT8U     channel, 
                                                    tINT8U     size, 
                                                    tINT8U     dtype, 
                                                    tINT8U    *src, 
                                                    tINT8U     raw_data,
                                                    tINT8U     client        );


#endif  /* _MC_RADIOCOMMS_H_ */
