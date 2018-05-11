/*
 * Copyright 1994-2008 The MathWorks, Inc.
 *
 * File: ext_comm.c     $Revision: 1.1.6.8 $
 *
 * Abstract:
 *  Host-side, transport-independent external-mode functions.  Calls to these
 *  functions originate from Simulink and are dispatched through ext_main.c
 *  Functions are included to:
 *      o set (send) packets to the target
 *      o get (receive) packets from the target
 *      o open connection with target
 *      o close connection with target
 *      o etc
 *
 *  Transport specific code (e.g., TCPIP code) resides in ext_transport.c.
 *  Modify that file to customize external mode to various transport
 *  mechanisms (e.g., shared memory, serial line, etc).
 *
 * 
 * Adapted for rtmc9s12 - Target, fw-04-10
 */

/*****************
 * Include files *
 *****************/

/*ANSI C headers*/
#include <stdio.h>
#include <string.h>

/*Real Time Workshop headers*/
#include "tmwtypes.h"
#include "mex.h"
#include "extsim.h"
#include "ext_convert.h"
#include "extutil.h"
#include "ext_transport.h"
#include "ext_share.h"


#include "debugMsgs_host.h"     /* macros PRINT_DEBUG_MSG_LVL1 to PRINT_DEBUG_MSG_LVL5,  fw - 06 - 07 */




// ----------------------------------------------------------------------------------------------------
// global variables
// ----------------------------------------------------------------------------------------------------

/* try to detect 'target stuck situations'  --  fw-07-07 */
HostSimStatus   HostStatus                      = HOST_STATUS_NOT_CONNECTED;   /* fw-07-07  :  used here as well as in ext_serial_utils.c -> ExtSetPkt() */


/* do not define DEADLOCK_EMERGENCY !!!  --  fw-07-07 */
//#define DEADLOCK_EMERGENCY

#ifdef DEADLOCK_EMERGENCY
static ulong_T  numCallsToExtRecvIncomingPkt    = 0;         /* fw-07-07  :  counting calls to ExtRecvIncomingPkt to detect comms errors... */
static ulong_T  maxNumCallsToExtRecvIncomingPkt = 10000;     /* fw-07-07  :  initial value... can be modified if required (currently fixed) */
#endif



#if DEBUG_MSG_LVL > 0

#ifdef TXactiveControl
 #define numDebugMsgs 36
#else
 #define numDebugMsgs 35
#endif

const char_T         *debugActionStrings[numDebugMsgs] = {
    /* connection actions */
    "EXT_CONNECT",
    "EXT_DISCONNECT_REQUEST",
    "EXT_DISCONNECT_REQUEST_NO_FINAL_UPLOAD",
    "EXT_DISCONNECT_CONFIRMED",

    /* parameter upload/download actions */
    "EXT_SETPARAM",
    "EXT_GETPARAMS",

    /* data upload actions */
    "EXT_SELECT_SIGNALS",
    "EXT_SELECT_TRIGGER",
    "EXT_ARM_TRIGGER",
    "EXT_CANCEL_LOGGING",

    /* model control actions */
    "EXT_MODEL_START",
    "EXT_MODEL_STOP",
    "EXT_MODEL_PAUSE",
    "EXT_MODEL_STEP",
    "EXT_MODEL_CONTINUE",

    /* data request actions */
    "EXT_GET_TIME",

    /*================================
     * Packets/actions from target.
     *==============================*/

    /* responses */
    "EXT_CONNECT_RESPONSE",   /* must not be 0! */
    "EXT_DISCONNECT_REQUEST_RESPONSE",
    "EXT_SETPARAM_RESPONSE",
    "EXT_GETPARAMS_RESPONSE",
    "EXT_MODEL_SHUTDOWN",
    "EXT_GET_TIME_RESPONSE",
    "EXT_MODEL_START_RESPONSE",
    "EXT_MODEL_PAUSE_RESPONSE",
    "EXT_MODEL_STEP_RESPONSE",
    "EXT_MODEL_CONTINUE_RESPONSE",
    "EXT_UPLOAD_LOGGING_DATA",
    "EXT_SELECT_SIGNALS_RESPONSE",
    "EXT_SELECT_TRIGGER_RESPONSE",
    "EXT_ARM_TRIGGER_RESPONSE",
    "EXT_CANCEL_LOGGING_RESPONSE",

    /*
     * This packet is sent from the target to signal the end of a data
     * collection event (e.g., each time that the duration is reached).
     * This packet only applies to normal mode (see
     * EXT_TERMINATE_LOG_SESSION)
     */
    "EXT_TERMINATE_LOG_EVENT",

    /*
     * This packet is sent from the target at the end of each data logging
     * session.  This occurs either at the end of a oneshot or at the end
     * of normal mode (i.e., the last in a series of oneshots).
     */
    "EXT_TERMINATE_LOG_SESSION",

    #ifdef TXactiveControl
    /* TXactive control (rtmc9s12 - target) --  fw-07-07 */
    "EXT_DATA_UPLD_NOACK_REQUEST",
    #endif

    /* used to break assumed deadlock situations --  fw-07-07 */
    "EXT_BREAK_DEADLOCK",

    "EXTENDED = 255"          /* reserved for extending beyond 254 ID's */
};

#endif


// ----------------------------------------------------------------------------------------------------
// local methods
// ----------------------------------------------------------------------------------------------------


#ifdef TXactiveControl
/* Function: EnableLogDataUpload ===============================================
 * Abstract:
 *  Trigger upload of one data telegram from the target (sets target flag TXactive)
 */
PRIVATE void EnableLogDataUpload(ExternalSim *ES) {

    UserData    *userData = (UserData *)esGetUserData(ES);
    PktHeader   pktHdr;
    int_T       nSet;
    boolean_T   error = EXT_NO_ERROR;

    // local function name... debugging only
    DEFINE_DEBUG_FNAME("EnableLogDataUpload")

    PRINT_DEBUG_MSG_LVL2("IN\n");

    /*
    * Send the EXT_DATA_UPLD_NOACK_REQUEST pkt to the target.  This message triggers
    * the upload of exactly one data telegram (host driven flow control, fw-07-07)
    */
    pktHdr.size = 0;
    pktHdr.type = EXT_DATA_UPLD_NOACK_REQUEST;

    Copy32BitsToTarget(ES, (char_T *)&pktHdr, (uint32_T *)&pktHdr, NUM_HDR_ELS);
    if (!esIsErrorClear(ES)) {

        esSetError(ES, "Copy32BitsToTarget() call failed while requesting new data telegram\n");
        goto EXIT_POINT;

    }

    PRINT_DEBUG_MSG_LVL2("Sending EXT_DATA_UPLD_NOACK_REQUEST (");
    PRINT_DEBUG_MSG_LVL2_UDec(EXT_DATA_UPLD_NOACK_REQUEST);
    PRINT_DEBUG_MSG_LVL2_Raw(") to enable upload of log data from the target\n");

    error = ExtSetTargetPkt(ES, sizeof(pktHdr), (char_T *)&pktHdr, &nSet);
    if (error || (nSet != sizeof(pktHdr))) {

        esSetError(ES, "ExtSetTargetPkt() call failed on EXT_DATA_UPLD_NOACK_REQUEST.\n");
        PRINT_DEBUG_MSG_LVL1("ExtSetTargetPkt claims to have sent ");
        PRINT_DEBUG_MSG_LVL1_UDec((uint_T)nSet);
        PRINT_DEBUG_MSG_LVL1_Raw(" bytes\n");

        error = EXT_ERROR;
        goto EXIT_POINT;

    }

EXIT_POINT:

    PRINT_DEBUG_MSG_LVL2("OUT");
    PRINT_DEBUG_MSG_NL2;

}  /* end EnableLogDataUpload */
#endif


