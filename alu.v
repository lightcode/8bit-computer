module alu(cin, cout, in_a, in_b, sum);

  parameter N = 8;

  input cin;
  input [N-1:0] in_a;
  input [N-1:0] in_b;
  output [N-1:0] sum;
  output cout;

  assign {cout, sum} = in_a + in_b + cin;

endmodule
