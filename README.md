Simple 8-bit computer in Verilog
================================

## Instruction decoder and machine state

List of instruction associated with states:

```
NOP : FETCH_PC, FETCH_INST
LDA : FETCH_PC, FETCH_INST, FETCH_PC, FETCH_ARG, LOAD_Z, RAM_A
ADD : FETCH_PC, FETCH_INST, FETCH_PC, FETCH_ARG, LOAD_Z, RAM_B, ADD
SUB : FETCH_PC, FETCH_INST, FETCH_PC, FETCH_ARG, LOAD_Z, RAM_B, SUB
OUT : FETCH_PC, FETCH_INST, OUT_A
JMP : FETCH_PC, FETCH_INST, FETCH_PC, JUMP
JEZ : FETCH_PC, FETCH_INST, FETCH_PC, JUMP_IF_ZERO
HLT : FETCH_PC, FETCH_INST, HALT
STA : FETCH_PC, FETCH_INST, FETCH_PC, FETCH_ARG, LOAD_Z, STORE_A
JNZ : FETCH_PC, FETCH_INST, FETCH_PC, JUMP_IF_NOT_ZERO
```

List of all states:

| State              | Signal enabled          |
|--------------------|-------------------------|
| `ADD`              | `C_EO`, `C_AI`          |
| `FETCH_ARG`        | `C_CI`, `C_RO`, `C_ZI`  |
| `FETCH_INST`       | `C_CI`, `C_RO`, `C_II`  |
| `FETCH_PC`         | `C_CO`, `C_MI`          |
| `HALT`             | `C_HALT`                |
| `JUMP`             | `C_CI`, `C_RO`, `C_J`   |
| `LOAD_Z`           | `C_ZO`, `C_MI`          |
| `OUT_A`            | `C_AO`, `C_OI`          |
| `RAM_A`            | `C_RO`, `C_AI`          |
| `RAM_B`            | `C_RO`, `C_BI`          |
| `SUB`              | `C_EO`, `C_AI`, `C_SUB` |
| `STORE_A`          | `C_AO`, `C_RI`          |
| `JUMP_IF_ZERO`     | `C_CI`, `C_RO`, `C_J`   |
| `JUMP_IF_NOT_ZERO` | `C_CI`, `C_RO`, `C_J`   |


Graph of the FSM:

```
[0]             FETCH_PC
[1]            FETCH_INST
       |------------+------------------------|
     (HLT)        (OUT)                   (else)
[2]  HALT         OUT_A                   FETCH_PC
       |            |          |-------------+-------------|
       |            |        (JMP)         (JEZ)         (else)
[3]   NEXT         NEXT       JUMP      JUMP_IF_ZERO    FETCH_ARG
                               |             |             |
                               |             |           (else)
[4]                           NEXT         NEXT          LOAD_Z
                                        |----------|-------+-------|
                                      (STA)      (LDA)           (else)
[5]                                  STORE_A     RAM_A           RAM_B
                                        |          |               |
                                        |          |        |------+-------|
[6]                                   NEXT        NEXT     ADD            SUB
                                                            |              |
[7]                                                        NEXT          NEXT
```
