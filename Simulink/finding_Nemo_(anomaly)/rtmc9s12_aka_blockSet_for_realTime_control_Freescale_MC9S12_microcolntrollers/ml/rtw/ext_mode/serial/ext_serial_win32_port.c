/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ext_serial_win32_port.c     $Revision: 1.1.6.3 $
 *
 * Abstract:
 *  The External Mode Serial Port is a logical object providing a standard
 *  interface between the external mode code and the physical serial port.
 *  The prototypes in the 'Visible Functions' section of this file provide
 *  the consistent front-end interface to external mode code.  The
 *  implementations of these functions provide the back-end interface to the
 *  physical serial port.  This layer of abstraction allows for minimal
 *  modifications to external mode code when the physical serial port is
 *  changed.
 *
 *     ----------------------------------
 *     | Host/Target external mode code |
 *     ----------------------------------
 *                   / \
 *                  /| |\
 *                   | |
 *                   | |
 *                  \| |/
 *                   \ /  Provides a standard, consistent interface to extmode
 *     ----------------------------------
 *     | External Mode Serial Port      |
 *     ----------------------------------
 *                   / \  Function definitions specific to physical serial port
 *                  /| |\
 *                   | |
 *                   | |
 *                  \| |/
 *                   \ /
 *     ----------------------------------
 *     | HW/OS/Physical serial port     |
 *     ----------------------------------
 *
 *  See also ext_serial_pkt.c.
 *
 *
 *   Adapted for rtmc9s12-Target, fw-12-09
 */


#include <string.h>

#include "tmwtypes.h"

#include "ext_types.h"
#include "ext_share.h"
#include "ext_serial_port.h"
#include "ext_serial_pkt.h"

/***************** WIN32 SPECIFIC FUNCTIONS ***********************************/

#include <windows.h>
#include <assert.h>
#include <stdio.h>


/* macros PRINT_DEBUG_MSG_LVL1 to PRINT_DEBUG_MSG_LVL5,  fw-06-07 */
#include "debugMsgs_host.h"



/*
 *********************************************************************************************************
 *    DEFINES
 *********************************************************************************************************
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
    ( (rb)->rb_in )
    

/* Macro accessing the next read (POP) position */
#define RB_POPSLOT(rb) \
    ( (rb)->rb_out )


/* 
 * Macro advancing the current write (PUSH) position by one element (foreward).
 * This also increases the number of elements in the buffer by one (element).
 */
#define RB_PUSHADVANCE(rb) \
    ( (rb)->rb_in = RB_SLOT((rb), (rb)->rb_in + 1) )


/* Macro advancing the current read (POP) position by one element (foreward) */
#define RB_POPADVANCE(rb) \
    ( (rb)->rb_out = RB_SLOT((rb), (rb)->rb_out + 1) )


/* Macro increasing the current buffer element counter by one (element) */
#define RB_INC(rb) \
    ( (rb)->rb_nElements++ )


/* Macro decreasing the current buffer element counter by one (element) */
#define RB_DEC(rb) \
    ( (rb)->rb_nElements-- )


/* Macro returning the current number of elements in the buffer */
#define RB_ELEMENTS(rb) \
    ( (rb)->rb_nElements )


/* 
 * Macro writing (PUSHing) an element to the ring buffer. The write position is
 * advanced by one element and the number of elements is increased by one (element).
 * The macro returns '0' upon success, '-1' when the buffer is full.
 */
#define RB_PUSH(rb, v) \
    ( RB_FULL(rb)  ? -1 : ( *RB_PUSHSLOT(rb) = (v), RB_PUSHADVANCE(rb), RB_INC(rb), 0 ) )

/* 
 * Macro reading (POPing) an element from the ring buffer. The read position is
 * advanced by one element (= the element is taken off the buffer) and the number
 * of elements is decreased by one (element). The macro returns '0' upon success, 
 * '-1' if the buffer is empty.
 */
