`timescale 1us / 1ps

///////////////////////////////////////////////////////////
//  Authors: Diogo Luís (96922), Duarte Marques (96523)
//  Module Name: misr
//  Description: Fibonacci MISR with 9 FFs
///////////////////////////////////////////////////////////

module misr(clock, reset_internal, scan_out, grant_o, control_misr, output_misr);
    input clock, reset_internal, scan_out, control_misr;
    input [3:0] grant_o;
    output [8:0] output_misr;
    localparam [9:0] init_val = 10'b0000000001;
    reg[9:0] z;
            
    always @(posedge clock) begin
        if (reset_internal == 1'b1)
            z <= init_val;
        else if (control_misr == 1'b1)
            z <= {scan_out^z[5]^z[0], grant_o[0]^z[9], grant_o[1]^z[8], grant_o[2]^z[7], grant_o[3]^z[6], z[5:1]};
    end

    assign output_misr = z[8:0];
endmodule