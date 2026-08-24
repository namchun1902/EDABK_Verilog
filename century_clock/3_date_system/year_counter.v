module year_counter (
  input            clk,
  input            reset_n,
  input            set,
  input            tick_up,      // Cờ tự đếm từ month_counter
  input            inc,
  input            dec,
  input            rst_num,
  input            set_century,  // Chỉnh cụm 2 số đầu của năm
  input            set_year,     // Chỉnh cụm 2 số sua của năm
  output reg [6:0] century,
  output reg [6:0] year
);

  localparam MAX_YEAR = 99;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      century <= 7'd20;
      year    <= 7'd0;
    end else begin
      // Chỉnh tay
      if (set) begin
        // Chỉnh 2 số đầu
        if (set_century) begin
          if      (rst_num) century <= 7'd0;
          else if (inc)     century <= (century == MAX_YEAR) ? 7'd0 : (century + 7'd1);
          else if (dec)     century <= (century == 7'd0)     ? MAX_YEAR : (century - 7'd1);
          else              century <= century;
        // Chỉnh 2 số sau
        end else if (set_year) begin
          if      (rst_num) year <= 7'd0;
          else if (inc)     year <= (year == MAX_YEAR) ? 7'd0 : (year + 7'd1);
          else if (dec)     year <= (year == 7'd0)     ? MAX_YEAR : (year - 7'd1);
          else              year <= year;
        end else begin
          century <= century;
          year    <= year;
        end

      // Đếm
      end else begin
        if (tick_up) begin
          if (year == MAX_YEAR && century == MAX_YEAR) begin
            century <= 7'd0;
            year    <= 7'd0;
          end else if (year == MAX_YEAR) begin
            year    <= 7'd0;
            century <= century + 7'd1;
          end else begin
            year    <= year + 7'd1;
          end
        end else begin
          century <= century;
          year    <= year;
        end
      end
    end
  end
endmodule