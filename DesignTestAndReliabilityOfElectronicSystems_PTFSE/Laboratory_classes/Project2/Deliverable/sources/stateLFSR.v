`timescale 1us / 1ps

///////////////////////////////////////////////////////////
//  Authors: Diogo Luís (96922), Duarte Marques (96523)
//  Module Name: stateLFSR
//  Description: Fibonacci LFSR (26 bits) for scan_in
///////////////////////////////////////////////////////////

module stateLFSR(clock, reset_internal, control_state, y0);
    input clock, reset_internal, control_state;
    output wire y0;
    localparam [25:0] init_val= 26'b10000000001010010001000101;
    reg[25:0] y;
    
    always @(posedge clock)
    begin
        if (reset_internal == 1'b1)
            y <= init_val;
        else if (control_state == 1'b1)
            y <= {y[6]^y[2]^y[1]^y[0], y[25:1]};
    end
   
    assign y0 = y[1];
endmodule