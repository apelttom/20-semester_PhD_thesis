/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ext_serial_port.h     $Revision: 1.1.6.3 $
 *
 * Abstract:
 *  Function prototypes for the External Mode Serial Port object.
 */

#ifndef __EXT_SERIAL_PORT__
#define __EXT_SERIAL_PORT__

typedef struct ExtSerialPort_tag {

    boolean_T       isLittleEndian;     /* Endianess of target. */
    boolean_T       fConnected;         /* Connected or not.    */
    
} ExtSerialPort;


extern ExtSerialPort    *ExtSerialPortCreate            (void);
extern void              ExtSerialPortDestroy           (ExtSerialPort    *portDev);
extern boolean_T         ExtSerialPortConnect           (ExtSerialPort    *portDev,
                                                         uint16_T          portNum,
                                                         uint32_T          baudRate);
extern boolean_T         ExtSerialPortDisconnect        (ExtSerialPort    *portDev);
extern boolean_T         ExtSerialPortSetData           (ExtSerialPort    *portDev,
                                                         uint8_T          *data,
                                                         uint32_T          size,
                                                         uint32_T         *bytesWritten);
extern boolean_T         ExtSerialPortDataPending       (ExtSerialPort    *portDev,
                                                         int32_T          *bytesPending);
extern boolean_T         ExtSerialPortGetRawChar        (ExtSerialPort    *portDev,
                                                         uint8_T          *c,
                                                         uint32_T         *bytesRead);
extern boolean_T         ExtSerialPortPeekRawChar       (ExtSerialPort    *portDev,
                                                         uint8_T          *c,
                                                         uint_T           *myTailOffset);
extern void              ExtSerialPortMoveRBTail        (uint16_T          tailOffset);

#if DEBUG_MSG_LVL > 0
extern void              ExtSerialPortPeekRB            (uint16_T          nBytesToDisplay);
#endif


#endif /* __EXT_SERIAL_PORT__ */

/* [EOF] ext_serial_port.h */
