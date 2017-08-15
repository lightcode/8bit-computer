module register(in, clk, enable, reset, out);
  parameter N = 8;

  input [N-1:0] in;
  input clk, reset, enable;
  output [N-1:0] out;

  reg [N-1:0] out;
  wire in, clk, reset;

  always @(posedge clk) begin
    if (enable)
      out <= in;
  end
endmodule
