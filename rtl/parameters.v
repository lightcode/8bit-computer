`define OP_NOP 8'h00
`define OP_LDA 8'h01
`define OP_ADD 8'h02
`define OP_OUT 8'h03
`define OP_JMP 8'h04
`define OP_HLT 8'h05
`define OP_SUB 8'h06
`define OP_JEZ 8'h07
`define OP_STA 8'h08
`define OP_JNZ 8'h09

`define STATE_NEXT             4'h0
`define STATE_FETCH_PC         4'h1
`define STATE_FETCH_INST       4'h2
`define STATE_HALT             4'h3
`define STATE_JUMP             4'h4
`define STATE_OUT_A            4'h5
`define STATE_RAM_A            4'h6
`define STATE_RAM_B            4'h7
`define STATE_STORE_A          4'h8
`define STATE_LOAD_ADDR        4'h9
`define STATE_ALU_OP           4'ha

`define ALU_ADD 4'h0
`define ALU_SUB 4'h1
