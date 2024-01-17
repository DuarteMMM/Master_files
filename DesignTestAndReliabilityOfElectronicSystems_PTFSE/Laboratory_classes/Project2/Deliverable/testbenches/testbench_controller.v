`timescale 1us / 1ps

module testbench_controller;
    // Inputs and outputs
    reg clock, bist_start, reset;
    reg[3:0] pi;
    wire bist_end, pass_nfail;
    wire[3:0] po;
    
    // Instantiate module
    top_level top_level(.clock(clock), .bist_start(bist_start), .reset(reset), .pi(pi), .bist_end(bist_end), .pass_nfail(pass_nfail), .po(po));
    
    initial begin
	// Initialization
        clock = 0;
        reset = 1;
        pi = 4'b1000; // Works with any value
        bist_start = 0;
        #200 reset = 0;

        $display("\n--- Testing controller mode ---\n");

        // Rising edge in START after reset to generate full sequence
        $display("Starting full sequence by rising edge in START after reset...");
        #200 bist_start = 1;
        #100 bist_start = 0;
        #136000
        if (bist_end == 1)
            $display("Full sequence generated, BIST_END=%b\n", bist_end);
        else begin
            $display("Error - full sequence not generated, exiting\n");
            $finish;
        end

        // Start new full sequence by rising edge of START (no reset)
        $display("Starting another full sequence by rising edge in START (no reset)...");
        #100 bist_start = 1;
        #400 bist_start = 0;
            
        // Rising edge of START while the sequence is running
        $display("Rising edge in START while sequence is running...");
        #500 bist_start = 1;
        #50 bist_start = 0;
        #136000
        if (bist_end == 1)
            $display("Another full sequence generated, BIST_END=%b\n", bist_end);
        else begin
            $display("Error - full sequence not generated, exiting\n");
            $finish;
        end
        
        // Interrupt full sequence with RESET, while START is at 1
        $display("Starting new sequence...");
        #100  bist_start = 1;
        $display("Rising edge in RESET mid-sequence...");
        #500 reset = 1;
        #100 reset = 0;
        #10
        if (bist_end == 0)
            $display("Sequence stopped by reset, BIST_END=%b\n", bist_end);
        else begin
            $display("Error - full sequence was not stopped, exiting\n");
            $finish;
        end
        
        // Full sequence after reset and with START permanently at 1
        $display("Starting new full sequence with START permanently at 1...");
        #100 bist_start = 0;
        #50 bist_start = 1;
        #136000
        if (bist_end == 1)
            $display("Full sequence generated, BIST_END=%b\n", bist_end);
        else begin
            $display("Error - full sequence not generated, exiting\n");
            $finish;
        end
        
        // Rising edge in START while RESET is active
        $display("Starting new sequence...");
        #50 bist_start = 0;
        #50 bist_start = 1;
        #50 bist_start = 0;
        $display("Rising edge in RESET...");
        #100 reset = 1;
        #500 bist_start = 1;
        $display("Rising edge in START...");
        #100
        if (bist_end == 0)
            $display("Reset still active, BIST_END=%b", bist_end);
        else begin
            $display("Error - New sequence started while reset was active, exiting\n");
            $finish;
        end
        $display("Rising edge in START with RESET at zero...");
        #50 reset = 0;
        #50 bist_start = 0;
        #50 bist_start = 1;
        #50 bist_start = 0;
        #136000
        if (bist_end == 1)
            $display("Another full sequence generated, BIST_END=%b\n", bist_end);
        else begin
            $display("Error - full sequence not generated, exiting\n");
            $finish;
        end

        $display("--- Finished! ---\n");
        $finish;
    end    

    always #5 clock = ~clock; // 10000ns period, 100kHz

endmodule