#!/bin/bash

for file in tests/*.asm; do
    echo "Running $file"
    python3 asm/asm.py "$file"
done
