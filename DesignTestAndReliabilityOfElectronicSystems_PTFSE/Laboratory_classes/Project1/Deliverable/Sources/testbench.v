`timescale 10ns / 1ps

module testbench;
    reg clk, reset, start;
    wire out, bist_end, running;

    // Instantiation of the design
    controller_fsm controller(clk, reset, start, out, bist_end, running);

    initial
    begin
        clk = 0;
        reset = 1;
        #20 reset = 0;
    end

    always #5 clk = ~clk; // 10 MHz clock

    initial
    begin
        // Rising edge in START after reset to generate full sequence
        start = 0;
        #100 start = 1;
        #100 start = 0;

        // Start new full sequence by rising edge of START (no reset)
        #1000 start = 1;
        #400 start = 0;
        
        // Rising edge of START while the sequence is running
        #100 start = 1;
        #500 start = 0;

        // Interrupt full sequence with RESET, while START is at 1
        #100  start = 1;
        #200 reset = 1;
        #100 reset = 0;
        
        // Full sequence after reset and with START permanently at 1
        #100 start = 0;
        #200 start = 1;
        #900 start = 0;
        
        // Full sequence only when START 0->1 after reset returns to 0
        #50 start = 1;
        #50 start = 0;
        #150 reset = 1;
        #50 start = 1;
        #50 reset = 0;
        #100 start = 0;
        #50 start = 1;
        #100 start = 0;
        
        #900 $finish;
    end

endmodule