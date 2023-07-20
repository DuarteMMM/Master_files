//sine8_buf Sine generation. Output buffer plotted within CCS

#include "dsk6713_aic23.h"						//support file for codec,DSK
Uint32 fs=DSK6713_AIC23_FREQ_8KHZ;			//set sampling rate
int loop = 0;   									//table index
short gain = 10;									//gain factor
short sine_table[8]={0,707,1000,707,0,-707,-1000,-707};//sine values
short out_buffer[256];              		//output buffer
const short BUFFERLENGTH = 256;     		//size of output buffer
int i = 0;                  	    			//for buffer count

interrupt void c_int11()            		//interrupt service routine
{
  output_sample(sine_table[loop]*gain);	//output sine values
  out_buffer[i] = sine_table[loop]*gain; 		//output to buffer
  i++;				    							//increment buffer count
  if(i==BUFFERLENGTH) i=0;						//if @ bottom reinit count
  if (loop < 7) ++loop;            			//check for end of table
  else loop = 0;                    		//reinit table index
  return;											//return from interrupt
}

void main()
{
  comm_intr();                  				//init DSK, codec, McBSP
  while(1);                      			//infinite loop
}
 
