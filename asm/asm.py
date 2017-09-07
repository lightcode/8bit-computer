#!/usr/bin/env python2

import sys

progf = sys.argv[1]

inst = {
    "nop": 0x00,
    "call": 0b00000001,
    "ret": 0b00000010,
    "lda": 0b10000111,
    "out": 0x03,
    "jmp": 0x04,
    "hlt": 0x05,
    "jez": 0x07,
    "sta": 0b10111000,
    "jnz": 0x09,
    "add": 0b01000000,
    "sub": 0b01001000,
    "inc": 0b01010000,
    "dec": 0b01011000,
    "ldi": 0b00010000,
    "mov": 0b10000000,
}

reg = {
    "A": 0b000,
    "B": 0b001,
    "C": 0b010,
    "D": 0b011,
    "E": 0b100,
    "F": 0b101,
    "G": 0b110,
    "M": 0b111,
}

PROGRAM, DATA = 0, 1
MEM_SIZE = 256

mem = [0 for _ in range(MEM_SIZE)]
cnt = 0

labels = {}
data = {}
data_addr = {}

with open(progf) as f:
    for l in f:
        l = l.strip()
        if l == "":
            continue

        if l == ".program":
            section = PROGRAM
        elif l == ".data":
            section = DATA
        else:
            if section == DATA:
                n, v = map(str.strip, l.split("=", 2))
                data[str(n)] = int(v)
            elif section == PROGRAM:
                kw = l.split()
                if kw[0][-1] == ":":
                    labels[kw[0].rstrip(":")] = cnt
                else:
                    current_inst = kw[0]

                    if current_inst == "ldi":
                        r = reg[kw[1]]
                        kw[0] = (inst[kw[0]] & 0b11111000) | r
                        del kw[1]
                        kw[1] = int(kw[1])
                    elif current_inst == "mov":
                        op1 = reg[kw[1]]
                        op2 = reg[kw[2]]
                        kw[0] = (inst[kw[0]] & 0b11111000) | op2
                        kw[0] = (kw[0] & 0b11000111) | (op1 << 3)
                        del kw[2]
                        del kw[1]
                    else:
                        kw[0] = inst[kw[0]]

                    for a in kw:
                        mem[cnt] = a
                        cnt += 1

# Write data into memory
for k, v in data.items():
    data_addr[k] = cnt
    mem[cnt] = v
    cnt += 1

data_addr.update(labels)

# Replace variables
for i, b in enumerate(mem):
    if str(b).startswith("%"):
        mem[i] = data_addr[b.lstrip("%")]

print ' '.join(['%02x' % b for b in mem])
