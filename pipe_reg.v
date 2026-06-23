module pipe_reg #(
    parameter WIDTH = 32
) (
    input wire clk,
    input wire rst_n,
    input wire stall,
    input wire flush,
    input wire [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout
);

// Pipeline register logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset: clear output when reset is active
        dout <= 'd0;
    end
    else if (flush) begin
        // Flush: clear the pipeline register
        dout <= 'd0;
    end
    else if (!stall) begin
        // Normal operation: transfer input to output on clock edge
        dout <= din;
    end
    // else: stall is active, hold current value (no change)
end

endmodule