/* do not define DEADLOCK_EMERGENCY !!!  --  fw-07-07 */
#ifdef DEADLOCK_EMERGENCY
/* Function: SendBreakDeadlockPktToTarget ======================================
 * Abstract:
 *  Attempts to break an assumed deadlock situation by sending an empty packet
 *  to the target. The arrival of new data will break the deadlock. Called by 
 *  the Simulink callback function 'ExtRecvIncomingPkt' (defined in this file)
 */
PRIVATE void SendBreakDeadlockPktToTarget(ExternalSim *ES) {

    UserData    *userData = (UserData *)esGetUserData(ES);
    PktHeader   pktHdr;
    int_T       nSet;
    boolean_T   error = EXT_NO_ERROR;

    // local function name... debugging only
    DEFINE_DEBUG_FNAME("SendNullPktToTarget")

    PRINT_DEBUG_MSG_LVL2("IN\n");

    /*
    * Send the EXT_BREAK_DEADLOCK pkt to the target.  This message triggers
    * the upload of exactly one data telegram (host driven flow control, fw-07-07)
    */
    pktHdr.size = 0;
    pktHdr.type = EXT_BREAK_DEADLOCK;

    Copy32BitsToTarget(ES, (char_T *)&pktHdr, (uint32_T *)&pktHdr, NUM_HDR_ELS);
    if (!esIsErrorClear(ES)) {

        esSetError(ES, "Copy32BitsToTarget() call failed while trying to break an assumed deadlock situation\n");
        goto EXIT_POINT;

    }

    PRINT_DEBUG_MSG_LVL2("Sending EXT_BREAK_DEADLOCK (");
    PRINT_DEBUG_MSG_LVL2_UDec(EXT_BREAK_DEADLOCK);
    PRINT_DEBUG_MSG_LVL2_Raw(") to enable upload of log data from the target\n");

    error = ExtSetTargetPkt(ES, sizeof(pktHdr), (char_T *)&pktHdr, &nSet);
    if (error || (nSet != sizeof(pktHdr))) {

        esSetError(ES, "ExtSetTargetPkt() call failed on EXT_BREAK_DEADLOCK.\n");
        PRINT_DEBUG_MSG_LVL1("ExtSetTargetPkt claims to have sent ");
        PRINT_DEBUG_MSG_LVL1_UDec((uint_T)nSet);
        PRINT_DEBUG_MSG_LVL1_Raw(" bytes\n");

        error = EXT_ERROR;
        goto EXIT_POINT;

    }

EXIT_POINT:

    PRINT_DEBUG_MSG_LVL2("OUT");
    PRINT_DEBUG_MSG_NL2;

}  /* end SendBreakDeadlockPktToTarget */
#endif  /* DEADLOCK_EMERGENCY */


/* Function: FreeAndNullUserData ===============================================
 * Abstract:
 *  Free user data and null it out in the external sim struct.
 */
PRIVATE void FreeAndNullUserData(ExternalSim *ES) {

    // local function name... debugging only
    DEFINE_DEBUG_FNAME("FreeAndNullUserData")

    PRINT_DEBUG_MSG_LVL2("IN\n");

    ExtUserDataDestroy(esGetUserData(ES));
    esSetUserData(ES, NULL);

    PRINT_DEBUG_MSG_LVL2("OUT\n");

}  /* end FreeAndNullUserData */


/* Function: ExtGetPktHdr ===== ================================================
 * Abstract:
 *  Get all bytes comprising a single packet header on the comm line.
 */
PRIVATE boolean_T ExtRecvIncomingPktHeader(
    ExternalSim *ES,
    PktHeader   *pktHdr) {
    
    char_T        *bufPtr;
    int         nBytes     = 0;            /* total pkt header bytes recv'd. */
    int         nGot       = 0;            /* num bytes recv'd in one call to ExtGetTargetPkt. */
    int         noDataCntr = 1000;         /* determines if target exited unexpectedly. */
    boolean_T   error      = EXT_NO_ERROR;

    // local function name... debugging only
    DEFINE_DEBUG_FNAME("ExtRecvIncomingPktHeader")

    //PRINT_DEBUG_MSG_LVL2("IN\n");

    /*
     * Loop until all bytes are received for the incoming packet header.
     * The packet header may not be read in one shot.
     */
    while (nBytes != sizeof(PktHeader)) {
        /*
         * Assume true since we should only be here after a call to
         * ExtTargetPktPending() returned true
         */
        boolean_T pending = true;

        /*
         * We may have received some of the packet header, but not all of
         * it.  Check to see if any additional data is pending to complete
         * the packet header.
         */
        if (nBytes > 0) {
        
            error = ExtTargetPktPending(ES, &pending, 0, 100000);
            if (error) {
            
                esSetError(ES,
                           "ExtTargetPktPending() call failed while checking "
                           " for target pkt\n");
                           
                goto EXIT_POINT;
                
            }

        }

        /*
         * Get any pending data
         */
        if (pending) {
        
            bufPtr = (char_T *)pktHdr + nBytes;
            
            error = ExtGetTargetPkt(ES, sizeof(PktHeader) - nBytes, &nGot, bufPtr);
            if (error) {
            
                esSetError(ES, 
                           "ExtGetTargetPkt() call failed while checking "
                           " target pkt header.\n");
                           
                goto EXIT_POINT;
                
            }

            nBytes += nGot;
            
        }

        /*
         * ExtRecvIncomingPktHeader() is called only after a call to
         * ExtTargetPktPending() returns true.  For tcp/ip, this function
         * may return true if the tcp/ip communication was shut down by
         * the target unexpectedly (e.g. someone did a ctrl-c to stop
         * the target executable while connected via extmode).  If
         * ExtTargetPktPending() returns true but we do not see any data
         * after checking the communication line some number of times,
         * we must break out of this infinite loop or Matlab will hang.
         */
        if (nGot == 0) {
        
            noDataCntr--;
            
            if (noDataCntr == 0) {
            
                error = 1;
                esSetError(ES, 
                           "ExtGetTargetPkt() call failed while checking "
                           " target pkt header.\n");
                           
                goto EXIT_POINT;
                
            }

        }
        
    }

EXIT_POINT:

    //PRINT_DEBUG_MSG_LVL2("OUT, error status: ");
    //PRINT_DEBUG_MSG_LVL2_UDec(error);
    //PRINT_DEBUG_MSG_NL2;

    return error;

}

