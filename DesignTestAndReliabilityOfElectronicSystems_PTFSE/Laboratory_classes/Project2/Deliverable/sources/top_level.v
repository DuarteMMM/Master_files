`timescale 1us / 1ps

module top_level(clock, bist_start, reset, pi, bist_end, pass_nfail, po);
    input clock, bist_start, reset;
    input [3:0] pi;
    output bist_end; // Defined as reg in controller.v
    output reg pass_nfail;
    output [3:0] po; // Defined as reg in circuito06.v
   
    wire scan_en, scan_in, scan_out, bist_running, new_seq, reset_internal;
    wire[3:0] circuito06_input, vector;
    wire[8:0] output_misr;

    localparam[8:0] signature = 9'h08c; // Signature for comparator
    
    // Instantiate each block
    controller controller(.clock(clock), .reset(reset), .bist_start(bist_start), .new_seq(new_seq), .out(scan_en), .bist_end(bist_end), .bist_running(bist_running));
    
    stateLFSR stateLFSR(.clock(clock), .reset_internal(reset_internal), .control_state(bist_running), .y0(scan_in));
    
    inputLFSR inputLFSR(.clock(clock), .reset_internal(reset_internal), .control_input(bist_running), .vector(vector));
    
    misr misr(.clock(clock), .reset_internal(reset_internal), .scan_out(scan_out), .grant_o(po), .control_misr(bist_running), .output_misr(output_misr));

    circuito06 circuito06(.clock(clock), .reset(reset_internal), .request1(circuito06_input[0]), .request2(circuito06_input[1]), 
                          .request3(circuito06_input[2]), .request4(circuito06_input[3]), .grant_o(po), 
                          .scan_en(scan_en), .scan_in(scan_in), .scan_out(scan_out));
    
    // MUX - select input of circuito06 (primary inputs or output from inputLFSR)
    assign circuito06_input = (bist_running? vector : pi);

    // Reset for LFSRs, MISR and circuito06 - with external reset or start of BIST session
    assign reset_internal = new_seq || reset;
        
    // Comparator
    always @(posedge clock) begin
        if (reset_internal == 1'b1)
            pass_nfail <= 1'b0;
        else if (bist_end == 1'b1 && output_misr == signature)
            pass_nfail <= 1'b1;
    end
	
endmodule