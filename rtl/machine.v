module machine;

  reg reset = 0;


  // ==========================
  // System clock
  // ==========================

  wire clk;
  reg enable_clk = 0;
  clock m_sys_clk (
    .enable(enable_clk),
    .clk(clk)
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


  // ==========================
  // Tests and monitoring
  // ==========================

  initial begin
    $readmemh("memory.list", m_ram.mem);
    $dumpfile("cpu.vcd");
    $dumpvars(0, m_cpu);
  end

  initial begin
    # 10 reset = 1;
    # 10 reset = 0;
    # 10 enable_clk = 1;
    $monitor(
      "[%08d] bus: %h, pc: %h, cycle: %h, state: %h, opcode: %h, a: %h, b: %h, alu: %h, mar: %h, eq_zero: %b, c_sub: %b",
      $time,
      m_cpu.bus,
      m_cpu.pc_out,
      m_cpu.cycle,
      m_cpu.state,
      m_cpu.opcode,
      m_cpu.rega_out,
      m_cpu.regb_out,
      m_cpu.alu_out,
      m_cpu.addr_bus,
      m_cpu.eq_zero,
      m_cpu.c_sub
    );
    # 20000 $display("Kill to prevent looping."); $stop;
  end

endmodule
