`timescale 1us / 1ps

module testbench_bist;
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
        bist_start = 0;
        pi = 4'b1000; // Works with any value
        #200 reset = 0;
        #200 bist_start = 1; // Start BIST session
        
        $display("\n--- Testing BIST mode ---\n");

        // Complete full BIST sequence
        #136000
        $display("Bist_end: %b\nMISR output: %b (%X)\nPass_nfail: %b", bist_end, testbench_bist.top_level.output_misr, testbench_bist.top_level.output_misr, pass_nfail);
        $display("\n--- Finished! ---\n");
        $finish;
    end

    always #5 clock = ~clock; // 10000ns period, 100kHz
    
endmodule