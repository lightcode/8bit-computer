FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && \
    apt-get install -y \
        python3 \
        make \
        iverilog \
        gtkwave \
        build-essential \
        git \
        bash \
    && rm -rf /var/lib/apt/lists/*

# Ensure `python` points to python3
RUN ln -sf /usr/bin/python3 /usr/bin/python

# Working directory
WORKDIR /opt/8bit-computer

# Copy project files
COPY . .

# Make assembler executable
RUN chmod +x asm/asm.py

# Start interactive shell
CMD ["/bin/bash"]
