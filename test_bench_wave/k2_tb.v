'timescale 1ns/1ns

module tb_top_all;
  // Các tín hiệu
  reg clk;
  reg rst_n;
  reg start;

  // Các output của K2
  wire [5:0]         addr_k2;
  wire               done_k2;
  wire signed [39:0] sum_k2;

  // Các output của K3
  wire               done_k3;
  wire signed [39:0] sum_k3;

  // Các output của K4
  wire [5:0]         addr_k4;
  wire               done_k4;
  wire signed [39:0] sum_k4;

  // Các mảng tạm thời để lưu dữ liệu
  reg signed [16:0] mem_a_tmp [0:63];
  reg signed [16:0] mem_b_tmp [0:63];

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

  // 1. Tạo xung nhịp
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // 2. Test trên 1000 vector
  integer seed;
  integer test_idx; // 1000
  integer i;

  initial begin
    // Khởi tạo
    rst_n = 0;
    start = 0;
    seed  = 123;

    #20 rst_n = 1;
    #10;

    for (test_idx = 1; test_idx <= 1000; test_idx = test_idx + 1) begin
      // A. Bơm dữ liệu ngẫu nhiên
      for (i = 0; i < 64; i = i + 1) begin
        mem_a_tmp[i] = $random(seed);
        mem_b_tmp[i] = $random(seed);

        dut_k2.sram_model_a.mem[i] = mem_a_tmp[i];
        dut_k2.sram_model_b.mem[i] = mem_b_tmp[i];

        dut_k4.sram_model_a.mem[i] = mem_a_tmp[i];
        dut_k4.sram_model_b.mem[i] = mem_b_tmp[i];
      end

      // Nạp riêng cho K3 (Tách 64 phần tử vào 4 Bank)
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
      
      // B. Cho mạch chạy
      @(negedge clk);
      start = 1;
      @(negedge clk);
      start = 0;

      // C. Đợi cho mạch chạy xong
      wait (done_k2 == 1'b1 && done_k3 == 1'b1 && done_k4 == 1'b1);
      @(negedge clk);

      // D. So sánh self-check
      if ((sum_k2 == sum_k3) && (sum_k3 == sum_k4)) begin
        if (test_idx % 100 == 0) begin
          $display("Test %4d: PASS | Kết quả = %d", test_idx, sum_k2);
        end else begin
          $display("\n[LỖI] Các kiến trúc cho kết quả khác nhau tại test số %d!", test_idx);
          $display(" - Tổng K2 (Đa chu kỳ): %d", sum_k2);
          $display(" - Tổng K3 (Chia Bank): %d", sum_k3);
          $display(" - Tổng K4 (Pipeline) : %d", sum_k4);
          $stop;
        end
      end

      #50
    end

    $display(" CẢ 3 KIẾN TRÚC K2, K3, K4 HOẠT ĐỘNG KHỚP NHAU!   ");
    $stop;
    
  end
endmodule