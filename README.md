8-bit computer in Verilog
=========================

This project contains:

* a 8-bit CPU with a basic instruction set
* 256 bytes of RAM


## How to use it

Build an exemple:

```
./asm/asm.py tests/multiplication.asm > memory.list
```

Run the computer:

```
make clean && make run
```


## Assembly

### Instructions set

#### Data transfert group

| Instruction   | Description                                                |
|---------------|------------------------------------------------------------|
| `lda`         | Alias for `mov A M D`                                      |
| `sta`         | Alias for `mov M A D`                                      |
| `ldi r D`     | Load _D_ into _r_ register                                 |
| `mov r M D`   | Copy the data at memory address D into register _r_        |
| `mov r2 r1`   | Copy register _r1_ into _r2_                               |
| `mov M r D`   | Copy the data from register _r_ into memory in address _D_ |


Legend:

* _D_ is a byte of data. It can be a memory address or directly the data depending on the instruction.
* _r_ is a register.
* _M_ means "memory", it's used to tell to the `mov` instruction the source/destination of the copy.


#### Arithmetic group

| Instruction   | Description                                                |
|---------------|------------------------------------------------------------|
| `add`         | Perform A = A + B (A, B are registers)                     |
| `adc`         | Perform A = A + B + carry (A, B are registers)             |
| `sub`         | Perform A = A - B (A, B are registers)                     |
| `inc`         | Perform A = A + 1 (A is a register)                        |
| `dec`         | Perform A = A - 1 (A is a register)                        |
| `cmp`         | Perform A - B without updating A, just update flags        |


#### Logical group

| Instruction   | Description                                                |
|---------------|------------------------------------------------------------|
| `and`         | Perform A = A AND B (A, B are registers)                   |
| `or`          | Perform A = A OR B (A, B are registers)                    |
| `xor`         | Perform A = A XOR B (A, B are registers)                   |


#### Branching group

| Instruction   | Description                                                                  |
|---------------|------------------------------------------------------------------------------|
| `jmp D`       | Jump to _D_                                                                  |
| `jz D `       | Jump to _D_ if flag zero is set                                              |
| `jnz D`       | Jump to _D_ if flag zero is not set                                          |
| `je D `       | Jump to _D_ if register A equals register B after `cmp` (alias `jz`)         |
| `jne D`       | Jump to _D_ if register A doesn't equal register B after `cmp` (alias `jnz`) |
| `jc D `       | Jump to _D_ if carry flag is set                                             |
| `jnc D`       | Jump to _D_ if carry flag is not set                                         |
| `call D`      | Call sub-routine _D_                                                         |
| `ret`         | Return to the parent routine                                                 |


#### Machine control

| Instruction   | Description                                                |
|---------------|------------------------------------------------------------|
| `nop`         | Do nothing                                                 |
| `hlt`         | Halt the CPU                                               |


#### I/O group

| Instruction   | Description                                                                  |
|---------------|------------------------------------------------------------------------------|
| `in D`        | Put the content of the data bus in the A register and set _D_ on address bus |
| `out D`       | Put the content of accumulator on the data bus and set _D_ on address bus    |


#### Stack operation group

| Instruction   | Description                                                 |
|---------------|-------------------------------------------------------------|
| `push r`      | Push the content of register _r_ on the stack               |
| `pop r`       | Pop the content from the stack and put it into register _r_ |



## Internal function

### Instruction decoding

T1 and T2 are always `FETCH_PC` and `FETCH_INST`.

List of instruction associated with states:

| Instruction | T3          | T4          | T5          | T6         | T7         |
|-------------|-------------|-------------|-------------|------------|------------|
| `NOP`       |             |             |             |            |            |
| `ALU`       | `ALU_EXEC`  | `ALU_STORE` |             |            |            |
| `CMP`       | `ALU_EXEC`  |             |             |            |            |
| `OUT`       | `FETCH_PC`  | `SET_ADDR`  | `OUT`       |            |            |
| `IN `       | `FETCH_PC`  | `SET_ADDR`  | `IN`        |            |            |
| `HLT`       | `HALT`      |             |             |            |            |
| `JMP`       | `FETCH_PC`  | `JUMP`      |             |            |            |
| `LDI`       | `FETCH_PC`  | `SET_REG`   |             |            |            |
| `MOV`       | `MOV_FETCH` | `MOV_LOAD`  | `MOV_STORE` |            |            |
| `CALL`      | `FETCH_PC`  | `SET_REG`   | `FETCH_SP`  | `PC_STORE` | `TMP_JUMP` |
| `RET`       | `INC_SP`    | `FETCH_SP`  | `RET`       |            |            |
| `PUSH`      | `FETCH_SP`  | `REG_STORE` |             |            |            |
| `POP`       | `INC_SP`    | `FETCH_SP`  | `SET_REG`   |            |            |


States versus signals enabled:

| States        | II | CI | CO | RFI | RFO | EO | EE | MI | RO | RI | HALT | J | SO | SD | SI | MEM/IO |
|---------------|----|----|----|-----|-----|----|----|----|----|----|------|---|----|----|----|--------|
| `ALU_EXEC`    |    |    |    |     |     |    | X  |    |    |    |      |   |    |    |    |        |
| `ALU_STORE`   |    |    |    | X   |     | X  |    |    |    |    |      |   |    |    |    |        |
| `FETCH_INST`  | X  |    |    |     |     |    |    |    | X  |    |      |   |    |    |    |        |
| `FETCH_PC`    |    | X  | X  |     |     |    |    | X  |    |    |      |   |    |    |    |        |
| `FETCH_SP`    |    |    |    |     |     |    |    | X  |    |    |      |   | X  |    |    |        |
| `HALT`        |    |    |    |     |     |    |    |    |    |    | X    |   |    |    |    |        |
| `INC_SP`      |    |    |    |     |     |    |    |    |    |    |      |   |    |    | X  |        |
| `IN`          |    |    |    | X   |     |    |    |    |    |    |      |   |    |    |    | X      |
| `JUMP`        |    | *  |    |     |     |    |    |    | *  |    |      | * |    |    |    |        |
| `MOV_FETCH`   |    | *  | *  |     |     |    |    | *  |    |    |      |   |    |    |    |        |
| `MOV_LOAD`    |    |    |    | *   | *   |    |    | *  | *  |    |      |   |    |    |    |        |
| `MOV_STORE`   |    |    |    | *   | *   |    |    |    | *  | *  |      |   |    |    |    |        |
| `OUT`         |    |    |    |     | X   |    |    |    |    |    |      |   |    |    |    | X      |
| `PC_STORE`    |    |    | X  |     |     |    |    |    |    | X  |      |   |    |    |    |        |
| `REG_STORE`   |    |    |    |     | X   |    |    |    |    | X  |      |   |    | X  | X  |        |
| `RET`         |    | X  |    |     |     |    |    |    | X  |    |      | X |    |    |    |        |
| `SET_ADDR`    |    |    |    |     |     |    |    | X  | X  |    |      |   |    |    |    |        |
| `SET_REG`     |    |    |    | X   |     |    |    |    | X  |    |      |   |    |    |    |        |
| `TMP_JUMP`    |    | X  |    |     | X   |    |    |    |    |    |      | X |    | X  | X  |        |


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