/* Function: ExtRecvIncomingPkt ================================================
 * Abstract:
 *  Check for packets (poll) from target on the comm line.  If a packet
 *  is pending, set the incoming packet pending flag to true and set the
 *  incoming packet type.  Otherwise, do nothing.
 */
PRIVATE void ExtRecvIncomingPkt(
    ExternalSim    *ES,
    int_T          nrhs,
    const mxArray  *prhs[]) {
    
    boolean_T   pending;
    char_T     *bufPtr;
    int         nGot         = 0;
    boolean_T   error        = EXT_NO_ERROR;

    char_T     *buf          = esGetIncomingPktDataBuf(ES);
    int32_T     nBytesNeeded = esGetIncomingPktDataNBytesNeeded(ES);
    int         nBytes       = esGetIncomingPktDataNBytesInBuf(ES);


    // local function name... debugging only
    DEFINE_DEBUG_FNAME("ExtRecvIncomingPkt")

    //PRINT_DEBUG_MSG_LVL1("IN\n");

    /*
     * Start recv'ing a packet.
     */
    if (nBytesNeeded == UNKNOWN_BYTES_NEEDED) {

        assert(nBytes == 0);

        /*
         * Check for pending packet.
         */
        error = ExtTargetPktPending(ES, &pending, 0, 100000);
        if (error) {

            esSetError(ES, "ExtTargetPktPending() call failed while checking "
                           " for target pkt\n");
                           
            goto EXIT_POINT;

        }

        if (!pending) {

            /* do not define DEADLOCK_EMERGENCY !!!  --  fw-07-07 */
            #ifdef DEADLOCK_EMERGENCY
                /* try to detect a hanging host - target communication and break the deadlock */
                if ((HostStatus == HOST_STATUS_RUNNING) && 
                    (numCallsToExtRecvIncomingPkt++ > maxNumCallsToExtRecvIncomingPkt)) {

                    numCallsToExtRecvIncomingPkt = 0;

                    /* send an empty packet to the target to break the deadlock...   --  fw-07-07 */
                    mexPrintf("%d calls without pending packet from the target...\n", maxNumCallsToExtRecvIncomingPkt);
                    SendBreakDeadlockPktToTarget(ES);
                }
            #endif

            goto EXIT_POINT;

        }  /* nothing to read */

        /* do not define DEADLOCK_EMERGENCY !!!  --  fw-07-07 */
        #ifdef DEADLOCK_EMERGENCY
        
            /* detected a pending packet -> reset counter... */
            numCallsToExtRecvIncomingPkt = 0;
        
        #endif

        /*
         * Process pending packet.
         */
        {
            PktHeader   pktHdr;

            error = ExtRecvIncomingPktHeader(ES, &pktHdr);
            if (error) {

                goto EXIT_POINT;

            }

            /* Convert the pkt hdr to host format. */
            Copy32BitsFromTarget(ES,
                                 (uint32_T *)&pktHdr, 
                                 (char_T *)&pktHdr,
                                 NUM_HDR_ELS);
                                 
            if (!esIsErrorClear(ES)) {

                goto EXIT_POINT;

            }

            /* feedback: eg.  --[3] ExtRecvIncomingPkt: Packet header received, type 26 (EXT_UPLOAD_LOGGING_DATA), size 24  */
            PRINT_DEBUG_MSG_LVL3("Packet header received, type ");
            PRINT_DEBUG_MSG_LVL3_UDec(pktHdr.type);
            PRINT_DEBUG_MSG_LVL3_Raw(" (");
            PRINT_DEBUG_MSG_LVL3_Raw(debugActionStrings[pktHdr.type]);
            PRINT_DEBUG_MSG_LVL3_Raw("), size ");
            PRINT_DEBUG_MSG_LVL3_UDec(pktHdr.size);
            PRINT_DEBUG_MSG_NL3;

            nBytesNeeded = pktHdr.size * esGetHostBytesPerTargetByte(ES);
            assert(nBytesNeeded <= esGetIncomingPktDataBufSize(ES));
            
            /*
             * We have a packet pending.  Set the flag and the type.
             */
            esSetIncomingPktPending(ES, TRUE);
            esSetIncomingPkt(ES, (ExtModeAction)pktHdr.type);
            
        }

    }
    
    if (nBytesNeeded == 0) {

        /* feedback: eg.  --[3] ExtRecvIncomingPkt: Packet header received, type 26 (EXT_UPLOAD_LOGGING_DATA), size 24  */
        PRINT_DEBUG_MSG_LVL3("Packet contains no further data.");
        PRINT_DEBUG_MSG_NL3;

        /* ... and we are done */
        goto EXIT_POINT;

    } else {

        /* stay around and look for packet data (section below...) */

    }

    /* packet has data -> retrieve */
    //PRINT_DEBUG_MSG_LVL3("Retrieving packet data...");
    //PRINT_DEBUG_MSG_NL3;

    bufPtr = buf + nBytes;

    /*
     * Check for pending pkt data.  
     */
    error = ExtTargetPktPending(ES, &pending, 0, 0);
    if (error) {
    
        esSetError(ES,
                   "ExtTargetPktPending() call failed while checking for "
                   " target pkt\n");
                   
        goto EXIT_POINT;

    }

    /*
     * Process pending data - may not get it all in one shot.
     */
    if (pending) {

        error = ExtGetTargetPkt(ES, nBytesNeeded, &nGot, bufPtr);
        if (error) {

            esSetError(ES, "ExtGetTargetPkt() call failed while retrieving pkt data\n");
            
            goto EXIT_POINT;

        }

        /* display the number of bytes we received */
        PRINT_DEBUG_MSG_LVL3("Got ");
        PRINT_DEBUG_MSG_LVL3_UDec(nGot);
        PRINT_DEBUG_MSG_LVL3_Raw(" (of ");
        PRINT_DEBUG_MSG_LVL3_UDec(nBytesNeeded);
        PRINT_DEBUG_MSG_LVL3_Raw(") bytes.");
        PRINT_DEBUG_MSG_NL3;
        
        /* THIS CRASHES THE HOST, presumably esGetCommBuf(ES) can change while being accessed...  DO NOT USE!!!!!!  fw - 06 - 07 */
        /* THIS CRASHES THE HOST, presumably esGetCommBuf(ES) can change while being accessed...  DO NOT USE!!!!!!  fw - 06 - 07 */
        /* THIS CRASHES THE HOST, presumably esGetCommBuf(ES) can change while being accessed...  DO NOT USE!!!!!!  fw - 06 - 07 */
        /* THIS CRASHES THE HOST, presumably esGetCommBuf(ES) can change while being accessed...  DO NOT USE!!!!!!  fw - 06 - 07 */
        /* THIS CRASHES THE HOST, presumably esGetCommBuf(ES) can change while being accessed...  DO NOT USE!!!!!!  fw - 06 - 07 */
        /* THIS CRASHES THE HOST, presumably esGetCommBuf(ES) can change while being accessed...  DO NOT USE!!!!!!  fw - 06 - 07 */
        /* THIS CRASHES THE HOST, presumably esGetCommBuf(ES) can change while being accessed...  DO NOT USE!!!!!!  fw - 06 - 07 */
        #ifdef ERASE
        #ifdef ERASE
        #ifdef ERASE

        #if DEBUG_MSG_LVL >= 2
        {
            int      i;
            uint8_T  *myBuf = esGetCommBuf(ES);

            if (nGot > 0) {

            PRINT_DEBUG_MSG_LVL2("Data received (");
            PRINT_DEBUG_MSG_LVL2_UDec(nGot);
            PRINT_DEBUG_MSG_LVL2_Raw(" in total): ");
            for (i = 0; i < nGot; i++) {

                uint16_T   myVal = (uint16_T)(myBuf[i]);
                PRINT_DEBUG_MSG_LVL2_UDec(myVal);
                PRINT_DEBUG_MSG_LVL2_Raw(" ");

            }

            PRINT_DEBUG_MSG_NL2;

            }

        }
        #endif
        #endif  /* ERASE */
        #endif  /* ERASE */
        #endif  /* ERASE */

        esSetIncomingPktPending(ES, TRUE);
        
        nBytesNeeded -= nGot;
        nBytes       += nGot;
        bufPtr       += nGot;


        #ifdef TXactiveControl
        
            /* check if the expected number of bytes has been received (normal) or nothing has been received (target blocked?) */
            if (nBytesNeeded == 0  /* || nGot == 0 */) {

                /* enable upload of the next log data packet (sets TXactive on the target)   --  fw-07-07 */
                EnableLogDataUpload(ES);

            }
            
        #endif

        assert(nBytesNeeded >= 0);

    }

EXIT_POINT:

    esSetIncomingPktDataNBytesNeeded(ES, nBytesNeeded);
    esSetIncomingPktDataNBytesInBuf (ES, nBytes      );

    //PRINT_DEBUG_MSG_LVL1("OUT, error status: ");
    //PRINT_DEBUG_MSG_LVL1_UDec(error);
    //PRINT_DEBUG_MSG_NL1;

}  /* end ExtRecvIncomingPkt */


