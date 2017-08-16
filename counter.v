module counter(clk, in, sel_in, reset, out);

  parameter N = 8;

  input wire clk;
  input wire [N-1:0] in;
  input wire sel_in;
  input wire reset;
  output reg [N-1:0] out;

  initial
    out = 0;

  always @(posedge clk) begin
    if (sel_in)
      out <= in;
    else
      out <= out + 1;
  end

  always @(posedge reset) begin
    out <= 0;
  end

endmodule
