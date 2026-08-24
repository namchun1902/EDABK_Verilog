// Đếm giây, phút
module counter_60 (
  input            clk,
  input            reset_n,
  input            set,     // Tín hiệu chỉnh hay không
  input            tick_up, // Cờ tự động đếm, 1Hz từ bộ chia tần
  input            inc,     // Tín hiệu tăng
  input            dec,     // Tín hiệu giảm
  input            rst_num, // Reset mỗi số này
  output reg [5:0] val,
  output wire      ena_out  // Cờ tràn
);
  localparam MAX_VAL = 59;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      val <= 6'd0;
    end else begin
      if (set) begin
        if      (rst_num) val <= 6'd0;
        else if (inc)     val <= (val == MAX_VAL) ? 6'd0 : (val + 6'd1);
        else if (dec)     val <= (val == 6'd0) ? MAX_VAL : (val - 6'd1);
        else              val <= val;
      end else begin
        if (tick_up) begin
          if (val == MAX_VAL) val <= 6'd0;
          else                val <= val + 6'd1;
        end else begin
          val <= val;
        end
      end
    end
  end

  assign ena_out = (!set) && tick_up && (val == MAX_VAL); // Tràn khi không chỉnh

endmodule