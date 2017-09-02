`define OP_NOP 8'b00_000_000
`define OP_OUT 8'b00_000_011
`define OP_JMP 8'b00_000_100
`define OP_HLT 8'b00_000_101
`define OP_JEZ 8'b00_000_111
`define OP_JNZ 8'b00_001_001
`define OP_LDI 8'b00_010_000
`define OP_ALU 8'b01_000_000
`define OP_MOV 8'b10_000_000

`define PATTERN_LDI 8'b00_010_???
`define PATTERN_MOV 8'b10_???_???
`define PATTERN_ALU 8'b01_???_000


`define STATE_NEXT             4'h0
`define STATE_FETCH_PC         4'h1
`define STATE_FETCH_INST       4'h2
`define STATE_HALT             4'h3
`define STATE_JUMP             4'h4
`define STATE_OUT_A            4'h5
`define STATE_ALU_OP           4'h6
`define STATE_LDI              4'h7
`define STATE_MOV_STORE        4'h8
`define STATE_MOV_FETCH        4'h9
`define STATE_MOV_LOAD         4'ha

`define ALU_ADD 3'b000
`define ALU_SUB 3'b001
