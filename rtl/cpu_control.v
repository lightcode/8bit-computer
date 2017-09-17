module cpu_control(
  input wire [7:0] opcode,
  input wire clk,
  input wire reset_cycle,
  output reg [7:0] state,
  output reg [3:0] cycle
);

  `include "rtl/parameters.v"

  reg [7:0] code;

  initial
    cycle = 0;

  always @ (posedge clk) begin
    casez (opcode)
      `PATTERN_LDI:  code = `OP_LDI;
      `PATTERN_MOV:  code = `OP_MOV;
      `PATTERN_ALU:  code = `OP_ALU;
      `PATTERN_JMP:  code = `OP_JMP;
      `PATTERN_PUSH: code = `OP_PUSH;
      `PATTERN_POP:  code = `OP_POP;
      default: code = opcode;
    endcase

    case (cycle)
      `T1: state = `STATE_FETCH_PC;
      `T2: state = `STATE_FETCH_INST;
      `T3: state = (code == `OP_HLT) ? `STATE_HALT :
                   (code == `OP_MOV) ? `STATE_MOV_FETCH :
                   (code == `OP_ALU) ? `STATE_ALU_OP :
                   (code == `OP_RET || code == `OP_POP) ? `STATE_INC_SP :
                   (code == `OP_PUSH) ? `STATE_FETCH_SP :
                   (code == `OP_IN || code == `OP_OUT || code == `OP_CALL || code == `OP_LDI || code == `OP_JMP) ? `STATE_FETCH_PC :
                   `STATE_NEXT;
      `T4: state = (code == `OP_JMP) ? `STATE_JUMP :
                   (code == `OP_LDI) ? `STATE_LDI :
                   (code == `OP_MOV) ? `STATE_MOV_LOAD :
                   (code == `OP_OUT || code == `OP_IN) ? `STATE_SET_ADDR :
                   (code == `OP_PUSH) ? `STATE_REG_STORE :
                   (code == `OP_CALL) ? `STATE_TMP_STORE :
                   (code == `OP_RET || code == `OP_POP) ? `STATE_FETCH_SP :
                   `STATE_NEXT;
      `T5: state = (code == `OP_MOV) ? `STATE_MOV_STORE :
                   (code == `OP_CALL) ? `STATE_FETCH_SP :
                   (code == `OP_RET) ? `STATE_RET :
                   (code == `OP_OUT) ? `STATE_OUT :
                   (code == `OP_POP) ? `STATE_SET_REG :
                   (code == `OP_IN) ? `STATE_IN :
                   `STATE_NEXT;
      `T6: state = (code == `OP_CALL) ? `STATE_PC_STORE :
                   `STATE_NEXT;
      `T7: state = (code == `OP_CALL) ? `STATE_TMP_JUMP :
                   `STATE_NEXT;
      `T8: state = `STATE_NEXT;
      default: $display("Cannot decode : cycle = %d, opcode = %h", cycle, opcode);
    endcase

    cycle = (cycle > 6) ? 0 : cycle + 1;
  end

  always @ (posedge reset_cycle) begin
    cycle = 0;
  end

endmodule
