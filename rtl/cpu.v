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

  // General Purpose Registers
  // 0 is for accumulator
  wire [2:0] sel_in;
  wire [2:0] sel_out;
  wire rfi;
  wire rfo;
  wire [7:0] rega_out;
  wire [7:0] regb_out;
  cpu_registers m_registers (
    .clk(internal_clk),
    .data_in(bus),
    .sel_in(sel_in),
    .sel_out(sel_out),
    .enable_write(rfi),
    .output_enable(rfo),
    .data_out(bus),
    .rega(rega_out),
    .regb(regb_out)
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
  wire eq_zero; // high when reg A is equal to 0
  wire [7:0] alu_out;
  wire [2:0] alu_mode;
  alu m_alu (
    .cin(cin),
    .cout(),
    .in_a(rega_out),
    .in_b(regb_out),
    .out(alu_out),
    .mode(alu_mode),
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

  wire [2:0] operand1;
  wire [2:0] operand2;
  assign operand1 = opcode[5:3];
  assign operand2 = opcode[2:0];

  wire mov_memory;
  assign mov_memory = operand1 == 3'b111 || operand2 == 3'b111;

  wire jump_allowed;
  assign jump_allowed = opcode == `OP_JMP | (opcode == `OP_JEZ & eq_zero) | (opcode == `OP_JNZ & !eq_zero);

  assign c_next = state == `STATE_NEXT | reset;

  assign alu_mode = (state == `STATE_ALU_OP) ? operand1 : 'bx;

  assign sel_in = (state == `STATE_ALU_OP | state == `STATE_RAM_A) ? 0 :
                  (state == `STATE_RAM_B) ? 1 :
                  (state == `STATE_LDI) ? operand2 :
                  (state == `STATE_MOV_STORE) ? operand1 :
                  'bx;

  assign sel_out = (state == `STATE_OUT_A | state == `STATE_STORE_A) ? 0 :
                   (state == `STATE_MOV_STORE) ? operand2 :
                   'bx;

  assign rfi = state == `STATE_RAM_A | state == `STATE_ALU_OP | state == `STATE_RAM_B | state == `STATE_LDI | (state == `STATE_MOV_STORE && operand1 != 3'b111);
  assign rfo = state == `STATE_OUT_A | state == `STATE_STORE_A | (state == `STATE_MOV_STORE && operand2 != 3'b111);

  assign c_ci   = state == `STATE_FETCH_INST | state == `STATE_JUMP | state == `STATE_LOAD_ADDR | state == `STATE_LDI | ((state == `STATE_MOV_LOAD) & mov_memory);
  assign c_co   = state == `STATE_FETCH_PC  | (state == `STATE_MOV_FETCH && mov_memory);
  assign c_eo   = state == `STATE_ALU_OP;
  assign c_halt = state == `STATE_HALT;
  assign c_ii   = state == `STATE_FETCH_INST;
  assign c_j    = state == `STATE_JUMP & jump_allowed;
  assign c_mi   = state == `STATE_FETCH_PC | state == `STATE_LOAD_ADDR | ((state == `STATE_MOV_FETCH | state == `STATE_MOV_LOAD) & mov_memory);
  assign c_oi   = state == `STATE_OUT_A;
  assign c_ro   = state == `STATE_FETCH_INST | (state == `STATE_JUMP & jump_allowed) |
                  state == `STATE_RAM_A | state == `STATE_RAM_B | state == `STATE_LOAD_ADDR | state == `STATE_LDI | (state == `STATE_MOV_LOAD & mov_memory) | (state == `STATE_MOV_STORE & operand2 == 3'b111);
  assign c_ri   = state == `STATE_STORE_A | (state == `STATE_MOV_STORE && operand1 == 3'b111);

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
