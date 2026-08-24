module leap_year_check (
  input  wire [6:0] century, // Hai số đầu
  input  wire [6:0] year,    // Hai số sau
  output wire       is_leap
);
  
  // Check chia hết cho 4
  wire div_by_4 = (year[1:0] == 2'b00);

  // Check chia hết cho 100. Hai số sau bằng 0
  wire div_by_100 = (year == 7'd0);

  // Check chia hết cho 400. Chia hết cho 100 và hai số đầu chia hết cho 4
  wire div_by_400 = div_by_100 && (century[1:0] == 2'b00);

  assign is_leap = div_by_400 || (div_by_4 && !div_by_100);
  
endmodule