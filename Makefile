computer:
	iverilog -o computer \
		alu.v \
		cpu.v \
		cpu_control.v \
		library/clock.v \
		library/counter.v \
		library/ram.v \
		library/register.v \
		library/tristate_buffer.v \
		machine.v

run_computer: computer
	vvp -n computer

clean_computer:
	rm -rf computer