/* Function: ExtConnect ========================================================
 * Abstract:
 *  Establish communication with target.
 */
PRIVATE void ExtConnect(
    ExternalSim    *ES,
    int_T          nrhs,
    const mxArray  *prhs[]) {
    
    int_T          nGot;
    int_T          nSet;
    PktHeader      pktHdr;
    boolean_T      pending;
    int16_T        one          = 1;
    boolean_T      error        = EXT_NO_ERROR;
    const ulong_T timeOutSecs   = 10;    // 120
    const ulong_T timeOutUSecs  = 0;

    // local function name... debugging only
    DEFINE_DEBUG_FNAME("ExtConnect")

    PRINT_DEBUG_MSG_LVL1("IN\n");
    {
        UserData *userData = ExtUserDataCreate();
        if (userData == NULL) {

            esSetError(ES, "Memory allocation error.");
            goto EXIT_POINT;

        }

        esSetUserData(ES, (void *)userData);
    }

    /*
     * Parse the arguments.
     */
    assert(esIsErrorClear(ES));
    ExtProcessArgs(ES, nrhs, prhs);
    if (!esIsErrorClear(ES)) {

        goto EXIT_POINT;

    }


    assert(esIsErrorClear(ES));
    ExtOpenConnection(ES);
    if (!esIsErrorClear(ES)) {

        goto EXIT_POINT;

    }

    /*
     * Send the EXT_CONNECT pkt to the target.  This packet consists
     * of the string 'ext-mode'.  The purpose of this header is to serve
     * as a flag to start the handshaking process.
     */
    PRINT_DEBUG_MSG_LVL1("Sending 'ext-mode'\n");

    (void)memcpy((void *)&pktHdr, "ext-mode", 8);
    error = ExtSetTargetPkt(ES, sizeof(pktHdr), (char_T *)&pktHdr, &nSet);
    if (error || (nSet != sizeof(pktHdr))) {

        esSetError(ES, "ExtSetTargetPkt() call failed on EXT_CONNECT.\n"
                        "Ensure target is still running\n");
                        
        goto EXIT_POINT;

    }

    /*
     * Get the first of two EXT_CONNECT_RESPONSE packets.  See the 
     * ext_conv.c/ProcessConnectResponse1() function for a description of
     * the packet.  If the timeout elapses before receiving the response
     * pkt, an error is returned.
     *
     * NOTE: Until both EXT_CONNECT_RESPONSE packets are read, packets
     *       received from the target consists solely of unsigned 32 bit
     *       integers.
     */
    PRINT_DEBUG_MSG_LVL1("Waiting for EXT_CONNECT_RESPONSE (1/2)\n");

    error = ExtTargetPktPending(ES, &pending, timeOutSecs, timeOutUSecs);
    if (error || !pending) {

        PRINT_DEBUG_MSG_LVL1("Timed out waiting for first connect response packet.\n");

        esSetError(ES, "Timed out waiting for first connect response packet.\n");
        
        goto EXIT_POINT;

    }

    assert(pending);

    error = ExtRecvIncomingPktHeader(ES, &pktHdr);
    if (error) {

        goto EXIT_POINT;

    }

    #if DEBUG_MSG_LVL >= 5
    {
        int_T i;

        for (i = 0; i < sizeof(pktHdr); i++) {

            PRINT_DEBUG_MSG_LVL5("ExtRecvIncomingPktHeader returned [");
            PRINT_DEBUG_MSG_LVL5_UDec(i + 1);
            PRINT_DEBUG_MSG_LVL5_Raw("/");
            PRINT_DEBUG_MSG_LVL5_UDec(sizeof(pktHdr));
            PRINT_DEBUG_MSG_LVL5_Raw("]) ");
            PRINT_DEBUG_MSG_LVL5_UHex((uint_T) * ((char_T *)&pktHdr + i));
            PRINT_DEBUG_MSG_NL5;

        }

    }
    #endif
            
    ProcessConnectResponse1(ES, &pktHdr);
    if (!esIsErrorClear(ES)) {

        goto EXIT_POINT;

    }

    #if DEBUG_MSG_LVL >= 3
    {
        /*  defined above:   int16_T   one = 1;  */
        MachByteOrder  hostEndian = (*((int8_T *)&one) == 1) ? LittleEndian : BigEndian;
        
        PRINT_DEBUG_MSG_LVL3("Detected host endianness is ");
        PRINT_DEBUG_MSG_LVL3_Raw((hostEndian == LittleEndian) ? "'little endian'  -->  0x0001 stored as  0x01:0x00 (LSB before MSB)" : 
                                                                "'big endian'  -->  0x0001 stored as  0x00:0x01 (MSB before LSB)");
        PRINT_DEBUG_MSG_NL3;
        PRINT_DEBUG_MSG_LVL3("Byte order reversal mechanism is currently ");
        PRINT_DEBUG_MSG_LVL3_Raw((esGetSwapBytes(ES)) ? "activated" : "deactivated");
        PRINT_DEBUG_MSG_LVL3_Raw(" on the host.");
        PRINT_DEBUG_MSG_NL3;
    }
    #endif

    /*
     * Get the second of two EXT_CONNECT_RESPONSE packets.  If the timeout
     * elapses before receiving the response pkt, an error is returned.
     * The format of the packet is:
     *
     * CS1 - checksum 1 (uint32_T)
     * CS2 - checksum 2 (uint32_T)
     * CS3 - checksum 3 (uint32_T)
     * CS4 - checksum 4 (uint32_T)
     * 
     * intCodeOnly   - flag indicating if target is integer only (uint32_T)
     *
     * MWChunkSize   - multiword data type chunk size on target (uint32_T)
     * 
     * targetStatus  - the status of the target (uint32_T)
     *
     * nDataTypes    - # of data types          (uint32_T)
     * dataTypeSizes - 1 per nDataTypes         (uint32_T[])
     */
    PRINT_DEBUG_MSG_LVL1("Waiting for EXT_CONNECT_RESPONSE (2/2)\n");

    error = ExtTargetPktPending(ES, &pending, timeOutSecs, timeOutUSecs);
    if (error || !pending) {

        PRINT_DEBUG_MSG_LVL1("Timed out waiting for second connect response packet.\n");

        esSetError(ES, "Timed out waiting for second connect response packet.\n");
        
        goto EXIT_POINT;

    }

    assert(pending);

    error = ExtRecvIncomingPktHeader(ES, &pktHdr);
    if (error) {

        goto EXIT_POINT;

    }

    #if DEBUG_MSG_LVL >= 5
    {
        int_T i;

        for (i = 0; i < sizeof(pktHdr); i++) {

            PRINT_DEBUG_MSG_LVL5("ExtRecvIncomingPktHeader returned (before copy32) [");
            PRINT_DEBUG_MSG_LVL5_UDec(i + 1);
            PRINT_DEBUG_MSG_LVL5_Raw("/");
            PRINT_DEBUG_MSG_LVL5_UDec(sizeof(pktHdr));
            PRINT_DEBUG_MSG_LVL5_Raw("]) ");
            PRINT_DEBUG_MSG_LVL5_UHex((uint_T) * ((char_T *)&pktHdr + i));
            PRINT_DEBUG_MSG_NL5;

        }

    }
    #endif

    Copy32BitsFromTarget(ES, (uint32_T *)&pktHdr, (char_T *)&pktHdr, NUM_HDR_ELS);

    #if DEBUG_MSG_LVL >= 5
    {
        int_T i;

        for (i = 0; i < sizeof(pktHdr); i++) {

            PRINT_DEBUG_MSG_LVL5("ExtRecvIncomingPktHeader returned (after copy32) [");
            PRINT_DEBUG_MSG_LVL5_UDec(i + 1);
            PRINT_DEBUG_MSG_LVL5_Raw("/");
            PRINT_DEBUG_MSG_LVL5_UDec(sizeof(pktHdr));
            PRINT_DEBUG_MSG_LVL5_Raw("]) ");
            PRINT_DEBUG_MSG_LVL5_UHex((uint_T) * ((char_T *)&pktHdr + i));
            PRINT_DEBUG_MSG_NL5;

        }

    }
    #endif

    if (!esIsErrorClear(ES)) {

        goto EXIT_POINT;

    }

    if (pktHdr.type != EXT_CONNECT_RESPONSE) {

        esSetError(ES, "Unexpected response from target. "
                       "Expected EXT_CONNECT_RESPONSE.\n");
                       
        goto EXIT_POINT;

    }

    /*
     * Allocate space to hold packet.
     */
    {
        uint32_T *tmpBuf;
        uint32_T *bufPtr;
        int_T     pktSize = pktHdr.size *esGetHostBytesPerTargetByte(ES);
        int_T     bytesToGet = pktSize;

        PRINT_DEBUG_MSG_LVL2("Host bytes per target bytes: ");
        PRINT_DEBUG_MSG_LVL2_UDec(esGetHostBytesPerTargetByte(ES));
        PRINT_DEBUG_MSG_NL2;
        PRINT_DEBUG_MSG_LVL2("Allocating memory for a message with ");
        PRINT_DEBUG_MSG_LVL2_UDec(pktSize);
        PRINT_DEBUG_MSG_LVL2_Raw(" bytes\n");

        tmpBuf = (uint32_T *)malloc(pktSize);
        if (tmpBuf == NULL) {

            esSetError(ES, "Memory allocation failure\n");
            
            goto EXIT_POINT;

        }

        bufPtr = tmpBuf;

        /*
         * Get the 2nd connect response packet.  It may not be transmitted as
         * one whole packet.
         */
        {
            char_T *buf = (char_T *)tmpBuf;

            while (bytesToGet != 0) {

                /*
                 * Look for any pending data.  If we ever go more than
                 * 'timeOutVal' seconds, bail with an error.
                 */
                error = ExtTargetPktPending(ES, &pending, timeOutSecs, timeOutUSecs);
                if (error || !pending) {

                    free(tmpBuf);
                
                    esSetError(
                        ES, "ExtTargetPktPending() call failed while checking "
                        " for 2nd EXT_CONNECT_RESPONSE target pkt\n");
                    
                    goto EXIT_POINT;

                }

                /*
                 * Grab the data.
                 */
                error = ExtGetTargetPkt(ES, bytesToGet, &nGot, buf);
                if (error) {

                    free(tmpBuf);

                    esSetError(ES, 
                               "ExtGetTargetPkt() call failed while getting "
                               " for 2nd EXT_CONNECT_RESPONSE target pkt\n");

                    goto EXIT_POINT;

                }

                buf        += nGot;
                bytesToGet -= nGot;

                assert(bytesToGet >= 0);

            }

            PRINT_DEBUG_MSG_LVL2("ExtGetTargetPkt returns ");
            PRINT_DEBUG_MSG_LVL2_UDec(nGot);
            PRINT_DEBUG_MSG_LVL2_Raw(" bytes\n");
            
        }  /* while (bytesToGet) */


        /*
         * This packet happens to consists of all uint32_T.  Convert them
         * in a batch.
         */
        #if DEBUG_MSG_LVL >= 4
        {
            int_T i;

            for (i = 0; i < nGot; i++) {

            PRINT_DEBUG_MSG_LVL5("2nd EXT_CONNECT_RESPONSE (before copy32) [");
            PRINT_DEBUG_MSG_LVL5_UDec(i + 1);
            PRINT_DEBUG_MSG_LVL5_Raw("/");
            PRINT_DEBUG_MSG_LVL5_UDec(nGot);
            PRINT_DEBUG_MSG_LVL5_Raw("]) ");
            PRINT_DEBUG_MSG_LVL5_UHex(*((uint8_T *)tmpBuf + i));
            PRINT_DEBUG_MSG_NL5;

            }

        }
        #endif

        Copy32BitsFromTarget(ES, tmpBuf, (char_T *)tmpBuf, pktSize/sizeof(uint32_T));

        #if DEBUG_MSG_LVL >= 4
        {
            int_T i;

            for (i = 0; i < nGot; i++) {

            PRINT_DEBUG_MSG_LVL5("2nd EXT_CONNECT_RESPONSE (after copy32) [");
            PRINT_DEBUG_MSG_LVL5_UDec(i + 1);
            PRINT_DEBUG_MSG_LVL5_Raw("/");
            PRINT_DEBUG_MSG_LVL5_UDec(nGot);
            PRINT_DEBUG_MSG_LVL5_Raw("]) ");
            PRINT_DEBUG_MSG_LVL5_UHex(*((uint8_T *)tmpBuf + i));
            PRINT_DEBUG_MSG_NL5;

            }

        }
        #endif
      
        if (!esIsErrorClear(ES)) {

            goto EXIT_POINT;

        }


        PRINT_DEBUG_MSG_LVL2("Contents of 2nd EXT_CONNECT_RESPONSE -----------------------\n");
        /*
         * CS1 - checksum 1 (uint32_T)
         * CS2 - checksum 2 (uint32_T)
         * CS3 - checksum 3 (uint32_T)
         * CS4 - checksum 4 (uint32_T)
         *
         * intCodeOnly   - flag indicating if target is integer only (uint32_T)
         *
         * targetStatus  - the status of the target (uint32_T)
         *
         * nDataTypes    - # of data types          (uint32_T)
         * dataTypeSizes - 1 per nDataTypes         (uint32_T[])
         */

         /*
            // Debug: analyse target specific byte ordering in floating point data types
            {
                real_T   test = 1.0;
                mexPrintf("size(real_T): %d\n", sizeof(test));
            }

                   
            mexPrintf("CS1: %f\n", *(real_T *)&bufPtr[0]);      // should be: -1.4
            mexPrintf("CS2: %f\n", *(real_T *)&bufPtr[1]);      // should be: 5555.2222
            mexPrintf("CS3: %d\n", bufPtr[2]);                  // should be: 20000
            mexPrintf("CS4: %d\n", *(int32_T *)&bufPtr[3]);     // should be: -400000
            
          */

        /* process 128 bit checksum */
        PRINT_DEBUG_MSG_LVL2("Checksum_1: ");
        PRINT_DEBUG_MSG_LVL2_UHex(bufPtr[0]);
        PRINT_DEBUG_MSG_NL2;
        PRINT_DEBUG_MSG_LVL2("Checksum_2: ");
        PRINT_DEBUG_MSG_LVL2_UHex(bufPtr[1]);
        PRINT_DEBUG_MSG_NL2;
        PRINT_DEBUG_MSG_LVL2("Checksum_3: ");
        PRINT_DEBUG_MSG_LVL2_UHex(bufPtr[2]);
        PRINT_DEBUG_MSG_NL2;
        PRINT_DEBUG_MSG_LVL2("Checksum_4: ");
        PRINT_DEBUG_MSG_LVL2_UHex(bufPtr[3]);
        PRINT_DEBUG_MSG_NL2;
        esSetTargetModelCheckSum(ES, 0, *bufPtr++);
        esSetTargetModelCheckSum(ES, 1, *bufPtr++);
        esSetTargetModelCheckSum(ES, 2, *bufPtr++);
        esSetTargetModelCheckSum(ES, 3, *bufPtr++);


        /* process integer only flag */
        PRINT_DEBUG_MSG_LVL2("Target integer only code: ");
        PRINT_DEBUG_MSG_LVL2_UDec((uint16_T)*bufPtr);
        PRINT_DEBUG_MSG_NL2;

        esSetIntOnly(ES, (boolean_T)*bufPtr++);

        if (esGetIntOnly(ES)) {

            InstallIntegerOnlyDoubleConversionRoutines(ES);

        }

      
        /* process multiword data type chunk size */
        PRINT_DEBUG_MSG_LVL2("Target multiword chunk size: ");
        PRINT_DEBUG_MSG_LVL2_UDec((uint16_T)*bufPtr);
        PRINT_DEBUG_MSG_NL2;

        esSetTargetMWChunkSize(ES, *bufPtr++);


        /* process target status */
        PRINT_DEBUG_MSG_LVL2("Target status: ");
        PRINT_DEBUG_MSG_LVL2_UDec((uint16_T)*bufPtr);
        PRINT_DEBUG_MSG_NL2;

        esSetTargetSimStatus(ES, (TargetSimStatus)*bufPtr++);

        ProcessTargetDataSizes(ES, bufPtr);

        PRINT_DEBUG_MSG_LVL2("End of contents of 2nd EXT_CONNECT_RESPONSE -----------------\n");

        free(tmpBuf);
        if (!esIsErrorClear(ES)) {

            goto EXIT_POINT;

        }

    }

    /*
     * Set up function pointers for Simulink.
     */
    esSetRecvIncomingPktFcn(ES, ExtRecvIncomingPkt);

    #ifdef TXactiveControl
    
        /* enable upload of the very first log data packet (sets TXactive on the target)   --  fw-07-07 */
        EnableLogDataUpload(ES);

    #endif


EXIT_POINT:

    if (!esIsErrorClear(ES)) {

        ExtCloseConnection(ES);
        FreeAndNullUserData(ES);

    }

    PRINT_DEBUG_MSG_LVL1("OUT, error status: ");
    PRINT_DEBUG_MSG_LVL1_UDec(error);
    PRINT_DEBUG_MSG_NL1;

}  /* end ExtConnect */