#define RB_POP(rb, v) \
    ( RB_EMPTY(rb) ? -1 : ( *v = *RB_POPSLOT(rb), RB_POPADVANCE(rb), RB_DEC(rb), 0 ) )


/* 
 * Macro peeking at an element of the ring buffer. If the supplied tail offset is '0' the macro 
 * reads from the current tail position of the buffer. The updated tail offset is returned so 
 * that a subsequent call will return the next value from the buffer. The return value of this 
 * macro is the current number of bytes on the buffer.
 */
#define RB_PEEK(rb, retVal, tailOffset) \
    ( RB_EMPTY(rb) ? 0 : ( *retVal = (rbBufElType)*(RB_SLOT((rb), RB_POPSLOT(rb) + *tailOffset)), (*tailOffset)++, RB_ELEMENTS(rb) ) )



/* size of the reception ring buffer */
//#define COM_RB_RX_BUF_SIZE      2048
#define COM_RB_RX_BUF_SIZE      20 * FIFOBUFSIZE

/* This is for the lcc compiler. */
#ifndef MAXDWORD
#define MAXDWORD                0xffffffff
#endif



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
                  type     *rb_start; \
                  type     *rb_end; \
                  type     *rb_in; \
                  type     *rb_out; \
                  uint16_T  rb_nElements; \
               } typename


/* 
 * typedef of the ring buffer admin structure for a buffer of element type 'uint8_T'.
 *
 * This definition might seem overly complicated, but this indirection is used below
 * to facilitate switching between 'macronized' ring buffer access (production code)
 * and regular access via function calls (development stage, debugging).
 *
 */
typedef uint8_T rbBufElType;
RB_TYPEDEF(rbAdminStructType, rbBufElType);




/*
 *********************************************************************************************************
 *    STATIC GLOBAL VARIABLES
 *********************************************************************************************************
 */

//PRIVATE COMMTIMEOUTS    cto_immediate   = { MAXDWORD, 0, 0, 0, 0 };
//PRIVATE COMMTIMEOUTS cto_timeout   = { MAXDWORD, MAXDWORD, 10000, 0, 0 };
PRIVATE COMMTIMEOUTS cto_timeout= {
   100,
   100,
   100,
   0,
   0
};

PRIVATE COMMTIMEOUTS cto_blocking= {
   0,
   0,
   0,
   0,
   0
};

PRIVATE DCB             dcb;
PRIVATE HANDLE          serialHandle    = INVALID_HANDLE_VALUE;

/* 
 * buffer to store packets received on the serial port of the host
 * -> this indirection allows peeking at values in the buffer without removing them
 */
PRIVATE rbAdminStructType  adminStruct_COMinBuf;
PRIVATE uint8_T            COMinBuf[COM_RB_RX_BUF_SIZE];       /* the actual ring buffer */




/*
 *********************************************************************************************************
 *    LOCAL FUNCTIONS
 *********************************************************************************************************
 */

/* Function: initDCB ===========================================================
 * Abstract:
 *  Initializes the control settings for a win32 serial communications device.
 */
PRIVATE void initDCB(uint32_T baud) {

    dcb.DCBlength       = sizeof(dcb);                   
        
    /* ---------- Serial Port Config ------- */
    dcb.BaudRate        = baud;
    dcb.Parity          = NOPARITY;
    dcb.fParity         = 0;
    dcb.StopBits        = ONESTOPBIT;
    dcb.ByteSize        = 8;
    dcb.fOutxCtsFlow    = 0;
    dcb.fOutxDsrFlow    = 0;
    dcb.fDtrControl     = DTR_CONTROL_DISABLE;
    dcb.fDsrSensitivity = 0;
    dcb.fRtsControl     = RTS_CONTROL_DISABLE;
    dcb.fOutX           = 0;
    dcb.fInX            = 0;
        
    /* ---------- Misc Parameters ---------- */
    dcb.fErrorChar      = 0;
    dcb.fBinary         = 1;
    dcb.fNull           = 0;
    dcb.fAbortOnError   = 0;
    dcb.wReserved       = 0;
    dcb.XonLim          = 2;
    dcb.XoffLim         = 4;
    dcb.XonChar         = 0x13;
    dcb.XoffChar        = 0x19;
    dcb.EvtChar         = 0;

}  /* end initDCB */


