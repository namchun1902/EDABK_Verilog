module day_in_month (
  input wire [3:0] month,   // Ngõ ra khối month_counter
  input wire       is_leap, // Ngõ ra khối leap_year_check
  output reg [4:0] max_day  // Số ngày của tháng
);

  always @(*) begin
    case (month)
      4'd1, 4'd3, 4'd5, 4'd7, 4'd8, 4'd10, 4'd12: max_day = 5'd31;
      4'd4, 4'd6, 4'd9, 4'd11:                    max_day = 5'd30;
      4'd2: if (is_leap) begin
              max_day = 5'd29;
            end else begin
              max_day = 5'd28;
            end
      default: max_day = 5'd31;
    endcase
  end
endmodule