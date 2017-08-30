COMPUTER    = $(wildcard rtl/*.v)
LIBRARIES   = $(wildcard rtl/library/*.v)

computer:
	iverilog -o computer \
		$(COMPUTER) \
		$(LIBRARIES) \
		rtl/tb/machine_tb.v

run_computer: computer
	vvp -n computer

clean_computer:
	rm -rf computer

view:
	gtkwave machine.vcd gtkwave/config.gtkw
