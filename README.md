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
```

List of all states:

| State              | Signal enabled          |
|--------------------|-------------------------|
| `ALU_OP`           | `C_EO`, `C_AI`          |
| `FETCH_INST`       | `C_CI`, `C_RO`, `C_II`  |
| `FETCH_PC`         | `C_CO`, `C_MI`          |
| `HALT`             | `C_HALT`                |
| `JUMP`             | `C_CI`, `C_RO`, `C_J`   |
| `LOAD_ADDR`        | `C_CI`, `C_RO`, `C_MI`  |
| `OUT_A`            | `C_AO`, `C_OI`          |
| `RAM_A`            | `C_RO`, `C_AI`          |
| `RAM_B`            | `C_RO`, `C_BI`          |
| `STORE_A`          | `C_AO`, `C_RI`          |


Graph of the FSM:

```
[0]             FETCH_PC
[1]            FETCH_INST
       |------------+-----------------------|
     (HLT)        (OUT)                   (else)
[2]  HALT         OUT_A                  FETCH_PC
       |            |            |----------+--------------|
       |            |       (JNZ/JMP/JEZ)                (else)
[3]   NEXT         NEXT         JUMP                   LOAD_ADDR
                                 |                         |
                                 |               |---------|-------------|
                                 |            (STA)      (LDA)       (ADD/SUB)
[4]                             NEXT         STORE_A     RAM_A         RAM_B
                                                 |          |            |
                                                 |          |            |
[5]                                            NEXT        NEXT       ALU_OP
                                                                         |
[6]                                                                    NEXT
```

## Resources

* [ejrh's CPU in Verilog](https://github.com/ejrh/cpu)
* [Ben Eater's video series](https://eater.net/8bit/)
* [Steven Bell's microprocessor](https://stanford.edu/~sebell/oc_projects/ic_design_finalreport.pdf)
