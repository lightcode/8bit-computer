module cpu_control(
  input wire [3:0] opcode,
  input wire [3:0] cycle,
  output reg [3:0] state
);

  `include "parameters.v"

  always @ (cycle) begin
    case (cycle)
      0: state = `STATE_FETCH_PC;
      1: state = `STATE_FETCH_INST;
      2: state = (opcode == `OP_HLT) ? `STATE_HALT :
                 (opcode == `OP_OUT) ? `STATE_OUT_A :
                 `STATE_FETCH_PC;
      3: state = (opcode == `OP_HLT || opcode == `OP_OUT) ? `STATE_NEXT :
                 (opcode == `OP_JMP || opcode == `OP_JEZ || opcode == `OP_JNZ) ? `STATE_JUMP :
                 `STATE_LOAD_ADDR;
      4: state = (opcode == `OP_LDA) ? `STATE_RAM_A :
                 (opcode == `OP_STA) ? `STATE_STORE_A :
                 (opcode == `OP_ADD || opcode == `OP_SUB) ?`STATE_RAM_B :
                 `STATE_NEXT;
      5: state = (opcode == `OP_ADD || opcode == `OP_SUB) ? `STATE_ALU_OP :
                 `STATE_NEXT;
      6: state = `STATE_NEXT;
      default: $display("Cannot decode : cycle = %d, opcode = %h", cycle, opcode);
    endcase
  end

endmodule
