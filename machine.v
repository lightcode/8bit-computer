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

  wire [7:0] addr_bus;
  wire [7:0] bus;
  wire c_mi;
  wire c_ri;
  wire c_ro;
  cpu m_cpu (
    .clk(clk),
    .nclk(nclk),
    .reset(reset),
    .addr_bus(addr_bus),
    .bus(bus),
    .c_mi(c_mi),
    .c_ri(c_ri),
    .c_ro(c_ro)
  );


  // ==========================
  // RAM
  // ==========================

  wire [7:0] ram_out;
  memory m_ram (
    .clk(clk),
    .addr(addr_bus),
    .val(bus),
    .get(c_mi),
    .set(c_ri),
    .out(ram_out)
  );
  tristate_buffer m_ram_buf (
    .in(ram_out),
    .enable(c_ro),
    .out(bus)
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