/* Function: serial_peek_byte =================================================
 * Abstract:
 *  Peeks at the specified byte in the comms line buffer / the RX ring buffer.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PRIVATE boolean_T serial_peek_byte(uint8_T   *data,
                                   uint_T    *myTailOffset) {

boolean_T error = EXT_NO_ERROR;

uint_T    nBuf;
ulong_T   bytesRead;

    // local function name... debugging only
    DEFINE_DEBUG_FNAME("serial_peek_byte")

    PRINT_DEBUG_MSG_LVL5("IN");
    PRINT_DEBUG_MSG_NL5;

    assert(serialHandle != NULL);

    /* determine number of bytes currently stored in the RX ring buffer */
    nBuf = RB_ELEMENTS(&adminStruct_COMinBuf);
    
    PRINT_DEBUG_MSG_LVL5("Found ");
    PRINT_DEBUG_MSG_LVL5_UDec((uint16_T)nBuf);
    PRINT_DEBUG_MSG_LVL5_Raw(" elements in the RX ring buffer.");
    PRINT_DEBUG_MSG_NL5;

    /* 
     * enough bytes in the RX ring buffer to retrieve peek byte from there? 
     * -> only read bytes from the RX ring buffer which we haven't read before...
     *    i. e. from '*myTailOffset + 1' to 'nBuf'
     */
    if (nBuf > *myTailOffset) {

        PRINT_DEBUG_MSG_LVL5("Retrieving RX ring buffer element number ");
        PRINT_DEBUG_MSG_LVL5_UDec((uint16_T)*myTailOffset);

        /* yes -> fetch peek byte from RX ring buffer */
        nBuf = RB_PEEK(&adminStruct_COMinBuf, data, myTailOffset);

        PRINT_DEBUG_MSG_LVL5_Raw(" : ");
        PRINT_DEBUG_MSG_LVL5_UHex((uint16_T)*data);
        PRINT_DEBUG_MSG_NL5;

        PRINT_DEBUG_MSG_LVL5("myTailOffset: ");
        PRINT_DEBUG_MSG_LVL5_UHex((uint16_T)*myTailOffset);
        PRINT_DEBUG_MSG_NL5;

        PRINT_DEBUG_MSG_LVL5("Adjusted number of elements in the RX ring buffer: ");
        PRINT_DEBUG_MSG_LVL5_UHex((uint16_T)nBuf);
        PRINT_DEBUG_MSG_NL5;

    } else {
        
        /* peek byte not yet in the RX ring buffer -> try the comms line directly */
        SetCommTimeouts(serialHandle, &cto_timeout);

        if (!ReadFile(serialHandle, data, 1L, &bytesRead, NULL)) {
        
            error = EXT_ERROR;
            goto EXIT_POINT;
            
        } else {
            
            PRINT_DEBUG_MSG_LVL5("Retrieved element from comms line buffer: ");
            PRINT_DEBUG_MSG_LVL5_UHex((uint16_T)*data);
            PRINT_DEBUG_MSG_NL5;

            /* placed byte in the RX ring buffer for later retrieval */
            if (RB_PUSH(&adminStruct_COMinBuf, *data) == -1) {
                
                PRINT_DEBUG_MSG_LVL1("Reception ring buffer full!");
                PRINT_DEBUG_MSG_NL1;
                
                error = EXT_ERROR;
                goto EXIT_POINT;
            
            }
            
            PRINT_DEBUG_MSG_LVL5("Byte pushed to RX ring buffer (for subsequent processing).");
            PRINT_DEBUG_MSG_NL5;
            
            /* adjust myTailOffset - current character already dealt with */
            *myTailOffset = *myTailOffset + 1;

            PRINT_DEBUG_MSG_LVL5("myTailOffset: ");
            PRINT_DEBUG_MSG_LVL5_UDec((uint16_T)*myTailOffset);
            PRINT_DEBUG_MSG_NL5;

        }  /* ReadFile successful */
        
    }  /* retrieve peek byte from comms line buffer */


