//Loop_intr.c Loop program using interrupt. Output = delayed input

#include "dsk6713_aic23.h"		//codec-DSK support file
#include "C6713dskinit.h"

Uint32 fs=DSK6713_AIC23_FREQ_16KHZ;	//set sampling rate

char	intflag = FALSE;
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

  comm_intr();                   	//init DSK, codec, McBSP
  while(1){                	   	//infinite loop
    while(intflag == FALSE);
      intflag = FALSE;
      //-----------------------------------------------------------------
            // Processamento específico
            //-----------------------------------------------------------------
            //declare the variables for the filter equations
                short xn;
                short y1n;
                short yn;
                short w1_n, w1_2n, w1n, w2_n, w2_2n, w2n
                int y1;
                int y;
                int w1, w2;

                //declare the coeficients and it's values
                //first biquad
                short d01 = 32767;
                short d11 = 31061;
                short d21 = -24444;
                short c01 = 8959;
                short c11 = 0;
                short c21 = -8959;

                //second biquad
                short d02 = 32767;
                short D12 = 20116; //d12>1, so it was reduced
                short d22 = -27692;
                short c02 = 5462;
                short c12 = 0;
                short c22 = -5462;

                //filter
                xn = AIC_buffer.channel[LEFT];
                w1 = (xn<<15) + (int)(d11*w1_n) + (int)(d21*w1_2n);

                w1n = w1>>15;

                y1 = (int)(c01*w1n) + (int)(c11*w1_n) + (int)(c21*w1_2n);
                y1n = y1>>15;

                w1_2n = w1_n;
                w1_n = w1n;


                w2 = (y1n<<15) + (w2_n<<15) + (int)(D12*w2_n) + (int)(d22*w2_2n);

                w2n = w2>>15;

                y = (int)(c02*w2n) + (int)(c12*w2_n) + (int)(c22*w2_2n);
                yn = y>>15;

                w2_2n = w2_n;
                w2_n = w2n;

                AIC_buffer.channel[LEFT] = yn;
  }

}


