module display_result (
  input  [4:0] alu_res_in,
  output [6:0] hex_chuc,   // LED hàng chục
  output [6:0] hex_donvi,  // LED hàng đơn vị
  output [6:0] hex_sign    // LED dấu
);

  // Dây trung gian
  wire is_negative;
  wire [4:0] abs_val;
  wire [7:0] bcd_out;

  // Lấy dấu và trị tuyệt đối
  assign is_negative = alu_res_in[4]; 
  assign abs_val     = (is_negative) ? -alu_res_in : alu_res_in;

  // Hiển thị dấu
  assign hex_sign = (is_negative) ? 7'b0111111 : 7'b1111111;

  // Chia 4 bit đầu hàng chục, 4 bit sau hàng đơn vị
  bin2bcd converter (
    .bin ( abs_val ),
    .bcd ( bcd_out )
  );

  // Gọi giải mã sang LED 7 thanh
  // bcd_out[7:4] dịch ra hex_chuc, bcd[3:0] dịch ra hex_donvi

  hex_to7seg hangchuc (
    .num     ( bcd_out[7:4] ),
    .segment ( hex_chuc     )
  );

  hex_to7seg donvi (
    .num     ( bcd_out[3:0] ),
    .segment ( hex_donvi    )
  );
endmodule