EXIT_POINT:

    PRINT_DEBUG_MSG_LVL5("OUT, error status: ");
    PRINT_DEBUG_MSG_LVL5_UDec(error);
    PRINT_DEBUG_MSG_NL5;

    return error;

}  /* end serial_peek_byte */


/* Function: serial_get_string =================================================
 * Abstract:
 *  Attempts to get the specified number of bytes from the comm line.  The
 *  number of bytes read is returned via the 'bytesRead' parameter.  If the
 *  specified number of bytes is not read within the time out period specified
 *  in cto_timeout, an error is returned.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PRIVATE boolean_T serial_get_string(uint8_T     *data,
                                    uint32_T     size,
                                    uint32_T    *bytesRead) {

boolean_T error = EXT_NO_ERROR;
uint32_T  nBuf;
uint_T    ii;

    // local function name... debugging only
    DEFINE_DEBUG_FNAME("serial_get_string")

    assert(serialHandle != NULL);

    //PRINT_DEBUG_MSG_LVL5("IN");
    //PRINT_DEBUG_MSG_NL5;

    /* determine number of bytes currently stored in the RX ring buffer */
    nBuf = (uint32_T)RB_ELEMENTS(&adminStruct_COMinBuf);
    
    /* enough bytes in the input buffer? */
    if (nBuf >= size) {
        
        /* yes -> fetch'em from there */
        for (ii = 0; ii < size; ii++) {
            
            /* fetch next byte */
            RB_POP(&adminStruct_COMinBuf, &data[ii]);
            
        }
        
        /* set 'bytesRead' */
        *bytesRead = size;
        
    } else {
        
        /* not all required bytes have been stored in the RX ring buffer */
        if (nBuf > 0) {
            
            /* some data available in the ring buffer -> retrieve this first */
            for (ii = 0; ii < nBuf; ii++) {
                
                /* fetch next byte */
                RB_POP(&adminStruct_COMinBuf, &data[ii]);
                
            }
            
        }
            
        /* attempt to read the remaining bytes directly from the comms line buffer */
        SetCommTimeouts(serialHandle, &cto_timeout);

        if (!ReadFile(serialHandle, &data[nBuf], size - nBuf, (ulong_T *)bytesRead, NULL)) {
        
            error = EXT_ERROR;
            goto EXIT_POINT;
            
        }

        /* adjust 'bytesRead' */
        *bytesRead += nBuf;
        
    }

EXIT_POINT:

    //PRINT_DEBUG_MSG_LVL5("OUT, error status: ");
    //PRINT_DEBUG_MSG_LVL5_UDec(error);
    //PRINT_DEBUG_MSG_NL5;

    return error;

}  /* end serial_get_string */


