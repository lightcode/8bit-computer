module machine;

  reg reset = 0;


  // ==========================
  // System clock
  // ==========================

  wire clk;
  wire nclk;
  reg enable_clk = 0;
  clock m_sys_clk (
    .enable(enable_clk),
    .clk(nclk),
    .clk_inv(clk)
  );


  // ==========================
  // CPU
  // ==========================

  cpu m_cpu (
    .clk(clk),
    .nclk(nclk),
    .reset(reset)
  );


  // ==========================
  // Tests
  // ==========================

  initial begin
    # 10 reset = 1;
    # 10 reset = 0;
    # 10 enable_clk = 1;
    # 20000 $display("Kill to prevent looping."); $stop;
  end

endmodule
