module cpu_control(
  input wire [7:0] opcode,
  input wire clk,
  input wire reset_cycle,
  output reg [3:0] state,
  output reg [3:0] cycle
);

  `include "rtl/parameters.v"

  reg [7:0] opclass;

  initial
    cycle = 0;

  always @ (posedge clk) begin
    casez (opcode)
      `OP_LDI: opclass = 8'b00_010_000;
      default: opclass = opcode;
    endcase

    case (cycle)
      0: state = `STATE_FETCH_PC;
      1: state = `STATE_FETCH_INST;
      2: state = (opclass == `OP_HLT) ? `STATE_HALT :
                 (opclass == `OP_OUT) ? `STATE_OUT_A :
                 `STATE_FETCH_PC;
      3: state = (opclass == `OP_HLT || opclass == `OP_OUT) ? `STATE_NEXT :
                 (opclass == `OP_JMP || opclass == `OP_JEZ || opclass == `OP_JNZ) ? `STATE_JUMP :
                 (opclass == 8'b00_010_000) ?  `STATE_LDI :
                 `STATE_LOAD_ADDR;
      4: state = (opclass == `OP_LDA) ? `STATE_RAM_A :
                 (opclass == `OP_STA) ? `STATE_STORE_A :
                 (opclass == `OP_ADD || opclass == `OP_SUB) ?`STATE_RAM_B :
                 `STATE_NEXT;
      5: state = (opclass == `OP_ADD || opclass == `OP_SUB) ? `STATE_ALU_OP :
                 `STATE_NEXT;
      6: state = `STATE_NEXT;
      default: $display("Cannot decode : cycle = %d, opcode = %h", cycle, opcode);
    endcase
    cycle = (cycle > 6) ? 0 : cycle + 1;
  end

  always @ (posedge reset_cycle) begin
    cycle = 0;
  end

endmodule
