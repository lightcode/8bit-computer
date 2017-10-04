#!/usr/bin/env python2

import re
import sys

progf = sys.argv[1]

inst = {
    "nop": 0x00,
    "call": 0b00000001,
    "ret": 0b00000010,
    "lda": 0b10000111,
    "out": 0b00000011,
    "in": 0b00000100,
    "hlt": 0b00000101,
    "cmp": 0b00000110,
    "sta": 0b10111000,
    "jmp": 0b00011000,
    "jz": 0b00011001,
    "jnz": 0b00011010,
    "je":  0b00011001,
    "jne": 0b00011010,
    "jc":  0b00011011,
    "jnc": 0b00011100,
    "push": 0b00100000,
    "pop": 0b00101000,
    "add": 0b01000000,
    "sub": 0b01001000,
    "inc": 0b01010000,
    "dec": 0b01011000,
    "and": 0b01100000,
    "or": 0b01101000,
    "xor": 0b01110000,
    "adc": 0b01111000,
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

TEXT, DATA = 0, 1
MEM_SIZE = 256

mem = [0 for _ in range(MEM_SIZE)]
cnt = 0

labels = {}
data = {}
data_addr = {}

def rich_int(v):
    if v.startswith("0x"):
        return int(v, 16)
    elif v.startswith("0b"):
        return int(v, 2)
    else:
        return int(v)

with open(progf) as f:
    for l in f:
        l = re.sub(";.*", "", l)

        l = l.strip()
        if l == "":
            continue

        if l == ".text":
            section = TEXT
        elif l == ".data":
            section = DATA
        else:
            if section == DATA:
                n, v = map(str.strip, l.split("=", 2))
                data[str(n)] = int(v)
            elif section == TEXT:
                kw = l.split()
                if kw[0][-1] == ":":
                    labels[kw[0].rstrip(":")] = cnt
                else:
                    current_inst = kw[0]

                    if current_inst == "ldi":
                        r = reg[kw[1]]
                        kw[0] = (inst[kw[0]] & 0b11111000) | r
                        del kw[1]
                        kw[1] = rich_int(kw[1])
                    elif current_inst in ("push", "pop"):
                        r = reg[kw[1]]
                        kw[0] = (inst[kw[0]] & 0b11111000) | r
                        del kw[1]
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

print ' '.join(['%02x' % int(b) for b in mem])
