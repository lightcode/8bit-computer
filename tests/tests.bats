#!/usr/bin/env bats

function compile_and_run() {
  local asm_file="$1"
  ./asm/asm.py "./tests/${asm_file}" > ./memory.list
  make clean
  make run
}

@test "test I/O" {
  compile_and_run io_test.asm | grep -E 'REGISTERS: A: ff, B: [xz]+, C: [xz]+, D: [xz]+, E: [xz]+, F: [xz]+, G: [xz]+, Temp: [xz]+'
}

@test "test ALU" {
  compile_and_run alu_test.asm | grep -E 'REGISTERS: A: ff, B: 02, C: [xz]+, D: 0e, E: f0, F: ff, G: 0f, Temp: [xz]+'
}

@test "test call" {
  compile_and_run call_test.asm | awk '/Output:/ { print $2; }' | tr '\n' ' ' | grep '10 42 10'
}

@test "test multiplication" {
  compile_and_run multiplication_test.asm | grep 'Output:  16'
}

@test "test mov" {
  compile_and_run mov_test.asm | awk '/Output:/ { print $2; }' | tr '\n' ' ' | grep '42 21'
}
