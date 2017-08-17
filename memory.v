module memory(
  input wire clk,
  input wire [7:0] addr,
  input wire [7:0] val,
  input wire get,
  input wire set,
  output reg [7:0] out
);

  reg [7:0] data [0:255];

  initial begin
    $readmemh("memory.list", data);
  end

  always @(posedge clk) begin
    if (set) begin
      data[addr] <= val;
      $display("Memory: set %h to %h", addr, val);
    end else if (get) begin
      out <= data[addr];
      $display("Memory: read %h from address %h", data[addr], addr);
    end
  end

endmodule
