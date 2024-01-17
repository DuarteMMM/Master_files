`timescale 10ns / 1ps

///////////////////////////////////////////////////////////
//  Authors: Diogo Luís (96922), Duarte Marques (96523)
//  Module Name: controller_fsm
//  Description: Controller
///////////////////////////////////////////////////////////

module controller_fsm(clk, reset, start, out, bist_end, running);
    input clk, reset, start;
    output reg out, bist_end, running;

    reg new_seq, prev_start, per_rst, seq_rst, seq_en; // Auxiliary registers

    reg [1:0] state, next_state; // State flip-flops
    reg [2:0] per_count; // Counter for number of periods
    reg [3:0] seq_count; // Counter for number of sequences

    localparam [1:0] IDLE=0, ON=1, OFF=2, END=3; // State coding
    localparam [2:0] N=6; // Number of periods
    localparam [3:0] M=11; // Number of sequences

    // State updating with synchronous reset
    always @(posedge clk)
    begin
        if (reset == 1'b1)
         state <= IDLE;
        else
         state <= next_state;
    end

    // Next state and output calculations
    always @(*)
    begin
        next_state = state;
        case (state)
            IDLE: begin
                    per_rst = 1'b1;
                    seq_rst = 1'b1;
                    seq_en = 1'b0;
                    out = 0;
                    bist_end = 0;
                    running = 0;
                    if (new_seq == 1'b1)
                        next_state = ON;
                  end
            ON:   begin
                    per_rst = 1'b0;
                    seq_rst = 1'b0;
                    seq_en = 1'b0;
                    out = 1;
                    bist_end = 0;
                    running = 1;
                    if (per_count == N-1) begin
                        if (seq_count == M)
                            next_state = END;
                        else
                            next_state = OFF;
                    end
                  end
            OFF:  begin
                    per_rst = 1'b1;
                    seq_rst = 1'b0;
                    seq_en = 1'b1;
                    out = 0;
                    bist_end = 0;
                    running = 1;
                    next_state = ON;
                  end
            END:  begin
                    per_rst = 1'b1;
                    seq_rst = 1'b1;
                    seq_en = 1'b0;
                    out = 0;
                    bist_end = 1;
                    running = 0;
                    if (new_seq == 1'b1)
                        next_state = ON;
                  end
            default: next_state = IDLE;
        endcase
    end

    // Detect rising edge in START
    always @(*)
    begin
        if (running == 0 && reset == 0)
            new_seq = start & (~prev_start);
        else
            new_seq = 1'b0;
        prev_start = start;
    end

    // Update counter for number of periods
    always @(posedge clk)
    begin
        if (per_rst == 1)
            per_count <= 3'b000;
        else if (running == 1)
            per_count <= per_count + 3'b001;
    end

    // Update counter for number of sequences
    always @(posedge clk)
    begin
        if (seq_rst == 1)
            seq_count <= 4'b0000;
        else if (seq_en == 1)
            seq_count <= seq_count + 4'b0001;
    end

endmodule