/*
 *  Copyright 2010 by Spectrum Digital Incorporated.
 *  All rights reserved. Property of Spectrum Digital Incorporated.
 */

#define AIC3204_I2C_ADDR 0x18
#include "usbstk5515.h"
#include "usbstk5515_gpio.h"
#include "usbstk5515_i2c.h"
#include "stdio.h"
#include "usbstk5515.h"
extern Int16 AIC3204_rset( Uint16 regnum, Uint16 regval);
#define Rcv 0x08
#define Xmit 0x20

/* ------------------------------------------------------------------------ *
 *                                                                          *
 *  main( )                                                                 *
 *                                                                          *
 * ------------------------------------------------------------------------ */
void main( void )
{
    /* Initialize BSL */
    USBSTK5515_init( );

    /* Configure AIC3204 */

       AIC3204_rset( 0, 0 );          // Select page 0
       AIC3204_rset( 1, 1 );          // Reset codec
       AIC3204_rset( 0, 1 );          // Select page 1
       AIC3204_rset( 1, 8 );          // Disable crude AVDD generation from DVDD
       AIC3204_rset( 2, 1 );          // Enable Analog Blocks, use LDO power
       AIC3204_rset( 0, 0 );          // Select page 0
       /* PLL and Clocks config and Power Up  */
       AIC3204_rset( 27, 0x0d );      // BCLK and WCLK is set as o/p to AIC3204(Master)
       AIC3204_rset( 28, 0x00 );      // Data ofset = 0
       AIC3204_rset( 4, 3 );          // PLL setting: PLLCLK <- MCLK, CODEC_CLKIN <-PLL CLK
       AIC3204_rset( 6, 7 );          // PLL setting: J=7
       AIC3204_rset( 7, 0x06 );       // PLL setting: HI_BYTE(D=1680)
       AIC3204_rset( 8, 0x90 );       // PLL setting: LO_BYTE(D=1680)
       AIC3204_rset( 30, 0x88 );      // For 32 bit clocks per frame in Master mode ONLY
                                      // BCLK=DAC_CLK/N =(12288000/8) = 1.536MHz = 32*fs
       AIC3204_rset( 5, 0x91 );       // PLL setting: Power up PLL, P=1 and R=1
       AIC3204_rset( 13, 0 );         // Hi_Byte(DOSR) for DOSR = 128 decimal or 0x0080 DAC oversamppling
       AIC3204_rset( 14, 0x80 );      // Lo_Byte(DOSR) for DOSR = 128 decimal or 0x0080
       AIC3204_rset( 20, 0x80 );      // AOSR for AOSR = 128 decimal or 0x0080 for decimation filters 1 to 6
       AIC3204_rset( 11, 0x86 );      // Power up NDAC and set NDAC value to 6 (fs=16kHz)
       AIC3204_rset( 12, 0x87 );      // Power up MDAC and set MDAC value to 7
       AIC3204_rset( 18, 0x87 );      // Power up NADC and set NADC value to 7
       AIC3204_rset( 19, 0x86 );      // Power up MADC and set MADC value to 6 (fs=16kHz)
       /* DAC ROUTING and Power Up */
       AIC3204_rset(  0, 0x01 );      // Select page 1
       AIC3204_rset( 12, 0x08 );      // LDAC AFIR routed to HPL
       AIC3204_rset( 13, 0x08 );      // RDAC AFIR routed to HPR
       AIC3204_rset(  0, 0x00 );      // Select page 0
       AIC3204_rset( 64, 0x02 );      // Left vol=right vol
       AIC3204_rset( 65, 0x00 );      // Left DAC gain to 0dB VOL; Right tracks Left
       AIC3204_rset( 63, 0xd4 );      // Power up left,right data paths and set channel
       AIC3204_rset(  0, 0x01 );      // Select page 1
       AIC3204_rset( 16, 0x00 );      // Unmute HPL , 0dB gain
       AIC3204_rset( 17, 0x00 );      // Unmute HPR , 0dB gain
       AIC3204_rset(  9, 0x30 );      // Power up HPL,HPR
       AIC3204_rset(  0, 0x00 );      // Select page 0
       USBSTK5515_wait( 500 );        // Wait

       /* ADC ROUTING and Power Up */
       AIC3204_rset( 0, 1 );          // Select page 1
       AIC3204_rset( 0x34, 0x30 );    // STEREO 1 Jack
   		                           // IN2_L to LADC_P through 40 kohm
       AIC3204_rset( 0x37, 0x30 );    // IN2_R to RADC_P through 40 kohmm
       AIC3204_rset( 0x36, 3 );       // CM_1 (common mode) to LADC_M through 40 kohm
       AIC3204_rset( 0x39, 0xc0 );    // CM_1 (common mode) to RADC_M through 40 kohm
       AIC3204_rset( 0x3b, 0x18 );       // MIC_PGA_L unmute
       AIC3204_rset( 0x3c, 0x18 );       // MIC_PGA_R unmute
       AIC3204_rset( 0, 0 );          // Select page 0
       AIC3204_rset( 0x51, 0xc0 );    // Powerup Left and Right ADC
       AIC3204_rset( 0x52, 0 );       // Unmute Left and Right ADC

       AIC3204_rset( 0, 0 );
       USBSTK5515_wait( 200 );        // Wait
       /* I2S settings */
       I2S0_SRGR = 0x0;
       I2S0_CR = 0x8010;    // 16-bit word, slave, enable I2C
       I2S0_ICMR = 0x3f;    // Enable interrupts



       Int16 DataInLeft, DataInRight, DataOutLeft, DataOutRight;
       Int16 r=0, Delta, index=0, y , i, f, y1, y2;
       //Int16 Delta=8192;
       Int16 Buffer[32];

       Int16 Delta_0=16384, Delta_min=8192, Delta_max=24576; // f0=4kHz, f_min=2kHz, f_max=6kHz
       Int16 lut[32]={0,3212,6393,9512,12539,15446,18204,20787,23170,25329,27245,28898,30273,31356,32137,32609,32767,32609,32137,31356,30273,28898,27245,25329,23170,20787,18204,15446,12539,9512,6393,3212};
       Int16 Gain=16384, K0=19051;

       Delta=Delta_0;

       Int16 alpha = 31530; //Q15 de 0.9622139467, for 100Hz
       Uint16 counter=0;
       //Int16 alpha = 32640; //Q15 de 0.9960883701, for 10Hz

       Int16 erro[2] = {0, 0}; //erro[1] -> atual; erro[0] -> anterior
       Int32 erro_int[2] = {0, 0}; //integração do erro
       Int16 erro_f = 0; //erro final pós CIC

       Int16 xD = 0; //multiplicação de entrada (x) com sinal gerado internamete (y)
       Int16 x = 0; // sinal de entrada

       Int16 a1 = 0, a1_approx=0, a2 = -27987, b0 = 2391, b2 = -2391, K_f = 23170, K_f_approx = 23170; // +-23170(Q15) ou 0
       Int16 y_n = 0, y_n1 = 0, y_n2 = 0, y_n_approx = 0, y_n1_approx = 0, y_n2_approx = 0, x_n = 0, x_n1=0, x_n2 = 0;
       Int16 Angle, i_K_f, f_K_f, K_f_1, K_f_2; // For exact value of K_f

       //Int16 pi_2=25736; // Q14
       //Int16 K1_2=16384; // Q15
       Int16 pi_2=30679 ; // Q14 - ajustado com a multiplicação por K_e = 1.1921
       Int16 K1_2= 19631; // Q15 - ajustado com a multiplicação por K_e = 1.1921
       Int16 K_a1=30376; // 2*(1-Kb)=1.854 Q14


       while(1) {
                	/* Read Digital audio */
                	while((Rcv & I2S0_IR) == 0);  // Wait for interrupt pending flag
                    DataInLeft = I2S0_W1_MSW_R;  // 16 bit left channel received audio data
          	        DataInRight = I2S0_W0_MSW_R;  // 16 bit right channel received audio data
    				/* Write Digital audio */
          	        while((Xmit & I2S0_IR) == 0);  // Wait for interrupt pending flag
    				I2S0_W1_MSW_W = DataOutLeft;  // 16 bit left channel transmit audio data
          	        I2S0_W0_MSW_W = DataOutRight;  // 16 bit right channel transmit audio data

//--------------------------------------------------------------------------------------------------------------------
 // Your program here!!!
//--------------------------------------------------------------------------------------------------------------------

// x(n)
x_n = DataInLeft;

// NCO
Delta = Delta_0 + ((((long)K0*erro[1])<<1)>>16); //k=8192 = 0.25
r+=Delta;
i = (r>>10)&(31);
f=(r&1023)<<5; // Q15
y1=lut[i]; // Q15
y2=lut[(i+1)&31]; // Q15
if (r<0){
	y1=-y1;
	y2=-y2;
}
y=y1+((((long)(y2-y1)*f)<<1)>>16); // onda gerada pelo oscilador

//Phase detector
xD = ((((long)x_n * y)<<1)>>16);

//Loop filter
erro[1] = ((((long)alpha*erro[0])<<1) + ((((long)(32767-alpha) * xD)<<1)))>>16;
erro[0] = erro[1];

erro_int[1] += erro[1];

//DataOutRight = y; -> used before question 4, after which use two Kfs
//DataOutRight = erro[1];			// loop right channel samples

//erro[1]=16384;
//if ((counter++)%32 == 0){

// Frequency control
if (counter==8192){
	erro_f = (erro_int[1] - erro_int[0])>>13;
	erro_int[0] = erro_int[1];


	K_f_approx=((((long)-pi_2*erro_f)<<2)>>16);
	//K_f_approx=((((long)-25736*erro[1])<<2)>>16); // Q14 -> usado para testes iniciais na pergunta 4

	//Angle=((((long)16384*erro[1])<<1)>>16); // Q15->mudar?
	Angle=((((long)K1_2*erro_f)<<1)>>16);
	//Angle=erro[1]>>1;

	i_K_f=(Angle>>10)&(31);
	f_K_f=(Angle&1023)<<5; // Q15
	//K_f_1=-lut[i_K_f];
	//K_f_2=-lut[(i_K_f+1)&31];
	K_f_1=lut[i_K_f];
	K_f_2=lut[(i_K_f+1)&31];
	if (Angle<0){
		K_f_1=-K_f_1;
		K_f_2=-K_f_2;
	}
	K_f=K_f_1+((((long)(K_f_2-K_f_1)*f_K_f)<<1)>>16); // onda gerada pelo oscilador

	K_f=-K_f;

	a1 = ((((long) 	K_a1*K_f)<<1)>>16); // (Q14) -> Q14xQ15=Q14, down shift 2
	a1_approx = ((((long) K_a1*K_f_approx)<<1)>>16); // (Q14) -> Q14xQ15=Q14, down shift 2

	counter=0;
}


// y[n] = 1.8541*K_f*y[n-1] - 0.8541*y[n-2] + 0.0730*x[n] - 0.0730*x[n-2]

//        30377(Q14)*K_f*y[n-1] - 27987(Q15)*y[n-2] + 2391(Q15)*x[n] - 2391(Q15)*x[n-2]
//a1 = ((((long) 30377*K_f)<<1)>>16); // (Q14) -> Q14xQ15=Q14, down shift 2

//a1_approx = ((((long) 30377*K_f_approx)<<1)>>16); // (Q14) -> Q14xQ15=Q14, down shift 2

//Filtro IIR
y_n = (((((long) a1*y_n1)<<2) + (((long) a2*y_n2)<<1) + (((long) b0*x_n)<<1) + (((long) b2*x_n2)<<1))>>16);
y_n_approx = (((((long) a1_approx*y_n1_approx)<<2) + (((long) a2*y_n2_approx)<<1) + (((long) b0*x_n)<<1) + (((long) b2*x_n2)<<1))>>16);


y_n2=y_n1;
y_n1=y_n;

y_n2_approx=y_n1_approx;
y_n1_approx=y_n_approx;

x_n2=x_n1;
x_n1=x_n;

DataOutLeft = y_n_approx;
counter+=1;
DataOutRight = y_n;
//DataOutLeft=erro_f;->questao4
//DataOutRight=erro_int[1];->questao4

//CIC filter - falta incluir entre Loop filter e Frequency control
//erro[1]+=erro[1]_previous~
//e'/e=1/(1-z^-1) logo e'=e-e_previous

//Depois, decimação - não percebi, pq mudamos K_f? é só mudar o erro de M em M vezes? Also, dividir por M para ter ganho unitário em 0 (aula teorica). O K_F tem a ver com frequency control...

//erro[1]-=erro[1]_previous
//e_f/e'=1-z^-1 logo e_f=e'-e'_previous


//--------------------------------------------------------------------------------------------------------------------
// Your program here!!!
//--------------------------------------------------------------------------------------------------------------------
  } // while(1)
 } // main()












