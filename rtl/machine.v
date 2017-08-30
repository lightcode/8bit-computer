module machine(
  input wire clk,
  input wire reset
);

  // ==========================
  // CPU
  // ==========================

  wire [7:0] addr_bus;
  wire [7:0] bus;
  wire c_ri;
  wire c_ro;
  wire mem_clk;
  cpu m_cpu (
    .clk(clk),
    .reset(reset),
    .addr_bus(addr_bus),
    .bus(bus),
    .mem_clk(mem_clk),
    .c_ri(c_ri),
    .c_ro(c_ro)
  );


  // ==========================
  // RAM
  // ==========================

  ram m_ram (
    .clk(mem_clk),
    .addr(addr_bus),
    .data(bus),
    .we(c_ri),
    .oe(c_ro)
  );

endmodule
