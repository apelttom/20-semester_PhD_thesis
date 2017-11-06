/*
 *********************************************************************************************************
 *
 * freeport communication routines
 *
 * (c) Frank Wörnle, 2010
 * 
 *********************************************************************************************************
 *
 * File              : mc_freePortComms.c
 * Version           : 1.1
 * Last modification : 26.07.2010, Frank Wörnle
 *
 *********************************************************************************************************
 */



/*
 *********************************************************************************************************
 *    INCLUDES
 *********************************************************************************************************
 */


#include "bsp_includes.h"                        /* all controller specific includes         */
#include "bsp_sci.h"                             /* communication support for SCIx           */
#include "bsp_err.h"                             /* error memory support                     */

#include "app_cfg.h"                             /* application specific configurations      */

#include "mc_defines.h"                          /* Model dependent constants                */
#include "mc_signal.h"                           /* abort_LED                                */
#include "mc_freePortComms.h"                    /* MAX_FREECOM_CHANNELS, etc.               */



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
 *    MODULE GLOBAL VARIABLES
 *********************************************************************************************************
 */


/* Active FreePort communication channel */
static tBOOLEAN               FreePortSCI0initialized  = FALSE; 
static tINT16S                currentFPchannelSCI0     = -1; 
                  
#if BSP_SCI1_SUPP == 1
static tBOOLEAN               FreePortSCI1initialized  = FALSE; 
static tINT16S                currentFPchannelSCI1     = -1; 
#endif  /* BSP_SCI1_SUPP */





/*
 *********************************************************************************************************
 *    PUBLIC FUNCTIONS
 *********************************************************************************************************
 */

/*
 *********************************************************************************************************
 * Function      : FreePort_Init()
 *
 * Description   : This function initializes the FreePort communication system
 * Arguments     : port     - freeport communications port (0: SCI0, 1: SCI1)
 *                 baudrate - baudrate specifiers from bsp_sci.h (BAUD_300, ..., BAUD_115200, ...)
 * Return values : none
 * Comment       : function will block when the PLL does not stabilize
 *********************************************************************************************************
 */

tVOID FreePort_Init(tINT16U port, tINT8U baudrate) {

    /*
     * initialize FreePort reception ring buffer and configure port 
     */
    switch (port) {

        case 0:

            if (FreePortSCI0initialized == FALSE) {

                SCI0_Init(baudrate);
                
                /* indicate, that the freeport comms system has been initialized */
                FreePortSCI0initialized = TRUE;

            }

            break;

        #if BSP_SCI1_SUPP == 1

        case 1:

            if (FreePortSCI1initialized == FALSE) {

                SCI1_Init(baudrate);

                /* indicate, that the freeport comms system has been initialized */
                FreePortSCI1initialized = TRUE;

            }

            break;

        #endif /* BSP_SCI1_SUPP */

    }  /* switch */

}  /* end FreePort_Init */



/*
 *********************************************************************************************************
 * Function      : process_fpdata_SCI0()
 *
 * Description   : Attempts to read a telegram from the FreePort ring buffer. If one is found, it is
 *                 to the appropriate buffer. The function simply returns if there are less than 4 bytes 
 *                 in the reception buffer, otherwise it BLOCKS until the entire telegram has been received.
 * Arguments     : raw_data - indicates if formatted (0) or unformatted (1) data is to be sent
 * Return values : none
 * Comment       : function will block until the entire telegram has been received
 *********************************************************************************************************
 */

