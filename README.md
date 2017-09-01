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


## Instruction decoder and machine state

List of instruction associated with states:

```
NOP : FETCH_PC, FETCH_INST
LDA : FETCH_PC, FETCH_INST, FETCH_PC, LOAD_ADDR, RAM_A
ADD : FETCH_PC, FETCH_INST, FETCH_PC, LOAD_ADDR, RAM_B, ALU_OP
SUB : FETCH_PC, FETCH_INST, FETCH_PC, LOAD_ADDR, RAM_B, ALU_OP
OUT : FETCH_PC, FETCH_INST, OUT_A
JMP : FETCH_PC, FETCH_INST, FETCH_PC, JUMP
JEZ : FETCH_PC, FETCH_INST, FETCH_PC, JUMP
HLT : FETCH_PC, FETCH_INST, HALT
STA : FETCH_PC, FETCH_INST, FETCH_PC, LOAD_ADDR, STORE_A
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
| `RAM_A`       |    |    |    | A   |     |    |    | X  |    |      |   |    |
| `RAM_B`       |    |    |    | B   |     |    |    | X  |    |      |   |    |
| `STORE_A`     |    |    |    |     | A   |    |    |    | X  |      |   |    |
| `LDI`         |    | X  |    | op2 |     |    |    | X  |    |      |   |    |
| `MOV_FETCH`   |    |    | X  |     |     |    | X  |    |    |      |   |    |
| `MOV_LOAD`    |    | X  |    | *   | *   |    | *  | *  |    |      |   |    |
| `MOV_STORE`   |    |    |    | *   | *   |    |    | *  | *  |      |   |    |

Special cases:

1. Enabled when we have to jump


Graph of the FSM:

```
[0]             FETCH_PC
[1]            FETCH_INST
       |------------+--------------+--------------------------|
     (HLT)        (OUT)          (MOV)                      (else)
[2]  HALT         OUT_A         MOV_FETCH                  FETCH_PC
       |            |              |               |----------+--------------+--------------------------|
       |            |              |          (JNZ/JMP/JEZ)                (else)                     (LDI)
[3]   NEXT         NEXT         MOV_LOAD          JUMP                   LOAD_ADDR                     LDI
                                   |               |                         |                          |
                                   |               |               |---------|-------------|            |
                                   |               |            (STA)      (LDA)       (ADD/SUB)        |
[4]                             MOV_STORE         NEXT         STORE_A     RAM_A         RAM_B        NEXT
                                   |                               |          |            |
                                   |                               |          |            |
[5]                              NEXT                            NEXT        NEXT       ALU_OP
                                                                                           |
[6]                                                                                      NEXT
```

## Clocks

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
