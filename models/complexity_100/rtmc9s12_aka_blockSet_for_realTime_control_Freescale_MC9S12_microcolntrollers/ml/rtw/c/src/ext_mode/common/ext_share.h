/* File: ext_share.h
 * Absract:
 *    External mode shared data structures used by the external communication
 *    mex link, the generated code, and Simulink.
 *
 * Copyright 1994-2005 The MathWorks, Inc.
 *
 * $Revision: 1.14.4.6 $
 */

/* 
 * Adapted for rtmc9s12-Target, fw-09-7
 */

#ifndef __EXTSHARE__
#define __EXTSHARE__

/* defining macro 'TXactiveControl' enables host based flow control via target variable 'TXactive'  --  fw-07-07 */
//#define TXactiveControl


typedef enum { 
    /*================================
     * Packets/actions to target.
     *==============================*/

    /* connection actions (0 - 3)*/
    EXT_CONNECT,
    EXT_DISCONNECT_REQUEST,
    EXT_DISCONNECT_REQUEST_NO_FINAL_UPLOAD,
    EXT_DISCONNECT_CONFIRMED,

    /* parameter upload/download actions (4 - 5) */
    EXT_SETPARAM,
    EXT_GETPARAMS,

    /* data upload actions (6 - 9) */
    EXT_SELECT_SIGNALS,
    EXT_SELECT_TRIGGER,
    EXT_ARM_TRIGGER,
    EXT_CANCEL_LOGGING,

    /* model control actions (10 - 14)*/
    EXT_MODEL_START,
    EXT_MODEL_STOP,
    EXT_MODEL_PAUSE,
    EXT_MODEL_STEP,
    EXT_MODEL_CONTINUE,

    /* data request actions (15) */
    EXT_GET_TIME,

    /*================================
     * Packets/actions from target.
     *==============================*/
    
    /* responses (16 - 30) */
    EXT_CONNECT_RESPONSE,   /* must not be 0! */
    EXT_DISCONNECT_REQUEST_RESPONSE,
    EXT_SETPARAM_RESPONSE,
    EXT_GETPARAMS_RESPONSE,
    EXT_MODEL_SHUTDOWN,
    EXT_GET_TIME_RESPONSE,
    EXT_MODEL_START_RESPONSE,
    EXT_MODEL_PAUSE_RESPONSE,
    EXT_MODEL_STEP_RESPONSE,
    EXT_MODEL_CONTINUE_RESPONSE,
    EXT_UPLOAD_LOGGING_DATA,
    EXT_SELECT_SIGNALS_RESPONSE,
    EXT_SELECT_TRIGGER_RESPONSE,
    EXT_ARM_TRIGGER_RESPONSE,
    EXT_CANCEL_LOGGING_RESPONSE,

    /*
     * (31)
     * This packet is sent from the target to signal the end of a data
     * collection event (e.g., each time that the duration is reached).
     * This packet only applies to normal mode (see
     * EXT_TERMINATE_LOG_SESSION)
     */
    EXT_TERMINATE_LOG_EVENT,     

    /*
     * (32)
     * This packet is sent from the target at the end of each data logging
     * session.  This occurs either at the end of a oneshot or at the end
     * of normal mode (i.e., the last in a series of oneshots).
     */
    EXT_TERMINATE_LOG_SESSION,

    #ifdef TXactiveControl
    /* 
     * (33)
     * TXactive control (rtmc9s12-target) --  fw-07-07
     */
    EXT_DATA_UPLD_NOACK_REQUEST,
    #endif

    /* 
     * (34 or 35)
     * used to break assumed deadlock situations --  fw-07-07
     */
    EXT_BREAK_DEADLOCK,

    EXTENDED = 255          /* reserved for extending beyond 254 ID's */
    
} ExtModeAction;


typedef enum {
  STATUS_OK,
  NOT_ENOUGH_MEMORY
} ResponseStatus;

typedef enum {
  LittleEndian,
  BigEndian
} MachByteOrder;

#ifndef TARGETSIMSTATUS_DEFINED
#define TARGETSIMSTATUS_DEFINED
typedef enum {
    TARGET_STATUS_NOT_CONNECTED,
    TARGET_STATUS_WAITING_TO_START,
    TARGET_STATUS_STARTING, /* in the process of starting - host waiting 
                               for confirmation */
    TARGET_STATUS_RUNNING,
    TARGET_STATUS_PAUSED
} TargetSimStatus;
#endif

/*
 * The packet header consists of 2 32 bit unsigned ints [type, size].  size
 * is the number of bytes coming after the header.  It is always expressed
 * in target bytes.
 */
typedef struct PktHeader_tag {
    uint32_T type;  /* packet type */
    uint32_T size;  /* number of bytes to follow */
} PktHeader;
#define NUM_HDR_ELS (2)

#ifndef FALSE
enum {FALSE, TRUE};
#endif

#define NO_ERR (0)

#define EXT_NO_ERROR ((boolean_T)(0))
#define EXT_ERROR ((boolean_T)(1))

#define UNKNOWN_BYTES_NEEDED (-1)

#define PRIVATE static
#define PUBLIC


/* now also monitoring host state -- mainly to avoid comms errors due to nervous users...  fw-07-07 */
typedef enum {

    HOST_STATUS_NOT_CONNECTED,
    HOST_STATUS_CONNECTING,
    HOST_STATUS_CONNECTED,
    HOST_STATUS_NOT_ARMED,
    HOST_STATUS_ARMED,
    HOST_STATUS_RUNNING,
    HOST_STATUS_STOPPING

} HostSimStatus;


#endif /* __EXTSHARE__ */
