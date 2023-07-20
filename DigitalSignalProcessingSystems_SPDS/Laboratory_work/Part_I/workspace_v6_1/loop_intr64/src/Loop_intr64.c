//Loop_intr.c Loop program using interrupt. Output = delayed input

#include "C6416dskinit.h"
#include "dsk6416_aic23.h"				//codec-DSK support file

unsigned int 	fs=DSK6416_AIC23_FREQ_16KHZ;	//set sampling rate
char	intflag = FALSE;

volatile unsigned int IsrKeyFlag = 0, IsrKeyData = 0;

union {Uint32 samples; short channel[2];} AIC_buffer;

interrupt void c_int11()         	//interrupt service routine
{
   output_sample(AIC_buffer.samples);   	//output data
   AIC_buffer.samples= input_sample(); 	    //input data
   intflag = TRUE;
   return;
}

void main()
{
  short 	inbuf, outbuf;

  comm_intr();                  //init DSK, codec, McBSP
  while(1){                	   	//infinite loop

	  while(intflag == FALSE);
      intflag = FALSE;

      inbuf = AIC_buffer.channel[LEFT];		// faz loop do canal ESQUERDO
      outbuf = inbuf;
      AIC_buffer.channel[LEFT] = outbuf;

      inbuf = AIC_buffer.channel[RIGHT];	// faz loop do canal DIREITO
      outbuf = inbuf;
      AIC_buffer.channel[RIGHT] = outbuf;
	
  }
}
