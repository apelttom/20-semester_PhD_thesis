/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ext_serial_pkt.h     $Revision: 1.1.6.3 $
 *
 * Abstract:
 *  Function prototypes for the External Mode Serial Packet object.
 */

#ifndef __EXT_SERIAL_PKT__
#define __EXT_SERIAL_PKT__

/*
 *********************************************************************************************************
 *    DEFINES
 *********************************************************************************************************
 */

/* ExtSerialPortDataPending... need at least 9 bytes to consider buffer contents a packet  --  fw-07-07 */
#define MIN_PACKET_SIZE  9    /* smallest packet size: ACK_PACKET (9) */
//#define MIN_PACKET_SIZE  1      /* safe assumption */

#ifndef CIRCBUFSIZE
#define CIRCBUFSIZE 2000  /* default (host) */
#endif

#ifndef FIFOBUFSIZE
#define FIFOBUFSIZE  400  /* default (host) */
#endif


/* Fixed sizes */
#define HEAD_SIZE                    2
#define TAIL_SIZE                    2
#define PACKET_TYPE_SIZE             1

/* Conform to HDLC Framing standard */
#define packet_head      ((uint8_T)0x7e)
#define packet_tail      ((uint8_T)0x03)
#define mask_character   ((uint8_T)0x20)
#define escape_character ((uint8_T)0x7d)
#define xon_character    ((uint8_T)0x13)
#define xoff_character   ((uint8_T)0x11)


enum ExtSerialPacketState {

    ESP_NoPacket, 
    ESP_InHead,
    ESP_InType,
    ESP_InSize,
    ESP_InPayload,
    ESP_InTail,
    ESP_Complete

};


typedef enum PacketTypes_tag {

    UNDEFINED_PACKET = 0,
    EXTMODE_PACKET,
    ACK_PACKET

} PacketTypeEnum;


typedef union numString_tag {

    uint32_T  num;
    uint8_T   string[sizeof(uint32_T)];

} numString;


typedef struct ExtSerialPacket_tag {

    uint8_T     head[HEAD_SIZE];
    uint8_T     PacketType;
    uint32_T    size;
    uint8_T    *Buffer;
    uint32_T    BufferSize;
    uint8_T     tail[TAIL_SIZE];
    int16_T     state;
    uint8_T    *cursor;
    uint32_T    DataCount;
    boolean_T   inQuote;

} ExtSerialPacket;


extern boolean_T SetExtSerialPacket   (ExtSerialPacket  *pkt,
                                       ExtSerialPort    *portDev);
extern boolean_T GetExtSerialPacket   (ExtSerialPacket  *pkt,
                                       ExtSerialPort    *portDev);
extern boolean_T CheckExtSerialPacket (ExtSerialPort    *portDev);
                                       
#endif /* __EXT_SERIAL_PKT__ */

/* [EOF] ext_serial_pkt.h */
