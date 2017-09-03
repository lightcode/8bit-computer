Simple 8-bit computer in Verilog
================================

This computer is inspired by [Ben Eater's computer](https://eater.net/8bit/) and by [Edmund Horner's CPU](https://github.com/ejrh/cpu).



## How to use it

Build an exemple:

```
./asm/asm.py asm/multiplication.asm > memory.list
```

Run the computer:

```
make clean_computer && make run_computer
```

## Assembly

### Instructions list

| Instruction   | Description                                                |
|---------------|------------------------------------------------------------|
| ``lda``       | Alias for ``mov A M D``                                    |
| ``sta``       | Alias for ``mov M A D``                                    |
| ``add``       | Perform A = A + B (A, B are registers)                     |
| ``sub``       | Perform A = A - B (A, B are registers)                     |
| ``out``       | Display the content of A                                   |
| ``hlt``       | Halt the CPU                                               |
| ``jmp D``     | Jump to _D_                                                |
| ``jez D``     | Jump to _D_ if register A is equal to zero                 |
| ``jnz D``     | Jump to _D_ if register A is not equat to zero             |
| ``ldi r D``   | Load _D_ into _r_ register                                 |
| ``mov r M D`` | Copy the data at memory address D into register _r_        |
| ``mov r2 r1`` | Copy register _r1_ into _r2_                               |
| ``mov M r D`` | Copy the data from register _r_ into memory in address _D_ |
| ``call D``    | Call sub-routine _D_                                       |
| ``ret``       | Return to the parent routine                               |

Legend:

* _D_ is a byte of data. It can be a memory address or directly the data depending on the instruction.
* _r_ is a register.
* _M_ means "memory", it's used to tell to the ``mov`` instruction the source/destination of the copy.



## Internal function

### Instruction decoder and machine state

List of instruction associated with states:

```
NOP  : FETCH_PC, FETCH_INST
ALU  : FETCH_PC, FETCH_INST, ALU_OP
OUT  : FETCH_PC, FETCH_INST, OUT_A
JMP  : FETCH_PC, FETCH_INST, FETCH_PC, JUMP
JEZ  : FETCH_PC, FETCH_INST, FETCH_PC, JUMP
HLT  : FETCH_PC, FETCH_INST, HALT
JNZ  : FETCH_PC, FETCH_INST, FETCH_PC, JUMP
LDI  : FETCH_PC, FETCH_INST, FETCH_PC, LDI
MOV  : FETCH_PC, FETCH_INST, MOV_FETCH, MOV_LOAD, MOV_STORE
CALL : FETCH_PC, FETCH_INST, FETCH_PC, TMP_STORE, FETCH_SP, PC_STORE, TMP_JUMP
RET  : FETCH_PC, FETCH_INST, INC_SP, FETCH_SP, RET
```

List of all states:

| State         | II | CI | CO | RFI | RFO | EO | MI | RO | RI | HALT | J | OI | SO | SD | SI |
|---------------|----|----|----|-----|-----|----|----|----|----|------|---|----|----|----|----|
| `ALU_OP`      |    |    |    | A   |     | X  |    |    |    |      |   |    |    |    |    |
| `FETCH_INST`  | X  | X  |    |     |     |    |    | X  |    |      |   |    |    |    |    |
| `FETCH_PC`    |    |    | X  |     |     |    | X  |    |    |      |   |    |    |    |    |
| `HALT`        |    |    |    |     |     |    |    |    |    | X    |   |    |    |    |    |
| `JUMP`        |    | X  |    |     |     |    |    | 1  |    |      | 1 |    |    |    |    |
| `OUT_A`       |    |    |    |     | A   |    |    |    |    |      |   | X  |    |    |    |
| `LDI`         |    | X  |    | op2 |     |    |    | X  |    |      |   |    |    |    |    |
| `MOV_FETCH`   |    |    | X  |     |     |    | X  |    |    |      |   |    |    |    |    |
| `MOV_LOAD`    |    | *  |    | *   | *   |    | *  | *  |    |      |   |    |    |    |    |
| `MOV_STORE`   |    |    |    | *   | *   |    |    | *  | *  |      |   |    |    |    |    |
| `TMP_STORE`   |    | X  |    | T   |     |    |    | X  |    |      |   |    |    |    |    |
| `FETCH_SP`    |    |    |    |     |     |    | X  |    |    |      |   |    | X  |    |    |
| `PC_STORE`    |    |    | X  |     |     |    |    |    | X  |      |   |    |    |    |    |
| `TMP_JUMP`    |    | X  |    |     | T   |    |    |    |    |      | X |    |    | X  | X  |
| `RET`         |    | X  |    |     |     |    |    | X  |    |      | X |    |    |    |    |
| `INC_SP`      |    |    |    |     |     |    |    |    |    |      |   |    |    |    | X  |

Special cases:

1. Enabled when we have to jump


Graph of the FSM:

```
[0]                            FETCH_PC
                                   |
[1]                            FETCH_INST
       |------------+--------------+----------+-----------+-----------------------|
     (HLT)        (OUT)          (MOV)      (ALU)       (RET)                   (else)
[2]  HALT         OUT_A         MOV_FETCH   ALU_OP      INC_SP                 FETCH_PC
       |            |              |                      |          |-------------+------------|
       |            |              |                      |     (JNZ/JMP/JEZ)    (LDI)        (CALL)
[3]   NEXT         NEXT         MOV_LOAD               FETCH_SP     JUMP          LDI        TMP_STORE
                                   |                      |          |             |            |
                                   |                      |          |             |            |
[4]                             MOV_STORE                RET        NEXT          NEXT       FETCH_SP
                                   |                      |                                     |
[5]                              NEXT                   NEXT                                 PC_STORE
                                                                                                |
[6]                                                                                          TMP_JUMP
                                                                                                |
[7]                                                                                           NEXT
```

### Clocks

```
CLK:
          +-+ +-+ +-+ +-+ +-+ +-+ +
          | | | | | | | | | | | | |
          | | | | | | | | | | | | |
          + +-+ +-+ +-+ +-+ +-+ +-+

CYCLE_CLK:
          +---+       +---+
          |   |       |   |
          |   |       |   |
          +   +---+---+   +---+---+

MEM_CLK:
              +---+       +---+
              |   |       |   |
              |   |       |   |
          +---+   +---+---+   +---+

INTERNAL_CLK:
                  +---+       +---+
                  |   |       |   |
                  |   |       |   |
          +---+---+   +---+---+   +
```



## Resources

* [ejrh's CPU in Verilog](https://github.com/ejrh/cpu)
* [Ben Eater's video series](https://eater.net/8bit/)
* [Steven Bell's microprocessor](https://stanford.edu/~sebell/oc_projects/ic_design_finalreport.pdf)
