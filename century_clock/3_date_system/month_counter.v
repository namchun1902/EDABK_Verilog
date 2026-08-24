// Đếm 1 đến tháng 12
module month_counter (
  input            clk,
  input            reset_n,
  input            set,
  input            tick_up,  // Cờ tự đếm
  input            inc,
  input            dec,
  input            rst_num,
  output reg [3:0] month,    // 12 tháng nên 4 bit
  output wire      ena_out   // Báo hết tháng, qua năm
);

  localparam MAX_month = 12;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      month <= 4'd1;
    end else begin
      if (set) begin
        if      (rst_num) month <= 4'd1;
        else if (inc)     month <= (month == MAX_month) ? 4'd1 : (month + 4'd1);
        else if (dec)     month <= (month == 4'd1) ? MAX_month : (month - 4'd1);
        else              month <= month;
      end else begin
        if (tick_up) begin
          if (month == MAX_month) month <= 4'd1;
          else                    month <= month + 4'd1;
        end else begin
          month <= month;
        end
      end
    end
  end

  assign ena_out = (!set) && tick_up && (month == MAX_month);
endmodule