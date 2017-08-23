module tristate_buffer(
  input [N-1:0] in,
  input enable,
  output [N-1:0] out
);

  parameter N = 8;

  assign out = enable ? in : 'bz;

endmodule
