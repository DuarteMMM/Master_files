`timescale 1us / 1ps

///////////////////////////////////////////////////////////
//  Authors: Diogo Luís (96922), Duarte Marques (96523)
//  Module Name: controller
//  Description: Controller
///////////////////////////////////////////////////////////

module controller(clock, reset, bist_start, new_seq, out, bist_end, bist_running);
    input clock, reset, bist_start;
    output reg bist_end;
    output wire new_seq, out, bist_running;
    reg new_seq_reg, out_reg, bist_running_reg;

    reg Q1, Q2, per_rst, seq_rst, seq_en; // Auxiliary registers

    reg [1:0] state, next_state; // State flip-flops
    reg [4:0] per_count; // Counter for number of periods
    reg [8:0] seq_count; // Counter for number of sequences

    localparam [1:0] IDLE=0, ON=1, OFF=2, END=3; // State coding
    localparam [4:0] N=26; // Number of periods
    localparam [8:0] M=500; // Number of sequences
	
    // State updating with synchronous reset
    always @(posedge clock) begin
        if (reset == 1'b1)
            state <= IDLE;
        else
            state <= next_state;
    end
        
    // Next state and output calculations
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                    per_rst = 1'b1;
                    seq_rst = 1'b1;
                    seq_en = 1'b0;
                    out_reg = 0;
                    bist_end = 0;
                    bist_running_reg = 0;
                    if (new_seq == 1'b1)
                        next_state = ON;
                  end
            ON:   begin
                    per_rst = 1'b0;
                    seq_rst = 1'b0;
                    seq_en = 1'b0;
                    out_reg = 1;
                    bist_end = 0;
                    bist_running_reg = 1;
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
                    out_reg = 0;
                    bist_end = 0;
                    bist_running_reg = 1;
                    next_state = ON;
                  end
            END:  begin
                    per_rst = 1'b1;
                    seq_rst = 1'b1;
                    seq_en = 1'b0;
                    out_reg = 0;
                    bist_end = 1;
                    bist_running_reg = 0;
                    if (new_seq == 1'b1)
                        next_state = ON;
                  end
            default: next_state = IDLE;
        endcase
    end

    // Detect rising edge in START (new_seq lasts for 1 clock period)
    always @(posedge clock) begin
        Q2 <= Q1;
        Q1 <= bist_start;
        if (bist_running_reg == 0 && reset == 0)
            new_seq_reg <= Q1 & (~Q2);
        else
            new_seq_reg <= 1'b0;
    end

    // Update counter for number of periods
    always @(posedge clock) begin
        if (per_rst == 1)
            per_count <= 5'b00000;
        else if (bist_running_reg == 1)
            per_count <= per_count + 5'b00001;
    end

    // Update counter for number of sequences
    always @(posedge clock) begin
        if (seq_rst == 1)
            seq_count <= 9'b000000000;
        else if (seq_en == 1)
            seq_count <= seq_count + 9'b000000001;
    end

    assign new_seq = new_seq_reg;
    assign out = out_reg;
    assign bist_running = bist_running_reg;

endmodule