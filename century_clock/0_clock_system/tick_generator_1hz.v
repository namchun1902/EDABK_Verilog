module tick_generator_1hz (
  input      clk,
  input      rst_n,
  output reg tick_1HZ, // Dùng để kích mạch đếm thời gian
  output reg blink_1HZ // Dùng để hiển thị ra LED
);

  localparam MAX_COUNT = 49_999_999;
  localparam HALF_COUNT = 24_999_999;

  reg [25:0] counter_value;
  reg [24:0] blink_counter;

  // Khối tạo xung kích (Pulse)
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      counter_value <= 0;
      tick_1HZ      <= 0;
    end else begin
      if (counter_value == MAX_COUNT) begin
        counter_value <= 0;
        tick_1HZ      <= 1;
      end else begin
        counter_value <= counter_value + 1;
        tick_1HZ      <= 0;
      end
    end
  end

  // Khối nhấp nháy LED
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      blink_counter <= 0;
      blink_1HZ     <= 0;
    end else begin
      if (blink_counter == HALF_COUNT) begin
        blink_counter <= 0;
        blink_1HZ     <= ~blink_1HZ; // Lệnh lật trạng thái (0->1, 1->0)
      end else begin
        blink_counter <= blink_counter + 1;
      end
    end
  end

endmodule