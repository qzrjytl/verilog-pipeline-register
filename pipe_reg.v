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

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dout <= 'd0;
    end
    else if (flush) begin
        dout <= 'd0;
    end
    else if (!stall) begin
        dout <= din;
    end
end

endmodule
