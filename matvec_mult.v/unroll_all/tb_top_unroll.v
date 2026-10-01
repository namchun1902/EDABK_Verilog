`timescale 1ns / 1ps

module tb_top_unroll;

  localparam CLK = 10;

  reg                 clk, rst_n, start;
  reg signed [1023:0] A_in;
  reg signed [127:0]  x_in;
  wire                done;
  wire signed [279:0] y_ram;
  integer i, r, c;

  top_unroll dut (
    .clk   ( clk   ),
    .rst_n ( rst_n ),
    .start ( start ),
    .A_in  ( A_in  ),
    .x_in  ( x_in  ),
    .done  ( done  ),
    .y_ram ( y_ram )
  );

  // Clock
  initial begin clk = 0; forever #(CLK/2) clk = ~clk; end

  initial begin
    // Reset
    rst_n = 0; start = 0; A_in = 0; x_in = 0;
    #(CLK*3);
    rst_n = 1;
    #CLK;

    // Testcase 1: A = 1 all, x = 1 all => y[i] = 8
    for (r = 0; r < 8; r = r+1)
      for (c = 0; c < 8; c = c+1)
        A_in[(r*8+c)*16 +: 16] = 1;
    for (i = 0; i < 8; i = i+1)
      x_in[i*16 +: 16] = 1;

    @(posedge clk); start <= 1;
    @(posedge clk); start <= 0;
    @(posedge done);
    @(posedge clk);

    $display("=== Test 1: A=1, x=1 ===");
    for (i = 0; i < 8; i = i+1)
      $display("y[%0d] = %0d  (expect 8)", i, $signed(y_ram[i*35 +: 35]));

    // Reset giua 2 test
    rst_n = 0; #(CLK*2); rst_n = 1; #CLK;

    // Testcase 2: A = identity, x = {1,2,...,8} => y[i] = i+1
    A_in = 0;
    for (r = 0; r < 8; r = r+1)
      A_in[(r*8+r)*16 +: 16] = 1;  // duong cheo = 1
    for (i = 0; i < 8; i = i+1)
      x_in[i*16 +: 16] = i + 1;

    @(posedge clk); start <= 1;
    @(posedge clk); start <= 0;
    @(posedge done);
    @(posedge clk);

    $display("=== Test 2: A=I, x={1..8} ===");
    for (i = 0; i < 8; i = i+1)
      $display("y[%0d] = %0d  (expect %0d)", i, $signed(y_ram[i*35 +: 35]), i+1);

    $finish;
  end

endmodule