/* Function: ExtDisconnectRequest ==============================================
 * Abstract:
 *  A request to terminate communication with target has been made.  Notify
 *  the target (if it is up and running).  The connection status will be:
 *  EXTMODE_DISCONNECT_REQUESTED
 */
PRIVATE void ExtDisconnectRequest(
    ExternalSim    *ES,
    int_T           nrhs,
    const mxArray  *prhs[]) {
    
	PktHeader   pktHdr;
	int_T       nSet;
	boolean_T   error = EXT_NO_ERROR;

    // local function name... debugging only
    DEFINE_DEBUG_FNAME("ExtDisconnectRequest")

    PRINT_DEBUG_MSG_LVL1("IN\n");

    assert(esGetConnectionStatus(ES) == EXTMODE_DISCONNECT_REQUESTED);

    pktHdr.size = 0;
    pktHdr.type = EXT_DISCONNECT_REQUEST;

    Copy32BitsToTarget(ES, (char_T *)&pktHdr, (uint32_T *)&pktHdr, NUM_HDR_ELS);
    if (!esIsErrorClear(ES)) {

        goto EXIT_POINT;

    }

    PRINT_DEBUG_MSG_LVL1("Sending EXT_DISCONNECT_REQUEST message\n");

    error = ExtSetTargetPkt(ES, sizeof(pktHdr), (char_T *)&pktHdr, &nSet);
    if (error || (nSet != sizeof(pktHdr))) {

        esSetError(ES, "ExtSetTargetPkt() call failed on CLOSE.\n"
                       "Ensure target is still running\n");
        
        goto EXIT_POINT;

    }

EXIT_POINT:

    PRINT_DEBUG_MSG_LVL1("OUT, error status:\n");
    PRINT_DEBUG_MSG_LVL1_UDec(error);
    PRINT_DEBUG_MSG_NL1;

    return;

}  /* end ExtDisconnectRequest */


