module test;

  reg [7:0] in = 15;

  /* Make a reset that pulses once. */
  reg reset = 0;
  reg oc = 1;

  initial begin
     # 17 reset = 1;
     # 10  in = 10;
     # 10  oc = 0;
     # 10  oc = 1;
     # 100 $stop;
  end

  /* Make a regular pulsing clock. */
  reg clk = 0;
  always #5 clk = !clk;

  wire [7:0] value;
  tristate_register r1 (in, oc, clk, reset, value);

  initial
     $monitor("At time %t, value = %h (%0d), outctrl = %d",
              $time, value, value, oc);
endmodule // test
