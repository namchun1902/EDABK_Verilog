// Trong một module khác, ví dụ top module
// Giả sử CPU_CLK là clock 100MHz từ PLL

// Tạo một tín hiệu enable nháy mỗi giây một lần
clock_enable_generator #(
  .INPUT_FREQ(100_000_000), // Tần số clock hệ thống
  .OUTPUT_FREQ(1)          // Tần số mong muốn của enable
) led_en_gen (
  .clk(CPU_CLK),
  .rst_n(rst_n),
  .enable(tick_1hz)
);

reg [7:0] led_counter;

// Logic chạy ở tần số chậm, nhưng vẫn được clock bởi clock hệ thống
always @(posedge CPU_CLK or negedge rst_n) begin
  if (!rst_n) begin
    led_counter <= 0;
  end else begin
    // Chỉ cập nhật bộ đếm khi có xung 'tick_1hz'
    if (tick_1hz) begin
      led_counter <= led_counter + 1;
    end
  end
end
