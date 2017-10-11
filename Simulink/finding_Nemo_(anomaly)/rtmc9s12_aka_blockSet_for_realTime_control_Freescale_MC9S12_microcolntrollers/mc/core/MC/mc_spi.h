/**
 * Header for SPI. See SPI.c for documentation.
 *
 * @author Stephen Craig 25/07/2006
 */

#ifndef _SPI_H_
#define _SPI_H_

#define CE        PTM_PTM7      /* Chip enable */

#define CSN       PTS_PTS7      /* Chip Select (active low) */
#define CSN_DDR   DDRS_DDRS7    /* Chip Select Data Direction */

// Macros for OnBoard DAC
#define CSDAC PTM_PTM6
#define CSDAC_DDR DDRM_DDRM6

// bits 6,5,4 are SPPR, bits 2,1,0 are SPR
// divisor is (1+SPPR)*2**(SPR+1)
// clock is 24MHz

// WARNING:
// Including a new baud rate should be followed by updating SPI_Pause()
#define SPI_BAUD_46875    0x17           // divisor 2*2^8 = 512
#define SPI_BAUD_93750    0x07           // divisor 1*2^8 = 256
#define SPI_BAUD_187500   0x06           // divisor 1*2^7 = 128
#define SPI_BAUD_375000   0x05           // divisor 1*2^6 = 64
#define SPI_BAUD_750000   0x04           // divisor 1*2^5 = 32
#define SPI_BAUD_1500000  0x03           // divisor 1*2^4 = 16
#define SPI_BAUD_3000000  0x02           // divisor 1*2^3 = 8
#define SPI_BAUD_6000000  0x01           // divisor 1*2^2 = 4
#define SPI_BAUD_12000000 0x00           // divisor 1*2^1 = 2

void SPI_Init(unsigned char baudRate);

void SPI_Pause(void);

void SPI_OutChar(unsigned char c);
void SPI_OutChar2(unsigned char command, unsigned char data);
void SPI_OutChar2DAC(unsigned char high, unsigned char low);
void SPI_OutChar3(unsigned char command,
                  unsigned char *data,
                  unsigned char len);

unsigned char SPI_InChar(void);

void SPI_Read(unsigned char command,
              unsigned char *data,
              unsigned char len);

#endif // _SPI_H_
