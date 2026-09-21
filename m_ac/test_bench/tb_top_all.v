`timescale 1ns/1ns

module tb_top_all;
  // C�c t�n hi?u
  reg clk;
  reg rst_n;
  reg start;

  // C�c output c?a K2
  wire [5:0]         addr_k2;
  wire               done_k2;
  wire signed [39:0] sum_k2;

  // C�c output c?a K3
  wire               done_k3;
  wire signed [39:0] sum_k3;

  // C�c output c?a K4
  wire        [5:0]  addr_k4;
  wire               done_k4;
  wire signed [39:0] sum_k4;

  // C�c m?ng t?m th?i �? l�u d? li?u
  reg signed [15:0] mem_a_tmp [0:63];
  reg signed [15:0] mem_b_tmp [0:63];

  top_k2 dut_k2 (
    .clk       ( clk     ),
    .rst_n     ( rst_n   ),
    .start     ( start   ),
    .sram_addr ( addr_k2 ),
    .done      ( done_k2 ),
    .mac_sum   ( sum_k2  )
  );

  top_k3 dut_k3 (
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .start   ( start   ),
    .done    ( done_k3 ),
    .mac_sum ( sum_k3  )
  );

  top_k4 dut_k4 (
    .clk       ( clk     ),
    .rst_n     ( rst_n   ),
    .start     ( start   ),
    .sram_addr ( addr_k4 ),
    .done      ( done_k4 ),
    .mac_sum   ( sum_k4  )
  );

  // 1. T?o xung nh?p
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // 2. Test tr�n 1000 vector
  integer seed;
  integer test_idx; // 1000
  integer i;

  initial begin
    // Kh?i t?o
    rst_n = 0;
    start = 0;
    seed  = 123;

    #20 rst_n = 1;
    #10;

    for (test_idx = 1; test_idx <= 1000; test_idx = test_idx + 1) begin
      // A. B�m d? li?u ng?u nhi�n
      for (i = 0; i < 64; i = i + 1) begin
        mem_a_tmp[i] = $random(seed);
        mem_b_tmp[i] = $random(seed);

        dut_k2.sram_model_a.mem[i] = mem_a_tmp[i];
        dut_k2.sram_model_b.mem[i] = mem_b_tmp[i];

        dut_k4.sram_model_a.mem[i] = mem_a_tmp[i];
        dut_k4.sram_model_b.mem[i] = mem_b_tmp[i];
      end

      // N?p ri�ng cho K3 (T�ch 64 ph?n t? v�o 4 Bank)
      for (i = 0; i < 16; i = i + 1) begin
        // Bank 0
        dut_k3.sram_model_ai.mem[i]  = mem_a_tmp[i*4 + 0];
        dut_k3.sram_model_bi.mem[i]  = mem_b_tmp[i*4 + 0];
        // Bank 1
        dut_k3.sram_model_ai1.mem[i] = mem_a_tmp[i*4 + 1];
        dut_k3.sram_model_bi1.mem[i] = mem_b_tmp[i*4 + 1];
        // Bank 2
        dut_k3.sram_model_ai2.mem[i] = mem_a_tmp[i*4 + 2];
        dut_k3.sram_model_bi2.mem[i] = mem_b_tmp[i*4 + 2];
        // Bank 3
        dut_k3.sram_model_ai3.mem[i] = mem_a_tmp[i*4 + 3];
        dut_k3.sram_model_bi3.mem[i] = mem_b_tmp[i*4 + 3];
      end
      
      // B. Cho m?ch ch?y
      @(negedge clk);
      start = 1;
      $display("B?t �?u k�ch ho?t Test %d...", test_idx);
      @(negedge clk);
      start = 0;

      // C. �?i cho m?ch ch?y xong
      wait (done_k2 == 1'b1);
      @(negedge clk);

      // D. So s�nh self-check
      if ((sum_k2 == sum_k3) && (sum_k3 == sum_k4)) begin
        if (test_idx % 100 == 0) begin
          $display("Test %4d: PASS | Ket qua = %d", test_idx, sum_k2);
        end

        $display(" - Tong K2 (�a chu ky): %d", sum_k2);
        $display(" - Tong K3 (Chia Bank): %d", sum_k3);
        $display(" - Tong K4 (Pipeline) : %d", sum_k4);
      end else begin
        $display("\n[LOI] C�c ki?n tr�c cho k?t qu? kh�c nhau t?i test s? %d!", test_idx);
        $display(" - Tong K2 (�a chu k?): %d", sum_k2);
        $display(" - Tong K3 (Chia Bank): %d", sum_k3);
        $display(" - Tong K4 (Pipeline) : %d", sum_k4);
        $stop;
      end

      #50;
    end

    $display(" CA 3 KIEN TRUC K2, K3, K4 HOAT DONG KHOP NHAU!   ");
    $stop;
    
  end
endmodule