/* Function: ExtDisconnectRequestNoFinalUpload =================================
 * Abstract:
 *  A request to terminate communication with target has been made.  Notify
 *  the target (if it is up and running).  The connection status will be:
 *  EXTMODE_DISCONNECT_REQUESTED
 */
PRIVATE void ExtDisconnectRequestNoFinalUpload(
    ExternalSim    *ES,
    int_T          nrhs,
    const mxArray  *prhs[]) {
    
PktHeader   pktHdr;
int_T       nSet;
boolean_T   error = EXT_NO_ERROR;

    // local function name... debugging only
    DEFINE_DEBUG_FNAME("ExtDisconnectRequestNoFinalUpload")

    PRINT_DEBUG_MSG_LVL1("IN\n");

    assert(esGetConnectionStatus(ES) == EXTMODE_DISCONNECT_REQUESTED);

    pktHdr.size = 0;
    pktHdr.type = EXT_DISCONNECT_REQUEST_NO_FINAL_UPLOAD;

    Copy32BitsToTarget(ES, (char_T *)&pktHdr, (uint32_T *)&pktHdr, NUM_HDR_ELS);
    if (!esIsErrorClear(ES)) {

        goto EXIT_POINT;

    }

    error = ExtSetTargetPkt(ES, sizeof(pktHdr), (char_T *)&pktHdr, &nSet);
    if (error || (nSet != sizeof(pktHdr))) {
    
        esSetError(ES, "ExtSetTargetPkt() call failed on CLOSE.\n"
                       "Ensure target is still running\n");
                       
        goto EXIT_POINT;
        
    }

EXIT_POINT:
   
    PRINT_DEBUG_MSG_LVL1("OUT, error status: ");
    PRINT_DEBUG_MSG_LVL1_UDec(error);
    PRINT_DEBUG_MSG_NL1;

    return;

}  /* end ExtDisconnectRequestNoFinalUpload */


