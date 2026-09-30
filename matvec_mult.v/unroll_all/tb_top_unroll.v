`timescale 1ns / 1ps

module tb_top_unroll;

  // ========== Tham so ==========
  localparam CLK_PERIOD = 10; // 10ns -> 100MHz

  // ========== Tin hieu ket noi DUT ==========
  reg                clk;
  reg                rst_n;
  reg                start;
  reg signed [1023:0] A_in;
  reg signed [127:0]  x_in;
  wire               done;
  wire signed [279:0] y_ram;

  // ========== DUT ==========
  top_unroll dut (
    .clk   ( clk   ),
    .rst_n ( rst_n ),
    .start ( start ),
    .A_in  ( A_in  ),
    .x_in  ( x_in  ),
    .done  ( done  ),
    .y_ram ( y_ram )
  );

  // ========== Clock ==========
  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  // ========== Bien kiem tra ==========
  integer cycle_count;
  integer pass_count, fail_count;
  integer total_tests;

  // Gia tri ky vong
  reg signed [34:0] y_expected [0:7];

  // Mang tam de tinh toan ky vong
  reg signed [15:0] A_tmp [0:7][0:7];
  reg signed [15:0] x_tmp [0:7];

  // ========== TASK: Reset ==========
  task reset_dut;
    begin
      rst_n = 0;
      start = 0;
      A_in  = 0;
      x_in  = 0;
      #(CLK_PERIOD * 3);
      rst_n = 1;
      #(CLK_PERIOD);
    end
  endtask

  // ========== TASK: Nap A dong deu 1 gia tri ==========
  task load_A_uniform;
    input signed [15:0] val;
    integer r, c;
    begin
      for (r = 0; r < 8; r = r + 1)
        for (c = 0; c < 8; c = c + 1)
          A_in[(r*8 + c)*16 +: 16] = val;
    end
  endtask

  // ========== TASK: Nap x dong deu 1 gia tri ==========
  task load_x_uniform;
    input signed [15:0] val;
    integer k;
    begin
      for (k = 0; k < 8; k = k + 1)
        x_in[k*16 +: 16] = val;
    end
  endtask

  // ========== TASK: Tinh gia tri ky vong bang phan mem ==========
  task compute_expected;
    integer r, c;
    reg signed [34:0] sum;
    reg signed [31:0] product;
    begin
      // Trich A va x tu packed input
      for (r = 0; r < 8; r = r + 1)
        for (c = 0; c < 8; c = c + 1)
          A_tmp[r][c] = A_in[(r*8 + c)*16 +: 16];
      for (c = 0; c < 8; c = c + 1)
        x_tmp[c] = x_in[c*16 +: 16];

      // Tinh y = A * x
      for (r = 0; r < 8; r = r + 1) begin
        sum = 35'sd0;
        for (c = 0; c < 8; c = c + 1) begin
          product = $signed(A_tmp[r][c]) * $signed(x_tmp[c]);
          sum = sum + product;
        end
        y_expected[r] = sum;
      end
    end
  endtask

  // ========== TASK: Chay test va kiem tra ==========
  task run_and_check;
    input [255:0] test_name;
    integer i;
    reg signed [34:0] y_actual;
    reg test_pass;
    begin
      total_tests = total_tests + 1;
      $display("----------------------------------------------------");
      $display("Test %0d: %0s", total_tests, test_name);

      // Tinh ky vong
      compute_expected;

      // Bat dau
      @(posedge clk);
      start <= 1;
      @(posedge clk);
      start <= 0;

      // Dem so chu ky cho den khi done
      cycle_count = 0;
      while (!done) begin
        @(posedge clk);
        cycle_count = cycle_count + 1;
      end

      $display("  So chu ky tu start den done: %0d", cycle_count);

      // So sanh ket qua
      test_pass = 1;
      for (i = 0; i < 8; i = i + 1) begin
        y_actual = y_ram[i*35 +: 35];
        if (y_actual !== y_expected[i]) begin
          $display("  FAIL: y[%0d] = %0d (0x%09h), expected = %0d (0x%09h)",
                   i, y_actual, y_actual, y_expected[i], y_expected[i]);
          test_pass = 0;
        end else begin
          $display("  OK:   y[%0d] = %0d", i, y_actual);
        end
      end

      if (test_pass) begin
        $display("  >> PASS");
        pass_count = pass_count + 1;
      end else begin
        $display("  >> FAIL");
        fail_count = fail_count + 1;
      end

      // Cho 1 chu ky truoc test tiep theo
      #(CLK_PERIOD);
    end
  endtask

  // ========== MAIN TEST ==========
  integer r, c;

  initial begin
    pass_count  = 0;
    fail_count  = 0;
    total_tests = 0;

    $display("====================================================");
    $display("  TESTBENCH: top_unroll (Trai hoan toan 8x8)");
    $display("====================================================");

    // Reset
    reset_dut;

    // ----------------------------------------------------------
    // Test 1: All zeros
    // A = 0, x = 0 => y = 0
    // ----------------------------------------------------------
    load_A_uniform(16'sd0);
    load_x_uniform(16'sd0);
    run_and_check("All zeros");

    // ----------------------------------------------------------
    // Test 2: Identity matrix
    // A = I, x = {1,2,3,4,5,6,7,8} => y = {1,2,3,4,5,6,7,8}
    // ----------------------------------------------------------
    A_in = 0;
    for (r = 0; r < 8; r = r + 1)
      A_in[(r*8 + r)*16 +: 16] = 16'sd1; // Duong cheo = 1
    for (c = 0; c < 8; c = c + 1)
      x_in[c*16 +: 16] = c + 1;          // x = {1,2,...,8}
    run_and_check("Identity matrix");

    // ----------------------------------------------------------
    // Test 3: All ones
    // A = 1, x = 1 => y[r] = 8
    // ----------------------------------------------------------
    load_A_uniform(16'sd1);
    load_x_uniform(16'sd1);
    run_and_check("All ones");

    // ----------------------------------------------------------
    // Test 4: Max positive A, x = 1
    // A = 32767, x = 1 => y[r] = 8 * 32767 = 262136
    // ----------------------------------------------------------
    load_A_uniform(16'sd32767);
    load_x_uniform(16'sd1);
    run_and_check("Max positive A");

    // ----------------------------------------------------------
    // Test 5: Max negative A, x = 1
    // A = -32768, x = 1 => y[r] = 8 * (-32768) = -262144
    // ----------------------------------------------------------
    load_A_uniform(-16'sd32768);
    load_x_uniform(16'sd1);
    run_and_check("Max negative A");

    // ----------------------------------------------------------
    // Test 6: Max positive x Max positive
    // A = 32767, x = 32767 => y[r] = 8 * 32767^2 = 8,589,410,312
    // ----------------------------------------------------------
    load_A_uniform(16'sd32767);
    load_x_uniform(16'sd32767);
    run_and_check("Max pos x Max pos");

    // ----------------------------------------------------------
    // Test 7: Max negative x Max negative
    // A = -32768, x = -32768 => y[r] = 8 * 32768^2 = 8,589,934,592
    // ----------------------------------------------------------
    load_A_uniform(-16'sd32768);
    load_x_uniform(-16'sd32768);
    run_and_check("Max neg x Max neg");

    // ----------------------------------------------------------
    // Test 8: Max positive x Max negative
    // A = 32767, x = -32768 => y[r] = 8 * 32767 * (-32768) = -8,589,672,448
    // ----------------------------------------------------------
    load_A_uniform(16'sd32767);
    load_x_uniform(-16'sd32768);
    run_and_check("Max pos x Max neg");

    // ----------------------------------------------------------
    // Test 9: Mixed signs
    // A[r][c] = r - 3, x = {1,-1,2,-2,3,-3,4,-4}
    // ----------------------------------------------------------
    for (r = 0; r < 8; r = r + 1)
      for (c = 0; c < 8; c = c + 1)
        A_in[(r*8 + c)*16 +: 16] = r - 3;
    x_in[0*16 +: 16] =  16'sd1;
    x_in[1*16 +: 16] = -16'sd1;
    x_in[2*16 +: 16] =  16'sd2;
    x_in[3*16 +: 16] = -16'sd2;
    x_in[4*16 +: 16] =  16'sd3;
    x_in[5*16 +: 16] = -16'sd3;
    x_in[6*16 +: 16] =  16'sd4;
    x_in[7*16 +: 16] = -16'sd4;
    run_and_check("Mixed signs");

    // ----------------------------------------------------------
    // Test 10: Random values
    // ----------------------------------------------------------
    for (r = 0; r < 8; r = r + 1)
      for (c = 0; c < 8; c = c + 1)
        A_in[(r*8 + c)*16 +: 16] = $random;
    for (c = 0; c < 8; c = c + 1)
      x_in[c*16 +: 16] = $random;
    run_and_check("Random values");

    // ========== TONG KET ==========
    $display("====================================================");
    $display("  KET QUA TONG HOP");
    $display("  PASS: %0d / %0d", pass_count, total_tests);
    $display("  FAIL: %0d / %0d", fail_count, total_tests);
    $display("====================================================");

    if (fail_count == 0)
      $display("  >>> ALL TESTS PASSED! <<<");
    else
      $display("  >>> SOME TESTS FAILED! <<<");

    $finish;
  end

endmodule
