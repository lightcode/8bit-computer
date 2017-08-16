module tristate_buffer(input_x, enable, output_x);

  parameter N = 8;

  input [N-1:0] input_x;
  input enable;
  output [N-1:0] output_x;

  assign output_x = enable ? input_x : 'bz;

endmodule
