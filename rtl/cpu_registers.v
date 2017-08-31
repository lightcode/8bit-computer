module cpu_registers(
  input wire clk,
  input wire [7:0] data_in,
  input wire [2:0] sel,
  input wire enable_write,
  input wire output_enable,
  output wire [7:0] data_out,
  output wire [7:0] rega,
  output wire [7:0] regb
);

  reg [7:0] registers[2:0];

  always @ (posedge clk) begin
    if (enable_write)
      registers[sel] = data_in;
  end

  assign data_out = (output_enable) ? registers[sel] : 'bz;
  assign rega = registers[0];
  assign regb = registers[1];

endmodule
