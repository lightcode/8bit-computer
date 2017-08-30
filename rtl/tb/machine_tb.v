module machine_tb;

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
  // Machine
  // ==========================

  reg reset = 0;
  machine m_machine(
    .reset(reset),
    .clk(clk)
  );


  // ==========================
  // Tests and monitoring
  // ==========================

  initial begin
    $readmemh("memory.list", m_machine.m_ram.mem);
    $dumpfile("machine.vcd");
    $dumpvars(0, m_machine);
  end

  initial begin
    # 10 reset = 1;
    # 10 reset = 0;
    # 10 enable_clk = 1;
    $monitor(
      "[%08d] bus: %h, pc: %h, cycle: %h, state: %h, opcode: %h, a: %h, b: %h, alu: %h, mar: %h, eq_zero: %b, c_sub: %b",
      $time,
      m_machine.m_cpu.bus,
      m_machine.m_cpu.pc_out,
      m_machine.m_cpu.cycle,
      m_machine.m_cpu.state,
      m_machine.m_cpu.opcode,
      m_machine.m_cpu.rega_out,
      m_machine.m_cpu.regb_out,
      m_machine.m_cpu.alu_out,
      m_machine.m_cpu.addr_bus,
      m_machine.m_cpu.eq_zero,
      m_machine.m_cpu.c_sub
    );
    # 20000 $display("Kill to prevent looping."); $stop;
  end

endmodule
