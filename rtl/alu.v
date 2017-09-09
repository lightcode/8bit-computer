module alu(
  input wire cin,
  input wire [2:0] mode,
  output wire cout,
  input wire [N-1:0] in_a,
  input wire [N-1:0] in_b,
  output wire [N-1:0] out,
  output wire eq_zero,
  output wire equal
);

  `include "rtl/parameters.v"

  parameter N = 8;

  assign {cout, out} = (mode == `ALU_SUB) ? in_a - in_b :
                       (mode == `ALU_ADD) ? in_a + in_b + cin :
                       (mode == `ALU_INC) ? in_a + 1 :
                       (mode == `ALU_DEC) ? in_a - 1 :
                       'bx;
  assign eq_zero = (in_a == 0);
  assign equal   = (in_a == in_b);

endmodule
