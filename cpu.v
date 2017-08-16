module cpu;

  `include "parameters.v"

  wire [7:0] bus;

  reg reset = 0;

  // ==========================
  // System clock
  // ==========================

  wire clk;
  wire nclk;
  reg enable_clk = 0;
  clock sys_clk (enable_clk, nclk, clk);

  always @(negedge clk)
    $display("-----");


  // ==========================
  // Registers
  // ==========================

  // A register
  wire [7:0] regA_bus;
  wire c_ao;
  wire c_ai;
  register regA (bus, nclk, c_ai, reset, regA_bus);
  tristate_buffer regA_buff (regA_bus, c_ao, bus);

  // B register
  wire [7:0] regB_bus;
  wire c_bi;
  register regB (bus, nclk, c_bi, reset, regB_bus);

  // Z register
  wire [7:0] regZ_bus;
  wire c_zo;
  wire c_zi;
  register regZ (bus, nclk, c_zi, reset, regZ_bus);
  tristate_buffer regZ_buff (regZ_bus, c_zo, bus);

  // Instruction Register
  wire [7:0] regI_bus;
  wire c_io;
  wire c_ii;
  register regI (bus, nclk, c_ii, reset, regI_bus);
  //tristate_buffer regI_buff (regI_bus, c_io, bus);


  // ==========================
  // Program Counter
  // ==========================

  wire [7:0] pc_out;
  wire c_co;
  wire c_ci;
  wire c_j;
  counter pc (c_ci, bus, c_j, reset, pc_out);
  tristate_buffer pc_buff (pc_out, c_co, bus);


  // ==========================
  // ALU
  // ==========================

  reg cin = 0;
  wire c_eo;
  wire [7:0] sum;
  alu alu (cin, cout, regA_bus, regB_bus, sum);
  tristate_buffer sum_buff (sum, c_eo, bus);


  // ==========================
  // Memory
  // ==========================

  // Memory Address Register
  wire [7:0] mar_bus;
  wire c_mi;
  register mar (bus, nclk, c_mi, reset, mar_bus);

  // RAM
  wire [7:0] mem_out;
  wire c_ri;
  wire c_ro;
  memory mem (clk, mar_bus, bus, c_mi, c_ri, mem_out);
  tristate_buffer mem_buff (mem_out, c_ro, bus);


  // ==========================
  // Decoder
  // ==========================

  wire [3:0] cycle;
  wire [3:0] state;
  wire [3:0] opcode;

  assign opcode[3:0] = regI_bus[3:0];

  assign c_ai   = (state == `STATE_RAM_A) || (state == `STATE_ALU);
  assign c_ao   = (state == `STATE_OUT_A);
  assign c_bi   = (state == `STATE_RAM_B);
  assign c_ci   = (state == `STATE_FETCH_INST) || (state == `STATE_FETCH_ARG) || (state == `STATE_JUMP_Z);
  assign c_co   = (state == `STATE_FETCH_PC);
  assign c_eo   = (state == `STATE_ALU);
  assign c_halt = (state == `STATE_HALT);
  assign c_ii   = (state == `STATE_FETCH_INST);
  assign c_j    = (state == `STATE_JUMP_Z);
  assign c_mi   = (state == `STATE_FETCH_PC) || (state == `STATE_LOAD_Z);
  assign c_next = (state == `STATE_NEXT) || (reset == 1);
  assign c_oi   = (state == `STATE_OUT_A);
  assign c_ro   = (state == `STATE_FETCH_INST) || (state == `STATE_FETCH_ARG) || (state == `STATE_JUMP_Z) || (state == `STATE_RAM_A) || (state == `STATE_RAM_B);
  assign c_zi   = (state == `STATE_FETCH_ARG);
  assign c_zo   = (state == `STATE_LOAD_Z);

  decoder dec (opcode, cycle, state);

  counter #(.N(4)) cycle_count (clk, , , c_next, cycle);


  // ==========================
  // Tests
  // ==========================

  initial begin
    # 10 reset = 1;
    # 10 reset = 0;
    # 10 $monitor(
      "[%t : %b/%b] bus: %h, pc: %d, cycle: %d, state: %h, opcode: %h, a: %h, b: %h, alu: %h NEXT: %1b, CO: %1b, MI: %1b, II: %1b, RO: %1b, mar: %h, ins: %h, mem: %h",
      $time, clk, nclk, bus, pc_out, cycle, state, opcode, regA_bus, regB_bus, sum, c_next, c_co, c_mi, c_ii, c_ro, mar_bus, regI_bus, mem_out);
    # 10 enable_clk = 1;
    # 2000 $stop;
  end

endmodule
