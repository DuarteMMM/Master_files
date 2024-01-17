`timescale 1us / 1ps

///////////////////////////////////////////////////////////
//  Authors: Diogo Luís (96922), Duarte Marques (96523)
//  Module Name: inputLFSR
//  Description: Fibonacci LFSR (5 bits) for inputs
///////////////////////////////////////////////////////////

module inputLFSR(clock, reset_internal, control_input, vector);
    input clock, reset_internal, control_input;
    output [3:0] vector;
    localparam [4:0] init_val= 5'b10010;
    reg[4:0] x;
    
    always @(posedge clock)
    begin
        if (reset_internal == 1'b1)
            x <= init_val;
        else if (control_input == 1'b1)
            x <= {x[3]^x[0], x[4:1]};
    end
   
    assign vector = x[3:0];
endmodule