tVOID process_fpdata_SCI0(tINT16U raw_data) {

tINT8U             myBuf[4];
tINT16U            i;

static myUsrBuf   *admin;        /* static, coz they may get used in subsequent calls to this function */
static tINT16U     size;         /* static, coz they may get used in subsequent calls to this function */
static tINT8U     *buf;          /* static, coz they may get used in subsequent calls to this function */

    /* unformatted telegram? */
    if (raw_data) {
        
        /* yes -->  send raw data */
        
        /* using channel '0' for raw data transmissions */
        currentFPchannelSCI0 = 0;
        
        /* fetch channel data */
        admin = freecomTelBuf[currentFPchannelSCI0];
        size  = admin->buf_size;
        buf   = admin->buf;

    }

    /* beginning of telegram -- only applies to the reception of formatted data telegrams */
    if (currentFPchannelSCI0 == -1) {

        /* no header has previously been received -> try to fetch it*/

        /* read telegram header (if fully received) */
        if (SCI0_InStatus() >= 4) {

            // debug
            //PORTB |= 0x08;

            /* read first 4 bytes (size, channel, data_type_len, '0') */
            for (i = 0; i < 4; i++) {

                SCI0_InChar(&myBuf[i]);

            }

            /* set channel as per received header */
            currentFPchannelSCI0 = myBuf[1];
            
            /* fetch channel data */
            admin = freecomTelBuf[currentFPchannelSCI0];
            size  = admin->buf_size;
            buf   = admin->buf;

        } /* header available */

    } /* currentFPchannelSCI0 == -1 */


    /* reception of the telegram (raw data) / the remainder of the telegram (formatted data) */
    if (currentFPchannelSCI0 != -1) {

        /* a header has previously been received -> try to fetch remainder*/

        /* read remainder of the telegram (if available) */
        if (SCI0_InStatus() >= size) {

            /* at this stage, the entire remainder of the telegram is in the ring buffer */

            #ifdef DEBUG_ONLY
            /* read remaining bytes from the ring buffer */
            SCI0_InChar(buf)

            if(*buf == 5) {

                PORTB |= 0x01;

            }

            SCI0_InChar(++buf)

            if(*buf == 4) {

                PORTB |= 0x02;

            }
            
            SCI0_InChar(++buf)
            
            if(*buf == 3) {

                PORTB |= 0x04;

            }
            
            SCI0_InChar(++buf)
            
            if(*buf == 2) {

                PORTB |= 0x08;

            }
            
            SCI0_InChar(++buf)
            
            if(*buf == 1) {

                PORTB |= 0x10;

            }
            #endif  /* DEBUG_ONLY */

            /* receive 'size' bytes */
            for (i = 0; i < size; i++) {

                SCI0_InChar(buf++);

            }

            /* indicate receipt of a telegram */
            admin->buffer_full = 1;

            /* reset global variable 'currentFPchannel' */
            currentFPchannelSCI0 = -1;

            // debug
            //PORTB &= ~(0x08|0x04);

        } /* remainder in buffer */

    } /* currentFPchannelSCI0 != -1 */

}  /* End of process_fpdata_SCI0 */



#if BSP_SCI1_SUPP == 1

/*
 *********************************************************************************************************
 * Function      : process_fpdata_SCI1()
 *
 * Description   : Attempts to read a telegram from the FreePort ring buffer. If one is found, it is
 *                 to the appropriate buffer. The function simply returns if there are less than 4 bytes 
 *                 in the reception buffer, otherwise it BLOCKS until the entire telegram has been received.
 * Arguments     : raw_data - indicates if formatted (0) or unformatted (1) data is to be sent
 * Return values : none
 * Comment       : function will block until the entire telegram has been received
 *********************************************************************************************************
 */

tVOID process_fpdata_SCI1(tINT16U raw_data) {

tINT8U             myBuf[4];
tINT16U            i;

static myUsrBuf   *admin;        /* static, coz they may get used in subsequent calls to this function */
static tINT16U     size;         /* static, coz they may get used in subsequent calls to this function */
static tINT8U     *buf;          /* static, coz they may get used in subsequent calls to this function */

    /* unformatted telegram? */
    if (raw_data) {
        
        /* yes -->  send raw data */
        
        /* using channel '0' for raw data transmissions */
        currentFPchannelSCI1 = 0;
        
        /* fetch channel data */
        admin = freecomTelBuf[currentFPchannelSCI1];
        size  = admin->buf_size;
        buf   = admin->buf;

    }

    /* beginning of telegram -- only applies to the reception of formatted data telegrams */
    if (currentFPchannelSCI1 == -1) {

        /* no header has previously been received -> try to fetch it*/

        /* read telegram header (if fully received) */
        if (SCI1_InStatus() >= 4) {

            // debug
            //PORTB |= 0x08;

            /* read first 4 bytes (size, channel, data_type_len, '0') */
            for (i = 0; i < 4; i++) {

                SCI1_InChar(&myBuf[i]);

            }

            /* set channel as per received header */
            currentFPchannelSCI1 = myBuf[1];
            
            /* fetch channel data */
            admin = freecomTelBuf[currentFPchannelSCI1];
            size  = admin->buf_size;
            buf   = admin->buf;

        } /* header available */

    } /* currentFPchannelSCI1 == -1 */


    /* reception of the telegram (raw data) / the remainder of the telegram (formatted data) */
    if (currentFPchannelSCI1 != -1) {

        /* a header has previously been received -> try to fetch remainder*/

        /* read remainder of the telegram (if available) */
        if (SCI1_InStatus() >= size) {

            /* at this stage, the entire remainder of the telegram is in the ring buffer */

            #ifdef DEBUG_ONLY
            /* read remaining bytes from the ring buffer */
            SCI1_InChar(buf)

            if(*buf == 5) {

                PORTB |= 0x01;

            }

            SCI1_InChar(++buf)

            if(*buf == 4) {

                PORTB |= 0x02;

            }
            
            SCI1_InChar(++buf)
            
            if(*buf == 3) {

                PORTB |= 0x04;

            }
            
            SCI1_InChar(++buf)
            
            if(*buf == 2) {

                PORTB |= 0x08;

            }
            
            SCI1_InChar(++buf)
            
            if(*buf == 1) {

                PORTB |= 0x10;

            }
            #endif  /* DEBUG_ONLY */

            /* receive 'size' bytes */
            for (i = 0; i < size; i++) {

                SCI1_InChar(buf++);

            }

            /* indicate receipt of a telegram */
            admin->buffer_full = 1;

            /* reset global variable 'currentFPchannel' */
            currentFPchannelSCI1 = -1;

            // debug
            //PORTB &= ~(0x08|0x04);

        } /* remainder in buffer */

    } /* currentFPchannelSCI1 != -1 */

}  /* End of process_fpdata_SCI1 */

