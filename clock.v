module clock(clk);

  output reg clk = 0;

  always begin
    #5 clk = !clk;
  end

endmodule
