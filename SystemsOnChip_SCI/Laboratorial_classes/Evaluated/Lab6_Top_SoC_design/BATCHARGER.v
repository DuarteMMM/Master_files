module BATCHARGER ( iforcedbat, vsensbat, vin, vbattemp, en, sel, dvdd, dgnd, pgnd);
   output iforcedbat;
   input vsensbat, vin, vbattemp, en;
   inout dvdd, dgnd, pgnd;
   input [3:0] sel; 
  
   wire pu, pd, smt, en, e2, e4, sr;
   wire [3:0]  sel_core;

   assign pu = 1'b0;
   assign pd = 1'b0;
   assign smt = 1'b0;
   assign en = 1'b1;
   assign e2 = 1'b0;
   assign e4 = 1'b0;
   assign sr = 1'b1;
   
   BATCHARGERcore   BATCH (.en(en_core), .iforcedbat(iforcedbat), .vsensbat(vsensbat) , .vin(vin), .vbattemp(vbattemp), .sel(sel_core), .dvdd(dvdd), .dgnd(dgnd), .pgnd(pgnd));

   GNDKHB gndinst1 (.GND(dgnd)); 
   VCCKHB vccinst1 (.VCC(dvdd));
   RCUT12HB instrc();

   GNDACUTHB gndinst2 (.GNDANA(pgnd));
   ULSCI0CUTHB analogpad3 (.O(vbattemp));
   ULSCI0CUTHB analogpad2 (.O(vsensbat));
   ULSCI0CUTHB analogpad1 (.O(iforcedbat));
   VCC12ACUTHB vccinst2 (.VCC12ANA(vin));

   LCUT12HB instlc();
   XMHB inst5 (.O(sel_core[3]), .I(sel[3]), .PU(pu), .PD(pd), .SMT(smt)); 
   VCC3IOHB vcc3io ;
   GND3IOHB gndio ;
   
   XMHB inst1 (.O(en_core), .I(en), .PU(pu), .PD(pd), .SMT(smt));
   XMHB inst2 (.O(sel_core[0]), .I(sel[0]), .PU(pu), .PD(pd), .SMT(smt));	     		     
   XMHB inst3 (.O(sel_core[1]), .I(sel[1]), .PU(pu), .PD(pd), .SMT(smt));
   XMHB inst4 (.O(sel_core[2]), .I(sel[2]), .PU(pu), .PD(pd), .SMT(smt)); 
   
endmodule
