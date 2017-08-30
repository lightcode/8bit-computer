module alu(
  input wire cin,
  input wire sub,
  output wire cout,
  input wire [N-1:0] in_a,
  input wire [N-1:0] in_b,
  output wire [N-1:0] out,
  output wire eq_zero
);

  parameter N = 8;

  assign {cout, out} = sub ? in_a - in_b : in_a + in_b + cin;
  assign eq_zero = (in_a == 0) ? 1 : 0;

endmodule