#endif /* BSP_SCI1_SUPP */



/*
 *********************************************************************************************************
 * Function      : put_fpdata_SCI0()
 *
 * Description   : Sends nbyte via free port SCI0.
 * Arguments     : channel  - data channel number (0 ... MAX_FREECOM_CHANNELS)
 *                 size     - number of message data bytes to be sent (excl. header)
 *                 dtype    - data type specifier
 *                 src      - source data buffer
 *                 raw_data - indicates the transmission of raw data
 * Return values : none
 * Comment       : -
 *********************************************************************************************************
 */

tVOID put_fpdata_SCI0(tINT8U channel, tINT8U size, tINT8U dtype, tINT8U *src, tINT8U raw_data) {

tINT16U   i;
tINT8U    myBuf[4];


    /* check if we need to send a header at all... (formatted telegrams) */
    if (!raw_data) {

        /* yes -> assemble header (size, channel, data_type_len, '0') */
        myBuf[0] = (tINT8U)(size+4);
        myBuf[1] = channel;
        myBuf[2] = dtype;
        myBuf[3] = 0;

        /* send header (4 bytes) */
        for (i = 0; i < 4; i++) {

            /* send next character of telegram header */
            SCI0_OutChar(myBuf[i]);
            //SCI0_OutChar(myBuf[i] + '0');                // send character (terminal)

        }

    }  /* raw_data == 0 */

    /* send remainder of the telegram (data) */
    for (i = 0; i < size; i++) {

        /* send next character of telegram data */
        SCI0_OutChar(src[i]);
        //SCI0_OutChar(src[i] + '0');                // send character (terminal)

    }

}  /* end of put_fpdata_SCI0 */



#if BSP_SCI1_SUPP == 1

/*
 *********************************************************************************************************
 * Function      : put_fpdata_SCI1()
 *
 * Description   : Sends nbyte via free port SCI1.
 * Arguments     : channel  - data channel number (0 ... MAX_FREECOM_CHANNELS)
 *                 size     - number of message data bytes to be sent (excl. header)
 *                 dtype    - data type specifier
 *                 src      - source data buffer
 *                 raw_data - indicates the transmission of raw data
 * Return values : none
 * Comment       : -
 *********************************************************************************************************
 */

tVOID put_fpdata_SCI1(tINT8U channel, tINT8U size, tINT8U dtype, tINT8U *src, tINT8U raw_data) {

tINT16U   i;
tINT8U    myBuf[4];


    /* check if we need to send a header at all... (formatted telegrams) */
    if (!raw_data) {

        /* yes -> assemble header (size, channel, data_type_len, '0') */
        myBuf[0] = (tINT8U)(size+4);
        myBuf[1] = channel;
        myBuf[2] = dtype;
        myBuf[3] = 0;

        /* send header (4 bytes) */
        for (i = 0; i < 4; i++) {

            /* send next character of telegram header */
            SCI1_OutChar(myBuf[i]);
            //SCI1_OutChar(myBuf[i] + '0');                // send character (terminal)

        }

    }  /* raw_data == 0 */

    /* send remainder of the telegram (data) */
    for (i = 0; i < size; i++) {

        /* send next character of telegram data */
        SCI1_OutChar(src[i]);
        //SCI1_OutChar(src[i] + '0');                // send character (terminal)

    }

}  /* end of put_fpdata_SCI1 */

#endif  /* BSP_SCI1_SUPP */
