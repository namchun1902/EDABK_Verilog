module day_counter (
  input            clk,
  input            reset_n,
  input            set,
  input            tick_up,
  input            inc,
  input            dec,
  input            rst_num,
  input      [4:0] max_day,  // Số ngày lấy từ module day_in_month
  output reg [4:0] day,      // Tối đa 31 ngày
  output wire      ena_out   // Báo hết ngày, qua tháng
);

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      day <= 5'd1;
    end else begin
      if (set) begin
        if      (rst_num) day <= 5'd1;
        else if (inc)     day <= (day >=  max_day) ? 5'd1 : (day + 5'd1);
        else if (dec)     day <= (day == 5'd1)     ? max_day : (day - 5'd1);
        else              day <= day;
      end else begin
        if (tick_up) begin
          if (day >= max_day) day <= 5'd1;
          else                day <= day + 5'd1;
        end else begin
          day <= day;
        end
      end
    end
  end

  assign ena_out = (!set) && tick_up && (day >= max_day);
  // Lớn hơn hoặc bằng max_day phòng chuyển tháng 1 sang tháng 2 (31 != 28)
endmodule