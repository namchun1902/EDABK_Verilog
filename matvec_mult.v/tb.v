`timescale 1ns / 1ns

module tb_top_p2;

  localparam CLK = 10;

  reg clk, rst_n, start;
  reg signed [127:0] x_in;
  wire done;
  integer i;

  top_p2 dut_p2 (
    .clk(clk), .rst_n(rst_n), .start(start), .x_in(x_in), .done(done)
  );

  // Clock
  initial begin clk = 0; forever #(CLK/2) clk = ~clk; end

  initial begin
    // Reset
    rst_n = 0; start = 0; x_in = 0;
    #(CLK*3);
    rst_n = 1;
    #CLK;

    // === Test 1: x = {1,1,1,1,1,1,1,1} ===
    // A[row] = {0,1,2,3,4,5,6,7} (tu SRAM)
    // y[row] = 0+1+2+3+4+5+6+7 = 28
    for (i = 0; i < 8; i = i+1) x_in[(i*16) +: 16] = 1;

    @(posedge clk); start <= 1;
    @(posedge clk); start <= 0;
    @(posedge done);
    @(posedge clk);

    $display("=== Test 1: x = all 1 ===");
    for (i = 0; i < 8; i = i+1)
      $display("y[%0d] = %0d  (expect 28)", i, dut_p2.y_ram[i]);

    // === Test 2: x = {1,2,3,4,5,6,7,8} ===
    // y[row] = 0*1+1*2+2*3+3*4+4*5+5*6+6*7+7*8 = 168
    #(CLK*3);
    rst_n = 0; #(CLK*2); rst_n = 1; #CLK;
    for (i = 0; i < 8; i = i+1) x_in[(i*16) +: 16] = i + 1;

    @(posedge clk); start <= 1;
    @(posedge clk); start <= 0;
    @(posedge done);
    @(posedge clk);

    $display("=== Test 2: x = {1,2,...,8} ===");
    for (i = 0; i < 8; i = i+1)
      $display("y[%0d] = %0d  (expect 168)", i, dut_p2.y_ram[i]);

    $finish;
  end

endmodule