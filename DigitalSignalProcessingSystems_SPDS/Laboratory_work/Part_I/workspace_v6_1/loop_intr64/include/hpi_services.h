// hpi_services.h
// dsk6713/6416 HPI daughtecard DSP services

#define HPI_SVC_QUEUE_SIZE          256

#ifdef _TMS320C6X    // skipped if not in CCS
// HPI services data transfer block
typedef struct {
    volatile unsigned short flag;
    volatile unsigned short baud;
    volatile unsigned int ddir;                             // digital I/O direction (1 = output)
    volatile unsigned int dout;                             // digital output values
    volatile unsigned int din;                              // digital input values
    volatile unsigned int aen;                              // aen I/O enables (1 = enabled)
    volatile unsigned short an0;                            // analog 0 value
    volatile unsigned short an1;                            // analog 1 value
    volatile unsigned short an2;                            // analog 2 value
    volatile unsigned short an3;                            // analog 3 value
    volatile unsigned short an4;                            // analog 4 value
    volatile unsigned short an5;                            // analog 5 value
    volatile unsigned short an6;                            // analog 6 value
    volatile unsigned short an7;                            // analog 7 value

    // used by DSP only
    volatile unsigned char  com_tx_tail;                    // COM tx buffer tail index
    volatile unsigned char  com_rx_head;                    // COM rx buffer head index
    volatile unsigned char  usb_tx_tail;                    // USB rx buffer tail index
    volatile unsigned char  usb_rx_head;                    // USB rx buffer head index

    // used by HPI host only
    volatile unsigned char  com_tx_head;                    // COM tx buffer head index
    volatile unsigned char  com_rx_tail;                    // COM rx buffer tail index
    volatile unsigned char  usb_tx_head;                    // USB tx buffer head index
    volatile unsigned char  usb_rx_tail;                    // USB rx buffer tail index

    // buffers are int's since HPI is 32-bit only
    volatile unsigned int   com_tx_buf[HPI_SVC_QUEUE_SIZE]; // COM tx buffer
    volatile unsigned int   com_rx_buf[HPI_SVC_QUEUE_SIZE]; // COM rx buffer
    volatile unsigned int   usb_tx_buf[HPI_SVC_QUEUE_SIZE]; // USB tx buffer
    volatile unsigned int   usb_rx_buf[HPI_SVC_QUEUE_SIZE]; // USB rx buffer
} HPI_SVC_BLOCK;
#endif

#define HPI_SVC_XFER_ADDRESS            0x01A007F8 // in EDMA scratch RAM
#define DSP_TO_HOST_MAGIC_NUMBER        0x0313
#define HOST_TO_DSP_MAGIC_NUMBER        0x0930

#define HPI_SVC_ANALOG_MAX_VALUE		    4096                // 12-bit ADC

// baud rate divisors for the MSP430 serial port
#define HPI_SVC_BAUD115200							(64)
#define HPI_SVC_BAUD57600								(128)
#define HPI_SVC_BAUD38400								(192)
#define HPI_SVC_BAUD19200								(384)
#define HPI_SVC_BAUD9600								(768)
#define HPI_SVC_BAUD4800								(1536)
#define HPI_SVC_BAUD2400								(3072)
#define HPI_SVC_BAUD1200								(6144)

// offsets of fields with HPI_SVC_BLOCK
#define HPI_SVC_FLAG_OFFSET             0
#define HPI_SVC_BAUD_OFFSET             2
#define HPI_SVC_DDIR_OFFSET             4
#define HPI_SVC_DOUT_OFFSET             8
#define HPI_SVC_DIN_OFFSET              12
#define HPI_SVC_AEN_OFFSET              16
#define HPI_SVC_AN0_OFFSET              20
#define HPI_SVC_AN1_OFFSET              22
#define HPI_SVC_AN2_OFFSET              24
#define HPI_SVC_AN3_OFFSET              26
#define HPI_SVC_AN4_OFFSET              28
#define HPI_SVC_AN5_OFFSET              30
#define HPI_SVC_AN6_OFFSET              32
#define HPI_SVC_AN7_OFFSET              34
#define HPI_SVC_COMTXTAIL_OFFSET        36
#define HPI_SVC_COMRXHEAD_OFFSET        37
#define HPI_SVC_USBTXTAIL_OFFSET        38
#define HPI_SVC_USBRXHEAD_OFFSET        39
#define HPI_SVC_COMTXHEAD_OFFSET        40
#define HPI_SVC_COMRXTAIL_OFFSET        41
#define HPI_SVC_USBTXHEAD_OFFSET        42
#define HPI_SVC_USBRXTAIL_OFFSET        43
#define HPI_SVC_COMTXBUF_OFFSET         44
#define HPI_SVC_COMRXBUF_OFFSET         (HPI_SVC_COMTXBUF_OFFSET+(HPI_SVC_QUEUE_SIZE*4))
#define HPI_SVC_USBTXBUF_OFFSET         (HPI_SVC_COMRXBUF_OFFSET+(HPI_SVC_QUEUE_SIZE*4))
#define HPI_SVC_USBRXBUF_OFFSET         (HPI_SVC_USBTXBUF_OFFSET+(HPI_SVC_QUEUE_SIZE*4))

#define HPI_SVC_DSP_INDEXES_OFFSET  HPI_SVC_COMTXTAIL_OFFSET
#define HPI_SVC_HOST_INDEXES_OFFSET HPI_SVC_COMTXHEAD_OFFSET
