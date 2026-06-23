`timescale 1ns / 1ps

module pipe_reg_tb;

parameter WIDTH = 8;
parameter CLK_PERIOD = 10;

reg clk;
reg rst_n;
reg stall;
reg flush;
reg [WIDTH-1:0] din;
wire [WIDTH-1:0] dout;

pipe_reg #(.WIDTH(WIDTH)) uut (
    .clk(clk),
    .rst_n(rst_n),
    .stall(stall),
    .flush(flush),
    .din(din),
    .dout(dout)
);

initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
    rst_n = 0;
    stall = 0;
    flush = 0;
    din = 8'h00;
    
    // Test 1: 
    $display("\n========== Test 1: Reset Verification ==========");
    #(CLK_PERIOD * 2);
    rst_n = 1;
    #CLK_PERIOD;
    $display("After reset, dout = 8'h%02h (expected: 8'h00)", dout);
    
    // Test 2:
    $display("\n========== Test 2: Normal Data Transfer ==========");
    din = 8'hAA;
    #CLK_PERIOD;
    $display("Input: 8'hAA, Output: 8'h%02h (expected: 8'h00 - delayed 1 cycle)", dout);
    #CLK_PERIOD;
    $display("Output: 8'h%02h (expected: 8'hAA)", dout);
    
    // Test 3: 
    $display("\n========== Test 3: Stall Verification ==========");
    din = 8'hBB;
    stall = 1;
    #CLK_PERIOD;
    $display("stall=1, new input: 8'hBB, Output: 8'h%02h (expected: 8'hAA - held)", dout);
    #CLK_PERIOD;
    $display("stall still 1, Output: 8'h%02h (expected: 8'hAA - held)", dout);
    
    // Test 4: 
    $display("\n========== Test 4: Release Stall ==========");
    stall = 0;
    #CLK_PERIOD;
    $display("stall=0, Output: 8'h%02h (expected: 8'hBB)", dout);
    
    // Test 5: 
    $display("\n========== Test 5: Flush Verification ==========");
    din = 8'hCC;
    flush = 1;
    #CLK_PERIOD;
    $display("flush=1, Output: 8'h%02h (expected: 8'h00 - flushed)", dout);
    
    // Test 6:
    $display("\n========== Test 6: Normal Operation After Flush ==========");
    flush = 0;
    din = 8'hDD;
    #CLK_PERIOD;
    $display("flush=0, new input: 8'hDD, Output: 8'h%02h (expected: 8'h00 - delayed)", dout);
    #CLK_PERIOD;
    $display("Output: 8'h%02h (expected: 8'hDD)", dout);
    
    // Test 7:
    $display("\n========== Test 7: Stall and Flush Both Active ==========");
    din = 8'hEE;
    stall = 1;
    flush = 1;
    #CLK_PERIOD;
    $display("stall=1, flush=1, Output: 8'h%02h (expected: 8'h00 - flushed)", dout);
    
    // Test 8:
    $display("\n========== Test 8: Reset During Operation ==========");
    stall = 0;
    flush = 0;
    din = 8'hFF;
    #CLK_PERIOD;
    rst_n = 0;
    #CLK_PERIOD;
    $display("rst_n=0, Output: 8'h%02h (expected: 8'h00 - reset)", dout);
    
    // Test 9: 
    $display("\n========== Test 9: Recovery After Reset ==========");
    rst_n = 1;
    din = 8'h99;
    #CLK_PERIOD;
    $display("After rst_n=1, new input: 8'h99, Output: 8'h%02h (expected: 8'h00)", dout);
    #CLK_PERIOD;
    $display("Output: 8'h%02h (expected: 8'h99)", dout);
    
    $display("\n========== Simulation Complete ==========\n");
    #(CLK_PERIOD * 2);
    $finish;
end

initial begin
    $dumpfile("pipe_reg_tb.vcd");
    $dumpvars(0, pipe_reg_tb);
end

endmodule
