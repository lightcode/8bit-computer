computer:
	iverilog -o computer cpu.v counter.v register.v clock.v alu.v tristate_buffer.v memory.v cpu_control.v

run_computer: computer
	vvp -n computer

clean_computer:
	rm -rf computer
