module cpu(
  input wire clk,
  input wire nclk,
  input wire reset,
  output wire [7:0] addr_bus,
  output wire c_mi,
  output wire c_ri,
  output wire c_ro,
  inout wire [7:0] bus
);

  `include "parameters.v"


  // ==========================
  // Registers
  // ==========================

  // A register
  wire [7:0] rega_out;
  wire c_ao;
  wire c_ai;
  register m_rega (
    .in(bus),
    .clk(nclk),
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
    .clk(nclk),
    .enable(c_bi),
    .reset(reset),
    .out(regb_out)
  );

  // Z register
  wire [7:0] regz_out;
  wire c_zo;
  wire c_zi;
  register m_regz (
    .in(bus),
    .clk(nclk),
    .enable(c_zi),
    .reset(reset),
    .out(regz_out)
  );
  tristate_buffer m_regz_buf (
    .in(regz_out),
    .enable(c_zo),
    .out(bus)
  );

  // Instruction Register
  wire [7:0] regi_out;
  wire c_ii;
  register m_regi (
    .in(bus),
    .clk(nclk),
    .enable(c_ii),
    .reset(reset),
    .out(regi_out)
  );

  // Memory Address Register
  register m_mar (
    .in(bus),
    .clk(nclk),
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
    .clk(c_ci),
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
  alu m_alu (
    .cin(cin),
    .cout(cout),
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

  wire [3:0] cycle;
  wire [3:0] state;
  wire [3:0] opcode;

  assign opcode[3:0] = regi_out[3:0];

  assign c_ai   = state == `STATE_RAM_A || state == `STATE_ADD || state == `STATE_SUB;
  assign c_ao   = state == `STATE_OUT_A || state == `STATE_STORE_A;
  assign c_bi   = state == `STATE_RAM_B;
  assign c_ci   = (state == `STATE_FETCH_INST || state == `STATE_FETCH_ARG || state == `STATE_JUMP) && nclk;
  assign c_co   = state == `STATE_FETCH_PC;
  assign c_eo   = state == `STATE_ADD || state == `STATE_SUB;
  assign c_halt = state == `STATE_HALT;
  assign c_ii   = state == `STATE_FETCH_INST;
  assign c_j    = state == `STATE_JUMP;
  assign c_mi   = state == `STATE_FETCH_PC || state == `STATE_LOAD_Z;
  assign c_next = state == `STATE_NEXT || reset;
  assign c_oi   = state == `STATE_OUT_A;
  assign c_ro   = state == `STATE_FETCH_INST || state == `STATE_FETCH_ARG || state == `STATE_JUMP ||
                  state == `STATE_RAM_A || state == `STATE_RAM_B;
  assign c_zi   = state == `STATE_FETCH_ARG;
  assign c_zo   = state == `STATE_LOAD_Z;
  assign c_sub  = state == `STATE_SUB;
  assign c_ri   = state == `STATE_STORE_A;

  cpu_control m_ctrl (
    .opcode(opcode),
    .cycle(cycle),
    .eq_zero(eq_zero),
    .state(state)
  );

  counter #(.N(4)) m_cycle_count (
    .clk(clk),
    .reset(c_next),
    .out(cycle)
  );

  always @ (posedge c_halt) begin
    $display("Halted.");
    $stop;
  end

  always @ (posedge c_oi) begin
    $display("Output: %d (%h)", rega_out, rega_out);
  end


  // ==========================
  // Monitoring
  // ==========================

  initial begin
    # 30 $monitor(
      "[%t] bus: %h, pc: %h, cycle: %h, state: %h, opcode: %h, a: %h, b: %h, alu: %h, mar: %h, ins: %h, eq_zero: %b",
      $time, bus, pc_out, cycle, state, opcode, rega_out, regb_out, alu_out, addr_bus, regi_out, eq_zero);
  end

endmodule