/* Function: ExtDisconnectConfirmed ============================================
 * Abstract:
 *  Terminate communication with target.  This should only be called after the
 *  target has been notified of the termination (if the target is up and 
 *  running).  The connection status will be: EXTMODE_DISCONNECT_CONFIRMED.
 */
PRIVATE void ExtDisconnectConfirmed(
    ExternalSim    *ES,
    int_T          nrhs,
    const mxArray  *prhs[]) {
    
    // local function name... debugging only
    DEFINE_DEBUG_FNAME("ExtDisconnectConfirmed")

    PRINT_DEBUG_MSG_LVL1("IN\n");

    assert(esGetConnectionStatus(ES) == EXTMODE_DISCONNECT_CONFIRMED);

    ExtCloseConnection(ES);
    FreeAndNullUserData(ES);

    PRINT_DEBUG_MSG_LVL1("OUT\n");

    return;

}  /* end ExtDisconnectConfirmed */


/* Function: ExtSendGenericPkt =================================================
 * Abstract:
 *  Send generic packet to the target.  This function simply passes the
 *  already formatted and packed packet to the target.
 */
PRIVATE void ExtSendGenericPkt(
    ExternalSim    *ES,
    int_T           nrhs,
    const mxArray  *prhs[]) {
    
int_T       nSet;
PktHeader   pktHdr;
int_T       pktSize;
boolean_T   error = EXT_NO_ERROR;

    // local function name... debugging only
    DEFINE_DEBUG_FNAME("ExtSendGenericPkt")

    PRINT_DEBUG_MSG_LVL2("IN\n");

    pktSize = esGetCommBufSize(ES);

    pktHdr.type = (uint32_T)esGetAction(ES);
    pktHdr.size = (uint32_T)(pktSize / esGetHostBytesPerTargetByte(ES));

    PRINT_DEBUG_MSG_LVL2("Packet type (before copy32): ");
    PRINT_DEBUG_MSG_LVL2_UDec(pktHdr.type);
    PRINT_DEBUG_MSG_NL2;
    PRINT_DEBUG_MSG_LVL2("Packet type (action) is: ");
    PRINT_DEBUG_MSG_LVL2_Raw(debugActionStrings[(int_T)pktHdr.type]);
    PRINT_DEBUG_MSG_NL2;
    PRINT_DEBUG_MSG_LVL2("Packet size (before copy32): ");
    PRINT_DEBUG_MSG_LVL2_UHex(pktHdr.size);
    PRINT_DEBUG_MSG_LVL2_Raw(" (");
    PRINT_DEBUG_MSG_LVL2_UDec(pktHdr.size);
    PRINT_DEBUG_MSG_LVL2_Raw(")");
    PRINT_DEBUG_MSG_NL2;

    Copy32BitsToTarget(ES, (char_T *)&pktHdr, (uint32_T *)&pktHdr, NUM_HDR_ELS);
    if (!esIsErrorClear(ES)) {

        goto EXIT_POINT;

    }

    PRINT_DEBUG_MSG_LVL2("Packet size (after copy32): ");
    PRINT_DEBUG_MSG_LVL2_UHex(pktHdr.size);
    PRINT_DEBUG_MSG_NL2;

    /*
     * Send packet header.
     */
    PRINT_DEBUG_MSG_LVL2("Sending packet header ====================\n");

    error = ExtSetTargetPkt(ES, sizeof(pktHdr), (char_T *)&pktHdr, &nSet);
    if (error || (nSet != sizeof(pktHdr))) {

        esSetError(ES, "ExtSetTargetPkt() call failed for ExtSendGenericPkt().\n"
                       "Ensure target is still running\n");
                       
        goto EXIT_POINT;

    }

    /*
     * Send packet data - if any.
     */
    if (pktSize > 0) {

        PRINT_DEBUG_MSG_LVL2("Sending packet data ====================\n");

        error = ExtSetTargetPkt(ES, pktSize, esGetCommBuf(ES), &nSet);
        if (error || (nSet != pktSize)) {

            mexPrintf("Download data (%d bytes) exceeds current buffer size (%d bytes)\n", pktSize, nSet);

            esSetError(ES, "ExtSetTargetPkt() call failed for ExtSendGenericPkt().\n"
                           "Ensure target is still running\n");
                           
            goto EXIT_POINT;

        }

    }


    #if DEBUG_MSG_LVL >= 2
    {
        int   i;

        if (pktSize > 0) {

            for (i = 0; i < pktSize; i++) {

            PRINT_DEBUG_MSG_LVL2("Data sent [");
            PRINT_DEBUG_MSG_LVL2_UDec(i + 1);
            PRINT_DEBUG_MSG_LVL2_Raw("/");
            PRINT_DEBUG_MSG_LVL2_UDec(pktSize);
            PRINT_DEBUG_MSG_LVL2_Raw("] ");
            PRINT_DEBUG_MSG_LVL2_UHex((uint8_T)esGetCommBuf(ES)[i]);
            PRINT_DEBUG_MSG_NL2;

            }

        }
    }
    #endif


EXIT_POINT:
   
    PRINT_DEBUG_MSG_LVL2("OUT, error status ");
    PRINT_DEBUG_MSG_LVL2_UDec(error);
    PRINT_DEBUG_MSG_NL2;

    return ;

}  /* end ExtSendGenericPkt */


