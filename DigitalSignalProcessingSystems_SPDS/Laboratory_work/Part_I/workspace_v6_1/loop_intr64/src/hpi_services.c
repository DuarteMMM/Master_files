
// hpi_services.c
// HPI service support for 6713/6416 DSK with HPI daughtercard

#include <c6x.h>
#include "hpi_services.h"
#include "hpi_services_funcs.h"

// DSP API functions

#define NUMBER_OF_HPI_INIT_RETRIES	100000			// retries on initialization

HPI_SVC_BLOCK HpiSvcBlock = {
	0, // flag
	HPI_SVC_BAUD115200 // default baud rate
};

int StartHpiServices() 
{
	unsigned int i;
	
//	HpiSvcBlock.ddir = 0xFFFF; 						// all digital pins inputs
//	HpiSvcBlock.aen = 0; 							// all analog disabled
	HpiSvcBlock.com_tx_head = 0;					// show all buffers empty
	HpiSvcBlock.com_rx_head = 0;
	HpiSvcBlock.usb_tx_head = 0;
	HpiSvcBlock.usb_rx_head = 0;
	HpiSvcBlock.com_tx_tail = 0;
	HpiSvcBlock.com_rx_tail = 0;
	HpiSvcBlock.usb_tx_tail = 0;
	HpiSvcBlock.usb_rx_tail = 0;
 
	*(unsigned int *)HPI_SVC_XFER_ADDRESS = (unsigned int)&HpiSvcBlock; 	// store data structure address
	HpiSvcBlock.flag = DSP_TO_HOST_MAGIC_NUMBER; 		// store magic number

	// signal HPI daughtercard to start services by writing 1 to HINT bit in HPIC
	*(unsigned int *)0x01880000 = 0x00000004;
	
	for(i = 0;i < NUMBER_OF_HPI_INIT_RETRIES;i++)		// wait for daughtercard to reply
		if(HpiSvcBlock.flag == HOST_TO_DSP_MAGIC_NUMBER)
			return 1;

	return 0;
}

void SetBaudRate(unsigned short baud_divider)
{
	HpiSvcBlock.baud = baud_divider;
}

int IsHpiDataNew()
{
	static unsigned short last_flag = 0;
	
	if(last_flag != HpiSvcBlock.flag) {
		last_flag = HpiSvcBlock.flag;
		return 1;
	}
	return 0;
}

void SetDigitalIoDirection(unsigned short mask)
{
	HpiSvcBlock.ddir = mask;
}

unsigned short ReadDigitalIo()
{
	return HpiSvcBlock.din;
}

void WriteDigitalIo(unsigned short val)
{
	HpiSvcBlock.dout = val;
}

void EnableAnalog(unsigned short number)
{
	HpiSvcBlock.aen = number;
}

unsigned short ReadAnalog(unsigned short pin)
{
	switch(pin) {
	case 0:
		return HpiSvcBlock.an0;
	case 1:
		return HpiSvcBlock.an1;
	case 2:
		return HpiSvcBlock.an2;
	case 3:
		return HpiSvcBlock.an3;
	case 4:
		return HpiSvcBlock.an4;
	case 5:
		return HpiSvcBlock.an5;
	case 6:
		return HpiSvcBlock.an6;
	case 7:
		return HpiSvcBlock.an7;
}
	return 0; // out of bounds
}

unsigned int ReadSerial(char* s, unsigned int n)
{
	unsigned int count = 0;

	while((count < n) && (HpiSvcBlock.com_rx_head != HpiSvcBlock.com_rx_tail)) {
		*s++ = (char)HpiSvcBlock.com_rx_buf[HpiSvcBlock.com_rx_head];
		HpiSvcBlock.com_rx_head++;
		count++;
	}
	return count;
}

unsigned int ReadUsb(char* s, unsigned int n)
{
	unsigned int count = 0;

	while((count < n) && (HpiSvcBlock.usb_rx_head != HpiSvcBlock.usb_rx_tail)) {
		*s++ = (char)HpiSvcBlock.usb_rx_buf[HpiSvcBlock.usb_rx_head];
		HpiSvcBlock.usb_rx_head++;
		count++;
	}
	return count;
}

unsigned int WriteSerial(char* s, unsigned int n)
{
	unsigned int count = 0;

	while((count < n) && ((HpiSvcBlock.com_tx_tail+1) != HpiSvcBlock.com_tx_head)) {
		HpiSvcBlock.com_tx_buf[HpiSvcBlock.com_tx_tail] = *s++;
		HpiSvcBlock.com_tx_tail++;
		count++;
	}
	return count;
}

unsigned int WriteUsb(char* s, unsigned int n)
{
	unsigned int count = 0;

	while((count < n) && ((HpiSvcBlock.usb_tx_tail+1) != HpiSvcBlock.usb_tx_head)) {
		HpiSvcBlock.usb_tx_buf[HpiSvcBlock.usb_tx_tail] = *s++;
		HpiSvcBlock.usb_tx_tail++;
		count++;
	}
	return count;
}

