module control(
  input wire [3:0] opcode,
  input wire [3:0] cycle,
  output reg [3:0] state
);

  `include "parameters.v"

  always @ (cycle) begin
    case (cycle)
      0: state = `STATE_FETCH_PC;
      1: state = `STATE_FETCH_INST;
      2: begin
        if (opcode == `OP_HLT)
          state = `STATE_HALT;
        else if (opcode == `OP_OUT)
          state = `STATE_OUT_A;
        else
          state = `STATE_FETCH_PC;
      end
      3: begin
        if (opcode == `OP_HLT || opcode == `OP_OUT)
          state = `STATE_NEXT;
        else if (opcode == `OP_JMP)
          state = `STATE_JUMP_Z;
        else
          state = `STATE_FETCH_ARG;
      end
      4: state = (opcode == `OP_JMP) ? `STATE_NEXT : `STATE_LOAD_Z;
      5: state = (opcode == `OP_LDA) ? `STATE_RAM_A : `STATE_RAM_B;
      6: state = (opcode == `OP_LDA) ? `STATE_NEXT : (opcode == `OP_ADD) ? `STATE_ADD : `STATE_SUB;
      7: state = `STATE_NEXT;
      default: $display("Cannot decode : cycle = %d, opcode = %h", cycle, opcode);
    endcase
  end

endmodule
