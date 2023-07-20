
// hpi_services_funcs.h
// HPI service support for 6713 DSK with HPI daughtercard


// DSP API functions
#ifdef __cplusplus
extern "C" {
#endif

int StartHpiServices(); 
void SetBaudRate(unsigned short);
int IsHpiDataNew();
void SetDigitalIoDirection(unsigned short);
unsigned short ReadDigitalIo();
void WriteDigitalIo(unsigned short);
void EnableAnalog(unsigned short);
unsigned short ReadAnalog(unsigned short);
unsigned int ReadSerial(char*, unsigned int);
unsigned int ReadUsb(char*, unsigned int);
unsigned int WriteSerial(char*, unsigned int);
unsigned int WriteUsb(char*, unsigned int);

#ifdef __cplusplus
}
#endif