/* Function: serial_set_string =================================================
 * Abstract:
 *  Sets (sends) the specified number of bytes on the comm line.  The number of
 *  bytes sent is returned via the 'bytesWritten' parameter.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PRIVATE boolean_T serial_set_string(uint8_T     *data,
                                    uint32_T     size,
                                    uint32_T    *bytesWritten) {

    // local function name... debugging only
    DEFINE_DEBUG_FNAME("serial_set_string")

    uint32_T    k,
                myBytesWritten;
    boolean_T   error             = EXT_NO_ERROR;

    assert(serialHandle != NULL);
    assert(data != NULL);

    #if DEBUG_MSG_LVL >= 5
    {

        PRINT_DEBUG_MSG_LVL5("");
        for (k = 0; k < size; k++) {

            PRINT_DEBUG_MSG_LVL5_Raw(" ");
            PRINT_DEBUG_MSG_LVL5_UHex(data[k]);

        }
        PRINT_DEBUG_MSG_NL5;
    }
    #endif

    /* 
     * The following call to WriteFile doesn't work properly (at least not when using LCC) 
     * for converted data (Filter, '^ 0x20') the host appears to send the original data, 
     * e.g. 0x3... this causes the target to misinterpret the received data and 
     * consequently 'hang'
     *
     * fw-06-07
     */
     #ifdef ERASE_NOT_WORKING_ORIGINAL
     if (!WriteFile(serialHandle, data , size, (ulong_T *)bytesWritten, NULL)) {

        error = EXT_ERROR;
        goto EXIT_POINT;

    }
    #endif /* ERASE_NOT_WORKING_ORIGINAL */

    /* working equivalent... fw-06-07 */
    PRINT_DEBUG_MSG_LVL5("Size = ");
    PRINT_DEBUG_MSG_LVL5_UDec(size);
    PRINT_DEBUG_MSG_NL5;
    *bytesWritten=0;
    for (k = 0; k < size; k++) {

        if (!WriteFile(serialHandle, data++, 1L, &myBytesWritten, NULL)) {

            error = EXT_ERROR;
            goto EXIT_POINT;

        }
        
        /* adjust number of bytes written */
        *bytesWritten += myBytesWritten;

    }
    PRINT_DEBUG_MSG_LVL5("BytesWritten = ");
    PRINT_DEBUG_MSG_LVL5_UDec(*bytesWritten);
    PRINT_DEBUG_MSG_NL5;

EXIT_POINT:

    return error;

}  /* end serial_set_string */


/* Function: serial_string_pending =============================================
 * Abstract:
 *  Returns, via the 'pendingBytes' arg, the number of bytes pending on the
 *  comm line.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PRIVATE boolean_T serial_string_pending(int32_T *pendingBytes) {

struct _COMSTAT     status;
ulong_T             etat;
boolean_T           error   = EXT_NO_ERROR;
int32_T             nBuf;

    assert(serialHandle != NULL);

    /* fetch number of bytes currently stored in the RX ring buffer */
    nBuf = (int32_T)RB_ELEMENTS(&adminStruct_COMinBuf);

    /* Find out how much data is available in the comms line buffer */
    if (!ClearCommError(serialHandle, &etat, &status)) {
    
        /* only return the number of bytes stored in the RX ring buffer */
        *pendingBytes = (int32_T)nBuf;
        
        error = EXT_ERROR;
        goto EXIT_POINT;
        
    } else {
    
        *pendingBytes = (int32_T)status.cbInQue;
        
    }
    
    /* total number of unprocessed bytes available */
    *pendingBytes += nBuf;


EXIT_POINT:

    return error;

}  /* end serial_string_pending */


/* Function: serial_uart_close =================================================
 * Abstract:
 *  Closes the serial port.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PRIVATE boolean_T serial_uart_close(void) {

    if (serialHandle != INVALID_HANDLE_VALUE) {
    
        CloseHandle(serialHandle);
        serialHandle = INVALID_HANDLE_VALUE;
        
    }
    
    /* reset RX buffer */
    RB_CLEAN(&adminStruct_COMinBuf);
    
    return EXT_NO_ERROR;

}  /* end serial_uart_close */


