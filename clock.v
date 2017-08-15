module clock(clk);

  output clk;

  reg clk = 0;
  always #2 clk = !clk;

endmodule
