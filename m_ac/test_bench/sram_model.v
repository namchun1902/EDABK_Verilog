module sram_model #(
  parameter DATA_WIDTH = 16,
  parameter ADDR_WIDTH = 6
) (
  input wire                         clk,
  input wire        [ADDR_WIDTH-1:0] addr,
  output reg signed [DATA_WIDTH-1:0] data_out
);

  // Memory array
  // Ví dụ 1<<6 = 64
  reg signed [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
  integer i;
  initial begin
    for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin
        mem[i] = i;
    end
  end

  always @(posedge clk) begin
    data_out <= mem[addr];
  end

endmodule
  // dut_k2.sram_model_inst[1].mem[i] = mem_a_tmp[i];