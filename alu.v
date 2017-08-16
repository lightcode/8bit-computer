module alu(cin, cout, in_a, in_b, sum);

  parameter N = 8;

  input wire cin;
  input wire [N-1:0] in_a;
  input wire [N-1:0] in_b;
  output wire [N-1:0] sum;
  output wire cout;

  assign {cout, sum} = in_a + in_b + cin;

endmodule