/* Function: ExtGetParams ======================================================
 * Abstract:
 *  Send request to the target to upload the accessible parameters.  Block
 *  until the parameters arrive.  This is done during the connection process
 *  when inline parameters is 'on'.
 */
PRIVATE void ExtGetParams(
    ExternalSim    *ES,
    int_T          nrhs,
    const mxArray  *prhs[]) {
    
    int_T          nSet;
    int_T          nGot;
    int_T          bytesToGet;
    PktHeader      pktHdr;
    boolean_T      pending;
    boolean_T      error         = EXT_NO_ERROR;
    const ulong_T  timeOutSecs   = 10; // 60
    const ulong_T  timeOutUSecs  = 0;
    char_T         *buf         = esGetIncomingPktDataBuf(ES);

    // local function name... debugging only
    DEFINE_DEBUG_FNAME("ExtGetParams")

    PRINT_DEBUG_MSG_LVL2("IN\n");

    /*
     * Instruct target to send parameters.
     */
    pktHdr.type = (uint32_T)esGetAction(ES);
    pktHdr.size = 0;

    assert(pktHdr.type == EXT_GETPARAMS);

    Copy32BitsToTarget(ES, (char_T *)&pktHdr, (uint32_T *)&pktHdr, NUM_HDR_ELS);
    if (!esIsErrorClear(ES)) {

        goto EXIT_POINT;

    }

    error = ExtSetTargetPkt(ES, sizeof(pktHdr), (char_T *)&pktHdr, &nSet);
    if (error || (nSet != sizeof(pktHdr))) {

        esSetError(ES, "ExtSetTargetPkt() call failed for ExtSendGenericPkt().\n"
                       "Ensure target is still running\n");
                       
        goto EXIT_POINT;

    }

    /*
     * Wait for start of parameters packet - error if timeOut.
     */
    error = ExtTargetPktPending(ES, &pending, timeOutSecs, timeOutUSecs);
    if (error || !pending) {

        esSetError(ES, "ExtTargetPktPending() call failed while checking "
                       " for target pkt\n");
                       
        goto EXIT_POINT;

    }

    assert(pending);

    /*
     * Get packet header - assume that it's all there.
     */
    error = ExtRecvIncomingPktHeader(ES, &pktHdr);
    if (error) {

        goto EXIT_POINT;

    }

    /*
     * Convert size to host format/host bytes & verify packet type.
     */
    Copy32BitsFromTarget(ES, (uint32_T *)&pktHdr, (char_T *)&pktHdr, NUM_HDR_ELS);
    
    assert(pktHdr.type == EXT_GETPARAMS_RESPONSE);
    
    if (!esIsErrorClear(ES)) {

        goto EXIT_POINT;

    }

    bytesToGet = pktHdr.size * esGetHostBytesPerTargetByte(ES);

    /*
     * Get the parameters.
     */
    while (bytesToGet != 0) {

        /*
         * Look for any pending data.  If we ever go more than
         * 'timeOutVal' seconds, bail with an error.
         */
        error = ExtTargetPktPending(ES, &pending, timeOutSecs, timeOutUSecs);
        if (error || !pending) {

            esSetError(ES, "ExtTargetPktPending() call failed while checking "
                           " for target pkt\n");
                           
            goto EXIT_POINT;

        }

        /*
         * Grab the data.
         */
        error = ExtGetTargetPkt(ES, bytesToGet, &nGot, buf);
        if (error) {

            esSetError(ES, "ExtGetTargetPkt() call failed while checking target pkt's\n");
            
            goto EXIT_POINT;

        }

        buf        += nGot;
        bytesToGet -= nGot;
        
        assert(bytesToGet >= 0);

    }

EXIT_POINT:

    PRINT_DEBUG_MSG_LVL2("OUT, error status ");
    PRINT_DEBUG_MSG_LVL2_UDec(error);
    PRINT_DEBUG_MSG_NL2;

    return;

}  /* end ExtGetParams */


/*******************************************************************
 * Include ext_main.c, the mex file wrapper containing mexFunction *
 *******************************************************************/
#include "ext_main.c"


/* [EOF] ext_comm.c */




