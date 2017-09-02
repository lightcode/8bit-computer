module cpu_control(
  input wire [7:0] opcode,
  input wire clk,
  input wire reset_cycle,
  output reg [3:0] state,
  output reg [3:0] cycle
);

  `include "rtl/parameters.v"

  reg [7:0] code;

  initial
    cycle = 0;

  always @ (posedge clk) begin
    casez (opcode)
      `PATTERN_LDI: code = `OP_LDI;
      `PATTERN_MOV: code = `OP_MOV;
      `PATTERN_ALU: code = `OP_ALU;
      default: code = opcode;
    endcase

    case (cycle)
      0: state = `STATE_FETCH_PC;
      1: state = `STATE_FETCH_INST;
      2: state = (code == `OP_HLT) ? `STATE_HALT :
                 (code == `OP_OUT) ? `STATE_OUT_A :
                 (code == `OP_MOV) ? `STATE_MOV_FETCH :
                 (code == `OP_ALU) ? `STATE_ALU_OP :
                 `STATE_FETCH_PC;
      3: state = (code == `OP_JMP || code == `OP_JEZ || code == `OP_JNZ) ? `STATE_JUMP :
                 (code == `OP_LDI) ? `STATE_LDI :
                 (code == `OP_MOV) ? `STATE_MOV_LOAD :
                 `STATE_NEXT;
      4: state = (code == `OP_MOV) ? `STATE_MOV_STORE :
                 `STATE_NEXT;
      5: state = `STATE_NEXT;
      default: $display("Cannot decode : cycle = %d, opcode = %h", cycle, opcode);
    endcase

    cycle = (cycle > 6) ? 0 : cycle + 1;
  end

  always @ (posedge reset_cycle) begin
    cycle = 0;
  end

endmodule
