`define OP_NOP  8'b00_000_000
`define OP_CALL 8'b00_000_001
`define OP_RET  8'b00_000_010
`define OP_OUT  8'b00_000_011
`define OP_JMP  8'b00_000_100
`define OP_HLT  8'b00_000_101
`define OP_JZ   8'b00_000_111
`define OP_JNZ  8'b00_001_001
`define OP_LDI  8'b00_010_000
`define OP_ALU  8'b01_000_000
`define OP_MOV  8'b10_000_000

`define PATTERN_LDI 8'b00_010_???
`define PATTERN_MOV 8'b10_???_???
`define PATTERN_ALU 8'b01_???_000


`define STATE_NEXT             8'h00
`define STATE_FETCH_PC         8'h01
`define STATE_FETCH_INST       8'h02
`define STATE_HALT             8'h03
`define STATE_JUMP             8'h04
`define STATE_OUT_A            8'h05
`define STATE_ALU_OP           8'h06
`define STATE_LDI              8'h07
`define STATE_MOV_STORE        8'h08
`define STATE_MOV_FETCH        8'h09
`define STATE_MOV_LOAD         8'h0a
`define STATE_TMP_STORE        8'h0b
`define STATE_FETCH_SP         8'h0c
`define STATE_PC_STORE         8'h0d
`define STATE_TMP_JUMP         8'h0e
`define STATE_RET              8'h0f
`define STATE_INC_SP           8'h10

`define ALU_ADD 3'b000
`define ALU_SUB 3'b001
`define ALU_INC 3'b010
`define ALU_DEC 3'b011

`define REG_T 3'b111