/* Function: serial_uart_init ==================================================
 * Abstract:
 *  Opens the serial port and initializes the port, baud, and DCB settings.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PRIVATE boolean_T serial_uart_init(uint16_T port, uint32_T baud) {

boolean_T   error       = EXT_NO_ERROR;
boolean_T   closeFile   = false;

    initDCB(baud);

    /* If the serial port is open, close it. */
    if (serialHandle != INVALID_HANDLE_VALUE) {
    
        error = serial_uart_close();
        
        if (error != EXT_NO_ERROR) {
        
            goto EXIT_POINT;
            
        }
        
    }

    assert(serialHandle == INVALID_HANDLE_VALUE);

    /* Attempt to open the serial port */
    if (serialHandle == INVALID_HANDLE_VALUE) {
    
        char_T localPortString[10];
        
        sprintf(localPortString, "COM%d:", port);

        serialHandle = (void *) CreateFile(localPortString,
                                           GENERIC_READ | GENERIC_WRITE,
                                           0, NULL, OPEN_EXISTING,
                                           FILE_ATTRIBUTE_NORMAL, NULL);
                                           
        if (serialHandle == INVALID_HANDLE_VALUE) {
        
            error = EXT_ERROR;
            goto EXIT_POINT;
            
        }
        
        /* 
         * file opened successfully
         * -> initialize RX ring buffer admin structure
         */
        RB_INIT(&adminStruct_COMinBuf,  COMinBuf,  COM_RB_RX_BUF_SIZE);            /* set up RX ring buffer */
        
    }

    if (!SetCommTimeouts(serialHandle, &cto_blocking)) {
    
        closeFile = true;
        error = EXT_ERROR;
        
        goto EXIT_POINT;
        
    }

    if (!SetCommState(serialHandle, &dcb)) {
    
        closeFile = true;

        error = EXT_ERROR;
        goto EXIT_POINT;
        
    }


EXIT_POINT:

    if (closeFile) {
    
        serial_uart_close();
        
    }
    
    return error;

}  /* end serial_uart_init */





/*
 *********************************************************************************************************
 *    PUBLIC FUNCTIONS
 *********************************************************************************************************
 */

/* Function: ExtSerialPortCreate ===============================================
 * Abstract:
 *  Creates an External Mode Serial Port object.  The External Mode Serial Port
 *  is an abstraction of the physical serial port providing a standard
 *  interface for external mode code.  A pointer to the created object is
 *  returned.
 *
 */
PUBLIC ExtSerialPort *ExtSerialPortCreate(void) {

static ExtSerialPort     serialPort;
ExtSerialPort           *portDev        = &serialPort;

    /* Determine and save endianness. */
    {
    
        union Char2Integer_tag {
        
            int_T   IntegerMember;                  /* 2 bytes or 4 bytes */
            char_T  CharMember[sizeof(int_T)];      /* 2 bytes or 4 bytes */
            
        } temp;

        /* 0x0001 (16-bit integers) or 0x00000001 (32-bit integers) */
        temp.IntegerMember = 1;
        
        /* determine endianness */
        if (temp.CharMember[0] != 1) {
        
            /* big endian:    0x0001   => 0x4000: 0x00   0x4001: 0x01    ( MSB -> LSB ) */
            portDev->isLittleEndian = false;
            
        } else {
        
            /* little endian: 0x0001   => 0x4000: 0x01   0x4001: 0x00    ( LSB -> MSB ) */
            portDev->isLittleEndian = true;
            
        }
        
    }

    portDev->fConnected = false;

    return portDev;

}  /* end ExtSerialPortCreate */


/* Function: ExtSerialPortConnect ==============================================
 * Abstract:
 *  Performs a logical connection between the external mode code and the
 *  External Mode Serial Port object and a real connection between the External
 *  Mode Serial Port object and the physical serial port.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PUBLIC boolean_T ExtSerialPortConnect(ExtSerialPort *portDev,
                                      uint16_T       port,
                                      uint32_T       baudRate) {

    boolean_T error = EXT_NO_ERROR;

    // local function name... debugging only
    DEFINE_DEBUG_FNAME("ExtSerialPortConnect")

    if (portDev->fConnected) {
    
        error = EXT_ERROR;
        goto EXIT_POINT;
        
    }

    portDev->fConnected = true;

    error = serial_uart_init(port, baudRate);
    
    if (error != EXT_NO_ERROR) {
    
        PRINT_DEBUG_MSG_LVL1("Failed to open serial port.");
        PRINT_DEBUG_MSG_NL1;

        portDev->fConnected = false;
        goto EXIT_POINT;
        
    }


EXIT_POINT:

    return error;

}  /* end ExtSerialPortConnect */


