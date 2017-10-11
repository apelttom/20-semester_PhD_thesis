/**
 * Header for server nRF24L01 code.
 *
 * @author Stephen Craig, 25/07/2006
 */

#ifndef _RADIO_SERVER_H_
#define _RADIO_SERVER_H_

#include "mc_spi.h"                /* support for SPI */

/* payload length */
#define PAYLOAD_LEN 32             /* maximum is 32, minimum is 5 */

/* default baud rate */
#define RADIO_DEFAULT_BAUD_RATE    SPI_BAUD_6000000


// there can be up to '5' clients
#define CLIENT_COUNT_MAX  5

// flags set in the clientFlags register which to signify what clients
// are active (for a server), and used by clients to determine what
// the LSB of their address should be.
// match the EN_RXADDR flags
#define CLIENT_FLAG_0     0x02
#define CLIENT_FLAG_1     0x04
#define CLIENT_FLAG_2     0x08
#define CLIENT_FLAG_3     0x10
#define CLIENT_FLAG_4     0x20

#define INIT_NO_ERROR             0
#define INIT_ERROR_NO_POWER       1
#define INIT_ERROR_NO_CLIENTS_SET 2

#ifdef NULL
#undef NULL
#define NULL                   ((tVOID *) 0)
#endif

/**
 * Initialises the radio transceiver.
 * @param baudRate rate at which to comm with module on SPI
 * @param rf_channel should be between 0 and 127
 * @param serverAddressHeader first four bytes of server address
 * @param clientAddressHeader first four bytes of client addresses
 * @param client one of CLIENT_FLAG_0, CLIENT_FLAG_1, etc.
 * @return one of the INIT_XXX values
 */
tINT8U RadioServer_Init(tINT8U baudRate,
                               tINT8U rfChannel,
                               tINT32U serverAddressHeader,
                               tINT32U clientAddressHeader,
                               tINT8U clientFlags);

/**
 * ISR for when the radio module should be polled.
 */

#define CPL_PRAGMA_ISR_START
#include "cpl_pragma.h"

extern CPL_INTERRUPT tVOID RadioServer_OnTick(tVOID);

#define CPL_PRAGMA_ISR_STOP
#include "cpl_pragma.h"


/**
 * This method will cycle through all the channels and increment an array
 * element corresponding to an RF channel if a signal is detected on that channel.
 * The lower the number of carrier detects, the better choice that channel is.
 * Advisable to let this run for about 10 minutes...
 * Use hyperterminal to output this to "CAPTURE.csv" file. Open in Excel. Remove
 * all but the last 128 rows. Then sort on the second column (CD count). The
 * channels will be sorted by their relative superiority.
 */
extern tVOID RadioServer_CheckCarrier(tVOID);

/**
 * Use this method to dynamically enable a certain client on the
 * network.
 */
extern tVOID RadioServer_AddClient(tINT8U client);

/**
 * Use this method to dynamically disable a certain client on the
 * network.
 */
extern tVOID RadioServer_RemoveClient(tINT8U client);

/**
 * Will add val to the end of the transmit FIFO buffer of the selected
 * client. This function will return 1 if the buffer was full and the
 * character was not added to the transmit buffer.
 */
extern tINT8U RadioServer_OutChar(tINT8U client,
                                         tINT8U val);

/**
 * Will add val[0], val[1], ... val[len-1] to the end of the transmit
 * FIFO buffer. This function will busy-wait if the buffer is full.
 */
extern tVOID RadioServer_OutCharArray(tINT8U client,
                                     tINT8U *pt,
                                     tINT8U len);

/**
 * Will add the \0 terminated string to the end of the transmit FIFO
 * buffer. This function will busy-wait if the buffer is full.
 */
extern tVOID RadioServer_OutString(tINT8U client,
                                  tINT8U *pt);

/**
 * Will empty the transmit buffer.
 */
extern tVOID RadioServer_CleanOut(tINT8U client);

/**
 * Will empty the receive buffer.
 */
extern tVOID RadioServer_CleanIn(tINT8U client);

/**
 * Returns true if the transmit buffer is full.
 */
extern tINT8U RadioServer_IsOutFull(tINT8U client);

/**
 * Returns true if the transmit buffer is empty.
 */
extern tINT8U RadioServer_IsOutEmpty(tINT8U client);

/**
 * Returns true if the receive buffer is full.
 */
extern tINT8U RadioServer_IsInFull(tINT8U client);

/**
 * Returns true if the receive buffer is empty.
 */
extern tINT8U RadioServer_IsInEmpty(tINT8U client);

/**
 * Returns the number of elements stored in a receive buffer.
 */
extern tINT8U RadioServer_HasElements(tINT8U client);

/**
 * Clean the input buffer of the selected client.
 */
extern tVOID RadioServer_CleanIn(tINT8U client);

/**
 * Clean the output buffer of the selected client.
 */
extern tVOID RadioServer_CleanOut(tINT8U client);

/**
 * Returns the byte at the head of the receive FIFO buffer, and
 * removes it from the buffer. If the buffer is empty, this method
 * will busy wait until there is data available.
 */
extern tINT8U RadioServer_InChar(tINT8U client);

/**
 * Removes len bytes from the head of the receive FIFO buffer, and
 * writes them to charArray. If the buffer is empty, this method
 * will busy wait until there is data available.
 */
extern tVOID RadioServer_InCharArray(tINT8U client,
                                    tINT8U *pt,
                                    tINT8U len);

/**
 * Returns the number of times the selected client has timed out since
 * server/client reset.
 */
extern tINT16U RadioServer_GetFailureCount(tINT8U client);

extern tVOID RadioServer_OutStatusClient(tINT8U client);

#endif // _RADIO_SERVER_H_
