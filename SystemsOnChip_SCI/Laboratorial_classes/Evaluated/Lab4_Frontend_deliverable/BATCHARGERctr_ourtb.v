`timescale 1ns / 1ps

module BATCHARGERctr_ourtb;

   wire  cc; // output to analog block: constant current mode with ich current
   wire  tc; // output to analog block: trickle mode with 0.1 x ich current
   wire  cv; // output to analog block: constant voltage mode vpreset voltage
   wire  imonen; // enables current monitor
   wire  vmonen; // enables voltage monitor
   wire  tmonen; // enables temperature monitor				
   reg [7:0] vbat; // 8 bits data from adc with battery voltage; vbat = adc(vref=0.5V, battery_voltage /10)
   reg [7:0] ibat; // 8 bits data from adc with battery current; ibat = adc(vref=0.5V, battery_current * Rsens);
                   // Rsens = 1/C ; C=nominal capacity of battery; vadc(Ibat=0.5C)=0.5V
   reg [7:0] tbat; // 8 bits data from adc with battery temperature; vadc = Temp/330 + 20/165 ; tbat = adc(vref=0,5, vadc)
   reg [7:0] vcutoff; // constant from OTP: voltage threshold for exiting trickle mode
   reg [7:0] vpreset; // constant from OTP: voltage for constant voltage mode
   reg [7:0] tempmin; // constant from OTP: minimum temperature
   reg [7:0] tempmax; // constant from OTP: maximum temperature
   reg [7:0] tmax; // constant from OTP: maximum charge time
   reg [7:0] iend; // charge current to be used as "end charging" end criteria
   reg 	     clk; // state machine clock
   reg       en;
   reg 	     rstz; // system reset
   reg 	     vtok; // singals that voltage and temperature values are valid
   wire      dvdd; // digital supply
   wire      dgnd; // digital ground
   wire      se;
   wire      si;
   wire      so;

   parameter start=0, cc_mode=1, tc_mode=2, cv_mode=3;
   
BATCHARGERctr uut(   
		     .cc(cc), 
		     .tc(tc), 
		     .cv(cv),
		     .vtok(vtok),
		     .imonen(imonen), 
		     .vmonen(vmonen), 
		     .tmonen(tmonen), 
		     .vbat(vbat), 
		     .ibat(ibat), 
		     .tbat(tbat), 
		     .vcutoff(vcutoff), 
		     .vpreset(vpreset), 
		     .tempmin(tempmin), 
		     .tempmax(tempmax), 
		     .tmax(tmax), 
		     .iend(iend), 
		     .clk(clk), 
		     .rstz(rstz),
		     .en(en),
                     .dvdd(dvdd),
                     .dgnd(dgnd)	     
		     );

   initial 
     begin
        clk=0;
	vtok = 0;
        rstz = 0; // active 0 reset at the begining

	vbat[7:0] = 8'b11100101 ; // Vbat=4.5V -> after resistor divider: 0.3V -> adc with Vref=0.5V:  vabt=8'b10011001 
	ibat[7:0] = 8'b01100110 ; // 8 bits data from adc with battery current: 0.2*C
	tbat[7:0] = 8'b01100100 ; // 8 bits data from adc with battery temperature: 25ºC -> 0.2V -> adc with Vref=0.5V:  tbat=8'b01100100
	vcutoff[7:0] = 8'b10100011; // constant from OTP: voltage threshold for exiting trickle mode; Vcutoff=3.2V 
	vpreset[7:0] = 8'b11000111; // constant from OTP: voltage for constant voltage mode; Vpreset=3.9V
	tempmin[7:0] = 8'b00101110; // constant from OTP: minimum temperature: -10ºC
	tempmax[7:0] = 8'b10001011; // constant from OTP: maximum temperature: 50ºC
	tmax[7:0] = 8'b00001000; // constant from OTP: maximum charge time (units of 255 clock periods): 255*8 = 2040 clock periods 
	iend[7:0] = 8'b00110011; // charge current div by 10 to be used as charging end criteria: 0.1C 
	
	#12 rstz = 1;   // reset end
        vtok = 1; // voltage and temperature values are valid

	/* Changes in mode: start->cc->cv->start->tc->cc->cv->start->cc-cv*/
	
	#100  vbat[7:0] = 8'b11000001 ; // Vbat=3.8V to exit start

	$display ( "Vbat > Vcutoff, Vbat < 4.2V, waiting cc mode");
	wait(cc);
	$display ( "cc mode ok");

	#100  vbat[7:0] = 8'b11001000 ; // Vbat=Vpreset+1 to change to cv_mode
	
	$display ( "Vbat > Vpreset, waiting cv mode");
	wait(cv);
	$display ( "cv mode ok");

	#100 tbat[7:0] = 8'b10010010 ; // tbat=55º to exit cv_mode
	vbat[7:0] = 8'b10011001 ; // Vbat<Vcutoff to enter tc_mode
	#100 tbat[7:0] = 8'b01001101; // tbat=10º to exit start mode
	
	$display ( "temperature increased (55º), voltage reduced (Vbat<Vcutoff), temperature increased (10º), waiting tc mode");
	wait(tc);
	$display ( "tc mode ok");

	#100  vbat[7:0] = 8'b11001000 ; // Vbat=Vpreset +1 to enter cc_mode and pass to cv_mode
	
	$display ( "voltage increased (Vbat > Vcutoff), waiting cc mode");
	wait(cc);
	$display ( "cc mode ok");

	$display ( "Vbat > Vpreset, waiting cv mode");
	wait(cv);
	$display ( "cv mode ok");

	#100  vbat[7:0] = 8'b11000110 ; // Vbat=preset -1 to return to cc_mode

	$display ( "voltage reduced, Vbat < Vpreset, waiting cc mode");
	wait(cc);
	$display ( "cc mode ok");

	#100  vbat[7:0] = 8'b11001000 ; // Vbat=preset +1 to exit cc_mode

	$display ( "Vbat > Vpreset, waiting cv mode");
	wait(cv);
	$display ( "cv mode ok");

	#100 ibat[7:0] = 8'b00110010 ; // ibat<0.1C to exit cv_mode
	#30 if (cv==1) begin
	   $display( "Error: no exit of cv by minimum current");
	   $finish();
	end
	else $display( "exit cv by minimum ccurrent ok");
	
	#1000
 	
	$finish;
     end
   
   always
     #5 clk = ~clk; 
   
endmodule
