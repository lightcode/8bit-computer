module tristate_buffer(in, enable, out);

  parameter N = 8;

  input [N-1:0] in;
  input enable;
  output [N-1:0] out;

  assign out = enable ? in : 'bz;

endmodule
