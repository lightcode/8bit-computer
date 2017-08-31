#!/usr/bin/env python2

import sys

progf = sys.argv[1]

inst = {
    "nop": 0x00,
    "lda": 0x01,
    "out": 0x03,
    "jmp": 0x04,
    "hlt": 0x05,
    "jez": 0x07,
    "sta": 0x08,
    "jnz": 0x09,
    "add": 0b01000000,
    "sub": 0b01001000,
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
                    mem[cnt] = inst[kw[0]]
                    cnt += 1
                    for a in kw[1:]:
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
