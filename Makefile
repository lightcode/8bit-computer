COMPUTER    = $(wildcard rtl/*.v)
LIBRARIES   = $(wildcard rtl/library/*.v)

computer:
	iverilog -o computer \
		$(COMPUTER) \
		$(LIBRARIES)

run_computer: computer
	vvp -n computer

clean_computer:
	rm -rf computer

view:
	gtkwave cpu.vcd config.gtkw
