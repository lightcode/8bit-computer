#!/usr/bin/env python2

import sys

progf = sys.argv[1]

inst = ["nop", "lda", "add", "out", "jmp", "hlt", "sub", "jez", "sta", "jnz"]

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
                    mem[cnt] = inst.index(kw[0])
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
