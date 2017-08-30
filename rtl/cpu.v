module cpu(
  input wire clk,
  input wire reset,
  output wire [7:0] addr_bus,
  output wire c_ri,
  output wire c_ro,
  output reg mem_clk,
  inout wire [7:0] bus
);

  `include "rtl/parameters.v"

  // ==========================
  // Clocks
  // ==========================

  reg cycle_clk = 0;
  reg internal_clk = 0;
  reg [1:0] cnt = 0;
  always @ (posedge clk) begin
    case (cnt)
      0 : begin
        {cycle_clk, mem_clk, internal_clk} <= 'b100;
        cnt <= 1;
      end
      1 : begin
        {cycle_clk, mem_clk, internal_clk} <= 'b010;
        cnt <= 2;
      end
      2 : begin
        {cycle_clk, mem_clk, internal_clk} <= 'b001;
        cnt <= 0;
      end
    endcase
  end


  // ==========================
  // Registers
  // ==========================

  // A register
  wire [7:0] rega_out;
  wire c_ao;
  wire c_ai;
  register m_rega (
    .in(bus),
    .clk(internal_clk),
    .enable(c_ai),
    .reset(reset),
    .out(rega_out)
  );
  tristate_buffer m_rega_buf (
    .in(rega_out),
    .enable(c_ao),
    .out(bus)
  );

  // B register
  wire [7:0] regb_out;
  wire c_bi;
  register m_regb (
    .in(bus),
    .clk(internal_clk),
    .enable(c_bi),
    .reset(reset),
    .out(regb_out)
  );

  // Instruction Register
  wire [7:0] regi_out;
  wire c_ii;
  register m_regi (
    .in(bus),
    .clk(internal_clk),
    .enable(c_ii),
    .reset(reset),
    .out(regi_out)
  );

  // Memory Address Register
  wire c_mi;
  register m_mar (
    .in(bus),
    .clk(internal_clk),
    .enable(c_mi),
    .reset(reset),
    .out(addr_bus)
  );


  // ==========================
  // Program Counter
  // ==========================

  wire [7:0] pc_out;
  wire c_co;
  wire c_ci;
  wire c_j;
  counter m_pc (
    .clk(c_ci & internal_clk),
    .in(bus),
    .sel_in(c_j),
    .reset(reset),
    .out(pc_out)
  );
  tristate_buffer m_pc_buf (
    .in(pc_out),
    .enable(c_co),
    .out(bus)
  );


  // ==========================
  // ALU
  // ==========================

  reg cin = 0;
  wire c_eo;
  wire c_sub;
  wire eq_zero; // high when reg A is equal to 0
  wire [7:0] alu_out;
  alu m_alu (
    .cin(cin),
    .cout(),
    .in_a(rega_out),
    .in_b(regb_out),
    .out(alu_out),
    .sub(c_sub),
    .eq_zero(eq_zero)
  );
  tristate_buffer m_alu_buf (
    .in(alu_out),
    .enable(c_eo),
    .out(bus)
  );


  // ==========================
  // Control logic
  // ==========================

  wire c_halt, c_next, c_oi;
  wire [3:0] state;
  wire [7:0] opcode;

  assign opcode = regi_out;

  wire jump_allowed;
  assign jump_allowed = opcode == `OP_JMP | (opcode == `OP_JEZ & eq_zero) | (opcode == `OP_JNZ & !eq_zero);

  assign c_next = state == `STATE_NEXT | reset;
  assign c_sub  = state == `STATE_ALU_OP & opcode == `OP_SUB;

  assign c_ai   = state == `STATE_RAM_A | state == `STATE_ALU_OP;
  assign c_ao   = state == `STATE_OUT_A | state == `STATE_STORE_A;
  assign c_bi   = state == `STATE_RAM_B;
  assign c_ci   = state == `STATE_FETCH_INST | state == `STATE_JUMP | state == `STATE_LOAD_ADDR;
  assign c_co   = state == `STATE_FETCH_PC;
  assign c_eo   = state == `STATE_ALU_OP;
  assign c_halt = state == `STATE_HALT;
  assign c_ii   = state == `STATE_FETCH_INST;
  assign c_j    = state == `STATE_JUMP & jump_allowed;
  assign c_mi   = state == `STATE_FETCH_PC | state == `STATE_LOAD_ADDR;
  assign c_oi   = state == `STATE_OUT_A;
  assign c_ro   = state == `STATE_FETCH_INST | (state == `STATE_JUMP & jump_allowed) |
                  state == `STATE_RAM_A | state == `STATE_RAM_B | state == `STATE_LOAD_ADDR;
  assign c_ri   = state == `STATE_STORE_A;

  wire [3:0] cycle;
  cpu_control m_ctrl (
    .opcode(opcode),
    .state(state),
    .reset_cycle(c_next),
    .clk(cycle_clk),
    .cycle(cycle)
  );

  always @ (posedge c_halt) begin
    $display("Halted.");
    $stop;
  end

  always @ (posedge c_oi) begin
    $display("Output: %d (%h)", rega_out, rega_out);
  end

endmodule
