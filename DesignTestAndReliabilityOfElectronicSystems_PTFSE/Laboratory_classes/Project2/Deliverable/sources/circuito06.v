`timescale 1ns / 1ps

module circuito06 (clock, reset, request1, request2, request3, request4, grant_o);

   input clock; 
   input reset; 
   input request1; 
   input request2; 
   input request3; 
   input request4; 
   output[3:0] grant_o; 

   reg[3:0] grant_o;

   reg[1:0] stato, stato_nxt; 
   reg[2:0] coda0, coda0_nxt; 
   reg[2:0] coda1, coda1_nxt; 
   reg[2:0] coda2, coda2_nxt; 
   reg[2:0] coda3, coda3_nxt; 
   reg ru1, ru1_nxt; 
   reg ru2, ru2_nxt; 
   reg ru3, ru3_nxt; 
   reg ru4, ru4_nxt; 
   reg fu1, fu1_nxt; 
   reg fu2, fu2_nxt; 
   reg fu3, fu3_nxt; 
   reg fu4, fu4_nxt; 
   reg[3:0] grant, grant_nxt; 

   localparam [1:0] INIT = 0; 
   localparam [1:0] ANALISI_REQ = 1; 
   localparam [1:0] ASSIGN = 2; 
   localparam [2:0] U1 = 3'b100; 
   localparam [2:0] U2 = 3'b010; 
   localparam [2:0] U3 = 3'b001; 
   localparam [2:0] U4 = 3'b111; 

   always @(*)
      grant_o <= grant;

   always @(posedge clock)
   begin
      if (reset == 1'b1)
      begin
         stato <= INIT;
         ru1 <= 1'b0;
         ru2 <= 1'b0;
         ru3 <= 1'b0;
         ru4 <= 1'b0;
         fu1 <= 1'b0;
         fu2 <= 1'b0;
         fu3 <= 1'b0;
         fu4 <= 1'b0;
         coda0 <= 3'b000;
         coda1 <= 3'b000;
         coda2 <= 3'b000;
         coda3 <= 3'b000;
         grant <= 4'b0000;
      end 
      else
      begin
         stato <= stato_nxt;
         ru1 <= ru1_nxt;
         ru2 <= ru2_nxt;
         ru3 <= ru3_nxt;
         ru4 <= ru4_nxt;
         fu1 <= fu1_nxt;
         fu2 <= fu2_nxt;
         fu3 <= fu3_nxt;
         fu4 <= fu4_nxt;
         coda0 <= coda0_nxt;
         coda1 <= coda1_nxt;
         coda2 <= coda2_nxt;
         coda3 <= coda3_nxt;
         grant <= grant_nxt;
      end
   end

   always @(*)
   begin
      ru1_nxt = ru1;
      ru2_nxt = ru2;
      ru3_nxt = ru3;
      ru4_nxt = ru4;
      fu1_nxt = fu1;
      fu2_nxt = fu2;
      fu3_nxt = fu3;
      fu4_nxt = fu4;
      coda0_nxt = coda0;
      coda1_nxt = coda1;
      coda2_nxt = coda2;
      coda3_nxt = coda3;
      grant_nxt = grant;
      case (stato)
         INIT : begin
               ru1_nxt = request1; 
               ru2_nxt = request2; 
               ru3_nxt = request3; 
               ru4_nxt = request4; 
               stato_nxt = ANALISI_REQ; 
            end
         ANALISI_REQ : begin
               if (ru1 == 1'b1)
               begin
                  if (fu1 == 1'b0)
                  begin
                     coda3_nxt = coda2; 
                     coda2_nxt = coda1; 
                     coda1_nxt = coda0; 
                     coda0_nxt = U1; 
                  end 
               end
               else if (ru2 == 1'b1)
               begin
                  if (fu2 == 1'b0)
                  begin
                     coda3_nxt = coda2; 
                     coda2_nxt = coda1; 
                     coda1_nxt = coda0; 
                     coda0_nxt = U2; 
                  end 
               end
               else if (ru3 == 1'b1)
               begin
                  if (fu3 == 1'b0)
                  begin
                     coda3_nxt = coda2; 
                     coda2_nxt = coda1; 
                     coda1_nxt = coda0; 
                     coda0_nxt = U3; 
                  end 
               end
               else if (ru4 == 1'b1)
               begin
                  if (fu4 == 1'b0)
                  begin
                     coda3_nxt = coda2; 
                     coda2_nxt = coda1; 
                     coda1_nxt = coda0; 
                     coda0_nxt = U4; 
                  end 
               end 
               fu1_nxt = ru1; 
               fu2_nxt = ru2; 
               fu3_nxt = ru3; 
               fu4_nxt = ru4; 
               stato_nxt = ASSIGN; 
            end
         ASSIGN : begin
               if ((fu1 | fu2 | fu3 | fu4) == 1'b1)
               begin
                  case (coda0)
                     U1 : grant_nxt = 4'b1000; 
                     U2 : grant_nxt = 4'b0100; 
                     U3 : grant_nxt = 4'b0010; 
                     U4 : grant_nxt = 4'b0001; 
                     default : grant_nxt = 4'b0000; 
                  endcase 
                  coda0_nxt = coda1; 
                  coda1_nxt = coda2; 
                  coda2_nxt = coda3; 
                  coda3_nxt = 3'b000; 
               end 
               ru1_nxt = request1; 
               ru2_nxt = request2; 
               ru3_nxt = request3; 
               ru4_nxt = request4; 
               stato_nxt = ANALISI_REQ; 
            end
          default : begin
               stato_nxt = INIT;
            end			
      endcase 
   end 
endmodule
