`timescale 1us / 1ps

module testbench_normal;
    
    // Declare array of 10 vectors with 4 bits each (for vectors read from file)
    reg [3:0] pattern_mem[9:0];

    // Inputs and outputs
    reg clock, bist_start, reset;
    wire[3:0] pi;
    wire bist_end, pass_nfail;
    wire[3:0] po;

    // Index array
    integer index;

    // Correspondance between circuit inputs and bits in the array      
    assign {pi[0], pi[1], pi[2], pi[3]} = pattern_mem[index];

    // Instantiate module
    top_level top_level(.clock(clock), .bist_start(bist_start), .reset(reset), .pi(pi), .bist_end(bist_end), .pass_nfail(pass_nfail), .po(po));
   
    initial begin
        // Initialization
        clock = 0;
        bist_start = 0;
        reset = 1;
        #17 reset = 0; // After posedge clk, before negedge clk
        index = 0;
        $display("\n--- Testing normal mode ---\n");

        // Read external array of vectors from circuito06.vec
        $readmemb("testbenches/circuito06.vec", pattern_mem);

        forever begin
            // Display signals in negative edge of clock and increase index
            @(negedge clock) begin
                $display( "index %0d, request1 %b, request2 %b, request3 %b, request4 %b, grant_o[0] %b, grant_o[1] %b, grant_o[2] %b, grant_o[3] %b", index, pi[0], pi[1], pi[2], pi[3], po[0], po[1], po[2], po[3]);
                index = index + 1;
            end
        end
    end
    
    always #5 clock = ~clock; // 10000ns period, 100kHz
    
    initial  begin
    // End simulation when final vector is reached
        wait(index == 10);
        $display("\n--- Finished! ---\n");
        $finish;
    end

endmodule