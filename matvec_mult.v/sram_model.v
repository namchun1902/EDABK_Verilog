module sram_model (
  input wire               clk,
  input wire        [2:0]  r,
  output reg signed [15:0] data_out
);

  reg signed [15:0] mem [0:7];
  integer i;
  initial begin
    for (i = 0; i < 8; i = i + 1) begin
        mem[i] = i;
    end
  end

  always @(posedge clk) begin
    data_out <= mem[r];
  end

endmodule
