module display_control (
  // Tín hiệu của hệ thống
  input wire clk,
  input wire rst_n,
 
  // Dữ liệu thời gian
  input wire [5:0] sec,
  input wire [5:0] min,
  input wire [4:0] hour,

  // Dữ liệu ngày tháng
  input wire [4:0] day,
  input wire [3:0] month,
  input wire [6:0] century,
  input wire [6:0] year,

  // Tín hiệu từ khối điều khiển FSM
  input wire is_editing,
  input wire set_sec, set_min, set_hour, set_day, set_month, set_year, set_century,

  //
  input wire tick_1MIN,

  // Xung nhấp nháy từ khối tick_gen
  input wire blink_1HZ,

  // Đầu ra 8 con LED 7 thanh
  output wire [6:0] hex7, hex6, hex5, hex4, hex3, hex2, hex1, hex0
);

  // auto_page = (0: Time | 1: Date)
  reg auto_page;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      auto_page <= 1'b0;
    end else begin
      if (tick_1MIN) begin
        auto_page <= ~auto_page; 
      end
    end
  end

  //1. Logic hiển thị màn hình
  // current_page = ( 1: Hiển thị Date | 0: Hiển thị Time)
  wire displaying_date;
  assign displaying_date = (set_day | set_month | set_year | set_century);

  wire current_page;
  assign current_page = is_editing ? displaying_date : auto_page; 

  //2. Cho dữ liệu vào 4 cụm (cặp) LED
  wire [13:0] val3, val2, val1, val0;
  // (HEX7, HEX6)
  assign val3 = current_page ? {9'd0, day}     : {9'd0, hour};
  // (HEX5, HEX4)
  assign val2 = current_page ? {10'd0, month}  : {8'd0, min};
  // (HEX3, HEX2)
  assign val1 = current_page ? {7'd0, century} : 14'd0;
  // (HEX1, HEX0)
  assign val0 = current_page ? {7'd0, year}    : {8'd0, sec};

  //3. Chuyển từ Binary sang BCD
  wire [15:0] bcd_3, bcd_2, bcd_1, bcd_0;
  bin2bcd bcd3 (
    .bin ( val3  ),
    .bcd ( bcd_3 )
  );
  bin2bcd bcd2 (
    .bin ( val2  ),
    .bcd ( bcd_2 )
  );
  bin2bcd bcd1 (
    .bin ( val1  ),
    .bcd ( bcd_1 )
  );
  bin2bcd bcd0 (
    .bin ( val0  ),
    .bcd ( bcd_0 )
  );

  //4. Logic nhấp nháy đèn
  // Có cờ set --> nhấp nháy
  wire ena_3 = current_page ? (set_day   ? blink_1HZ : 1'b1) : (set_hour ? blink_1HZ : 1'b1);
  wire ena_2 = current_page ? (set_month ? blink_1HZ : 1'b1) : (set_min  ? blink_1HZ : 1'b1);
  wire ena_1 = current_page ? (set_century   ? blink_1HZ : 1'b1) : 1'b0;
  wire ena_0 = current_page ? (set_year  ? blink_1HZ : 1'b1) : (set_sec  ? blink_1HZ : 1'b1);
    
  //5. Giải mã ra LED 7 thanh
  // Cụm 3 (HEX7, HEX6)
  hex_to7seg inst_hex7 (.ena(ena_3), .num(bcd_3[7:4]), .segment(hex7));
  hex_to7seg inst_hex6 (.ena(ena_3), .num(bcd_3[3:0]), .segment(hex6));

  // Cụm 2 (HEX5, HEX4)
  hex_to7seg inst_hex5 (.ena(ena_2), .num(bcd_2[7:4]), .segment(hex5));
  hex_to7seg inst_hex4 (.ena(ena_2), .num(bcd_2[3:0]), .segment(hex4));

  // Cụm 1 (HEX3, HEX2)
  hex_to7seg inst_hex3 (.ena(ena_1), .num(bcd_1[7:4]), .segment(hex3));
  hex_to7seg inst_hex2 (.ena(ena_1), .num(bcd_1[3:0]), .segment(hex2));

  // Cụm 0 (HEX1, HEX0)
  hex_to7seg inst_hex1 (.ena(ena_0), .num(bcd_0[7:4]), .segment(hex1));
  hex_to7seg inst_hex0 (.ena(ena_0), .num(bcd_0[3:0]), .segment(hex0));

endmodule