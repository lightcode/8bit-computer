module register(
  input wire [N-1:0] in,
  input wire clk,
  input wire reset,
  input wire enable,
  output reg [N-1:0] out
);

  parameter N = 8;

  always @(posedge clk) begin
    if (enable)
      out <= in;
  end

endmodule
