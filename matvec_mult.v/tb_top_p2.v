`timescale 1ns/1ns

module tb_top_p2;
  reg clk;
  reg rst_n;
  reg start;
  reg signed [127:0] x_in;
  wire done;

  // Cac mang du lieu tam
  reg signed [15:0] mem_a_tmp[0:7][0:7];
  reg signed [15:0] mem_x[0:7];

  top_p2 dut_p2 (
    .clk   ( clk   ),
    .rst_n ( rst_n ),
    .start ( start ),
    .x_in  ( x_in  ),
    .done  ( done  )
  );

  // 1. Tao tin hieu xung nhip
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  integer seed;
  integer i;
  integer j;
  integer k;
  
  initial begin
    // Khoi tao
    rst_n = 0;
    start = 0;
    seed  = 123;
    j     = 0;
    k     = 0;
    x_in      = $random(seed);

    #20; rst_n = 1;
    #10;

    for (i = 0; i < 8; i = i + 1) begin
      for (j = 0; j < 8; j = j + 1) begin
        mem_a_tmp[i][j] = $random(seed);
        dut_p2.sram_model_inst.mem[i] = mem_a_tmp[i][j];
      end
    end

    for (k = 0; k < 8; k = k + 1) begin
      
    end
  end
endmodule