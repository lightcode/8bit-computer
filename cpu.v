module cpu;

  wire clock;
  wire [7:0] bus;

  reg reset = 0;

  // ==========================
  // System clock
  // ==========================

  clock sys_clk (clk);


  // ==========================
  // Registers
  // ==========================

  // A register
  wire [7:0] regA_bus;
  reg c_ao = 0;
  reg c_ai = 0;
  register regA (bus, clk, c_ai, reset, regA_bus);
  tristate_buffer regA_buff (regA_bus, c_ao, bus);

  // B register
  wire [7:0] regB_bus;
  reg c_bo = 0;
  reg c_bi = 0;
  register regB (bus, clk, c_bi, reset, regB_bus);
  tristate_buffer regB_buff (regB_bus, c_bo, bus);

  // Z register
  wire [7:0] regZ_bus;
  reg c_zo = 0;
  reg c_zi = 0;
  register regZ (bus, clk, c_zi, reset, regZ_bus);
  tristate_buffer regZ_buff (regZ_bus, c_zo, bus);

  // Instruction Register
  wire [7:0] regI_bus;
  reg c_io = 0;
  reg c_ii = 0;
  register regI (bus, clk, c_ii, reset, regI_bus);
  tristate_buffer regI_buff (regI_bus, c_io, bus);


  // ==========================
  // Program Counter
  // ==========================

  wire [7:0] pc_out;
  reg c_co = 0;
  reg c_ce = 0;
  reg c_j = 0;
  counter pc (c_ce, bus, c_j, reset, pc_out);
  tristate_buffer pc_buff (pc_out, c_co, bus);


  // ==========================
  // ALU
  // ==========================

  reg cin = 0;
  reg c_eo = 0;
  wire [7:0] sum;
  alu alu (cin, cout, regA_bus, regB_bus, sum);
  tristate_buffer sum_buff (sum, c_eo, bus);


  // ==========================
  // Tests
  // ==========================

  initial begin
    $monitor("At time %t, bus = %h, sum = %d, regA = %d, regB = %d, pc_out = %d", $time, bus, sum, regA_bus, regB_bus, pc_out);
  end

  initial begin
    # 1 c_eo = 0;
    # 1 c_co = 1;
    # 1 reset = 1;
    # 1 reset = 0;
    # 2 c_ce = 1;
    # 5 c_ce = 1;
    # 5 c_ai = 1;
    # 6 c_ao = 0;
    # 1 c_bi = 1;
    # 100 $stop;
  end

endmodule
