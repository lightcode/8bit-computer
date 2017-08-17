Simple 8-bit computer in Verilog
================================

```
FETCH_PC   = C_CO | C_MI
FETCH_INST = C_CI | C_RO | C_II
FETCH_ARG  = C_CI | C_RO | C_ZI
HALT       = C_HALT
JUMP_Z     = C_CI | C_RO | C_J
OUT_A      = C_AO | C_OI
LOAD_Z     = C_ZO | C_MI
RAM_A      = C_RO | C_AI
RAM_B      = C_RO | C_BI
ADD        = C_EO | C_AI
SUB        = C_EO | C_AI | C_SUB
```

```
C_AI   = RAM_A || ALU
C_AO   = OUT_A
C_BI   = RAM_B
C_CI   = FETCH_INST || FETCH_ARG || JUMP_Z
C_CO   = FETCH_PC
C_EO   = ALU
C_HALT = HALT
C_II   = FETCH_INST
C_J    = JUMP_Z
C_MI   = FETCH_PC || LOAD_Z
C_OI   = OUT_A
C_RO   = FETCH_INST || FETCH_ARG || JUMP_Z || RAM_A || RAM_B
C_SUB  = SUB
C_ZI   = FETCH_ARG
C_ZO   = LOAD_Z
```

```
NOP : FETCH_PC, FETCH_INST
LDA : FETCH_PC, FETCH_INST, FETCH_PC, FETCH_ARG, LOAD_Z, RAM_A
ADD : FETCH_PC, FETCH_INST, FETCH_PC, FETCH_ARG, LOAD_Z, RAM_B, ADD
SUB : FETCH_PC, FETCH_INST, FETCH_PC, FETCH_ARG, LOAD_Z, RAM_B, SUB
OUT : FETCH_PC, FETCH_INST, OUT_A
JMP : FETCH_PC, FETCH_INST, FETCH_PC, JUMP_Z
HLT : FETCH_PC, FETCH_INST, HALT
```

```
           FETCH_PC       [0]
          FETCH_INST      [1]
  |------------+-------------------|
(HLT)        (OUT)              (else)
HALT         OUT_A             FETCH_PC   [2]
  |            |          |--------+-------------|
  |            |        (JMP)                  (else)
 NEXT         NEXT     JUMP_Z                FETCH_ARG    [3]
                          |                      |
                        (JMP)                  (else)
                         NEXT                  LOAD_Z     [4]
                                         |-------+-------|
                                       (LDA)           (else)
                                       RAM_A           RAM_B   [5]
                                         |               |
                                         |        |------+-------|
                                        NEXT     ADD            SUB   [6]
                                                  |              |
                                                 NEXT          NEXT   [7]
```
