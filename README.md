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
| ``add D``     | Add value from address _D_ to A                            |
| ``sub D``     | Substract value from address _D_ from A                    |
| ``out``       | Display the content of A                                   |
| ``hlt``       | Halt the CPU                                               |
| ``jmp D``     | Jump to _D_                                                |
| ``jez D``     | Jump to _D_ if register A is equal to zero                 |
| ``jnz D``     | Jump to _D_ if register A is not equat to zero             |
| ``ldi r D``   | Load _D_ into _r_ register                                 |
| ``mov r M D`` | Copy the data at memory address D into register _r_        |
| ``mov r2 r1`` | Copy register _r1_ into _r2_                               |
| ``mov M r D`` | Copy the data from register _r_ into memory in address _D_ |

Legend:

* _D_ is a byte of data. It can be a memory address or directly the data depending on the instruction.
* _r_ is a register.
* _M_ means "memory", it's used to tell to the ``mov`` instruction the source/destination of the copy.



## Internal function

### Instruction decoder and machine state

List of instruction associated with states:

```
NOP : FETCH_PC, FETCH_INST
ALU : FETCH_PC, FETCH_INST, FETCH_PC, LOAD_ADDR, RAM_B, ALU_OP
OUT : FETCH_PC, FETCH_INST, OUT_A
JMP : FETCH_PC, FETCH_INST, FETCH_PC, JUMP
JEZ : FETCH_PC, FETCH_INST, FETCH_PC, JUMP
HLT : FETCH_PC, FETCH_INST, HALT
JNZ : FETCH_PC, FETCH_INST, FETCH_PC, JUMP
LDI : FETCH_PC, FETCH_INST, FETCH_PC, LDI
MOV : FETCH_PC, FETCH_INST, MOV_FETCH, MOV_LOAD, MOV_STORE
```

List of all states:

| State         | II | CI | CO | RFI | RFO | EO | MI | RO | RI | HALT | J | OI |
|---------------|----|----|----|-----|-----|----|----|----|----|------|---|----|
| `ALU_OP`      |    |    |    | A   |     | X  |    |    |    |      |   |    |
| `FETCH_INST`  | X  | X  |    |     |     |    |    | X  |    |      |   |    |
| `FETCH_PC`    |    |    | X  |     |     |    | X  |    |    |      |   |    |
| `HALT`        |    |    |    |     |     |    |    |    |    | X    |   |    |
| `JUMP`        |    | X  |    |     |     |    |    | 1  |    |      | 1 |    |
| `LOAD_ADDR`   |    | X  |    |     |     |    | X  | X  |    |      |   |    |
| `OUT_A`       |    |    |    |     | A   |    |    |    |    |      |   | X  |
| `RAM_B`       |    |    |    | B   |     |    |    | X  |    |      |   |    |
| `LDI`         |    | X  |    | op2 |     |    |    | X  |    |      |   |    |
| `MOV_FETCH`   |    |    | X  |     |     |    | X  |    |    |      |   |    |
| `MOV_LOAD`    |    | *  |    | *   | *   |    | *  | *  |    |      |   |    |
| `MOV_STORE`   |    |    |    | *   | *   |    |    | *  | *  |      |   |    |

Special cases:

1. Enabled when we have to jump


Graph of the FSM:

```
[0]                            FETCH_PC
                                   |
[1]                            FETCH_INST
       |------------+--------------+--------------------------------|
     (HLT)        (OUT)          (MOV)                           (else)
[2]  HALT         OUT_A         MOV_FETCH                        FETCH_PC
       |            |              |               |----------------+---------------|
       |            |              |          (JNZ/JMP/JEZ)       (else)          (LDI)
[3]   NEXT         NEXT         MOV_LOAD          JUMP          LOAD_ADDR          LDI
                                   |               |                |               |
                                   |               |            (ALU ops)           |
[4]                             MOV_STORE         NEXT            RAM_B            NEXT
                                   |                                |
[5]                              NEXT                            ALU_OP
                                                                    |
[6]                                                               NEXT
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