/* Function: ExtSerialPortDisconnect ===========================================
 * Abstract:
 *  Performs a logical disconnection between the external mode code and the
 *  External Mode Serial Port object and a real disconnection between the
 *  External Mode Serial Port object and the physical serial port.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PUBLIC boolean_T ExtSerialPortDisconnect(ExtSerialPort *portDev) {

boolean_T error = EXT_NO_ERROR;

    if (!portDev->fConnected) {
    
        error = EXT_ERROR;
        goto EXIT_POINT;
        
    }

    portDev->fConnected = false;

    error = serial_uart_close();
    
    if (error != EXT_NO_ERROR) {
    
        goto EXIT_POINT;
        
    }


EXIT_POINT:

    return error;

}  /* end ExtSerialPortDisconnect */


/* Function: ExtSerialPortSetData ==============================================
 * Abstract:
 *  Sets (sends) the specified number of bytes on the comm line.  The number of
 *  bytes sent is returned via the 'bytesWritten' parameter.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PUBLIC boolean_T ExtSerialPortSetData(ExtSerialPort     *portDev,
                                      uint8_T           *data,
                                      uint32_T           size,
                                      uint32_T          *bytesWritten) {
                                      
    if (!portDev->fConnected) {
    
        return EXT_ERROR;
        
    }

    return serial_set_string(data, size, bytesWritten);

}  /* end ExtSerialPortSetData */


/* Function: ExtSerialPortDataPending ==========================================
 * Abstract:
 *  Returns, via the 'bytesPending' arg, the combined number of bytes pending on 
 *  the comm line as well as in the RX ring buffer.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PUBLIC boolean_T ExtSerialPortDataPending(ExtSerialPort     *portDev,
                                          int32_T           *bytesPending) {
    
    /* are we connected at all? */
    if (!portDev->fConnected) {

        /* nope -> mistake */
        return EXT_ERROR;

    } else {

        /* connected */

        /* determine the total number of elements available in the comms line and RX buffer */
        return serial_string_pending(bytesPending);

    }  /* connected */

} /* end ExtSerialPortDataPending */


/* Function: ExtSerialPortGetRawChar ===========================================
 * Abstract:
 *  Attempts to get one byte from the comm line.  The number of bytes read is
 *  returned via the 'bytesRead' parameter.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PUBLIC boolean_T ExtSerialPortGetRawChar(ExtSerialPort  *portDev,
                                         uint8_T        *c,
                                         uint32_T       *bytesRead) {

    if (!portDev->fConnected) {
    
        return EXT_ERROR;
        
    } else {
    
        return serial_get_string(c, 1, bytesRead);
        
    }

}  /* end ExtSerialPortGetRawChar */


/* Function: ExtSerialPortPeekRawChar ===========================================
 * Abstract:
 *  Peeks at next byte from the comm line / ring buffer. The read position is 
 *  determined by 'myTailOffset'. Setting 'myTailOffset' to '0' will result in 
 *  reading from the current tail position of the ring buffer. Variable 'myTailOffset'
 *  is increased by one with every call to this function.
 *
 *  EXT_NO_ERROR is returned on success, EXT_ERROR on failure.
 */
PUBLIC boolean_T ExtSerialPortPeekRawChar(ExtSerialPort *portDev,
                                          uint8_T       *c,
                                          uint_T        *myTailOffset) {

    /* are we connected at all? */
    if (!portDev->fConnected) {

        /* nope -> mistake */
        return EXT_ERROR;

    } else {

        /* get a copy of the next character on the ring buffer */
        return serial_peek_byte(c, myTailOffset);

    }  /* connected */

} /* end ExtSerialPortPeekRawChar */


/* [EOF] ext_serial_win32_port.c */
