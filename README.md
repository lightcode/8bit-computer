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
JMP : FETCH_PC, FETCH_INST, FETCH_PC, JUMP_Z
HLT : FETCH_PC, FETCH_INST, HALT
```

List of all states:

| State        | Signal enabled          |
|--------------|-------------------------|
| `ADD`        | `C_EO`, `C_AI`          |
| `FETCH_ARG`  | `C_CI`, `C_RO`, `C_ZI`  |
| `FETCH_INST` | `C_CI`, `C_RO`, `C_II`  |
| `FETCH_PC`   | `C_CO`, `C_MI`          |
| `HALT`       | `C_HALT`                |
| `JUMP_Z`     | `C_CI`, `C_RO`, `C_J`   |
| `LOAD_Z`     | `C_ZO`, `C_MI`          |
| `OUT_A`      | `C_AO`, `C_OI`          |
| `RAM_A`      | `C_RO`, `C_AI`          |
| `RAM_B`      | `C_RO`, `C_BI`          |
| `SUB`        | `C_EO`, `C_AI`, `C_SUB` |


Graph of the FSM:

```
[0]             FETCH_PC
[1]            FETCH_INST
       |------------+-------------------|
     (HLT)        (OUT)              (else)
[2]  HALT         OUT_A             FETCH_PC
       |            |          |--------+-------------|
       |            |        (JMP)                  (else)
[3]   NEXT         NEXT     JUMP_Z                FETCH_ARG
                               |                      |
                             (JMP)                  (else)
[4]                           NEXT                  LOAD_Z
                                              |-------+-------|
                                            (LDA)           (else)
[5]                                         RAM_A           RAM_B
                                              |               |
                                              |        |------+-------|
[6]                                          NEXT     ADD            SUB
                                                       |              |
[7]                                                   NEXT          NEXT
```
