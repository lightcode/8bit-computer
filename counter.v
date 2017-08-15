module counter(clk, in, sel_in, reset, out);
  parameter N = 8;

  input clk, reset, sel_in;
  input [N-1:0] in;
  output [N-1:0] out;

  reg [N-1:0] out;
  wire clk, reset;

  always @(posedge clk) begin
    if (sel_in)
      out <= in;
    else
      out <= out + 1;
  end

  always @reset
    if (reset)
      out = 0;
endmodule
