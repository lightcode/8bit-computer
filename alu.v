module alu(
  input wire cin,
  output wire cout,
  input wire [N-1:0] in_a,
  input wire [N-1:0] in_b,
  output wire [N-1:0] sum
);

  parameter N = 8;

  assign {cout, sum} = in_a + in_b + cin;

endmodule
