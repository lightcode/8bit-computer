#!/usr/bin/env python2

instructions = {
    "0000 0000": "NOP",
    "0000 0001": "CALL",
    "0000 0010": "RET",
    "0000 0011": "OUT",
    "0000 0100": "IN",
    "0000 0101": "HLT",
    "0000 0110": "CMP",

    "0001 1000": "JMP",
    "0001 1001": "JZ",
    "0001 1010": "JNZ",
    "0001 1011": "JC",
    "0001 1100": "JNC",

    "0100 0000": "ADD",
    "0100 1000": "SUB",
    "0101 0000": "INC",
    "0101 1000": "DEC",
    "0110 0000": "AND",
    "0110 1000": "OR",
    "0111 0000": "XOR",
    "0111 1000": "ADC"
}

regs = {
    "000": "A",
    "001": "B",
    "010": "C",
    "011": "D",
    "100": "E",
    "101": "F",
    "110": "G"
}

for k, v in regs.items():
    instructions["0001 0" + k] = "LDI " + v
    instructions["0010 0" + k] = "PUSH " + v
    instructions["0010 1" + k] = "POP " + v

for k1, v1 in regs.items():
    for k2, v2 in regs.items():
        if k1 == k2:
            txt = "invalid"
        else:
            txt = " ".join((v1, v2))

        instructions[" ".join(("10", k1, k2))] = "MOV " + txt


for k, v in regs.items():
    instructions["10 111 %s" % k] = "MOV M %s" % v
    instructions["10 %s 111" % k] = "MOV %s M" % v

for k, v in instructions.items():
    print k.replace(" ", ""), v
