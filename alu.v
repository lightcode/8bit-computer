module alu(
  input wire cin,
  input wire sub,
  output wire cout,
  input wire [N-1:0] in_a,
  input wire [N-1:0] in_b,
  output wire [N-1:0] out
);

  parameter N = 8;

  assign {cout, out} = sub ? in_a - in_b : in_a + in_b + cin;

endmodule
