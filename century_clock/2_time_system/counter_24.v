// Đếm giờ
module counter_24 (
  input            clk,
  input            reset_n,
  input            set,
  input            tick_up,
  input            inc,
  input            dec,
  input            rst_num, // Reset mỗi số này-
  output reg [4:0] hour,
  output wire      ena_out // Tín hiệu báo qua ngày
);
  localparam MAX_HOUR = 23;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      hour <= 5'd0;
    end else begin
      if (set) begin
        if      (rst_num) hour <= 5'd0;
        else if (inc)     hour <= (hour == MAX_HOUR) ? 5'd0 : (hour + 5'd1);
        else if (dec)     hour <= (hour == 5'd0) ? MAX_HOUR : (hour - 5'd1);
        else              hour <= hour;
      end else begin
        if (tick_up) begin
          if (hour == MAX_HOUR) hour <= 5'd0;
          else                hour <= hour + 5'd1;
        end else begin
          hour <= hour;
        end
      end
    end
  end

  assign ena_out = (!set) && tick_up && (hour ==  MAX_HOUR); // Tràn khi không chỉnh

endmodule