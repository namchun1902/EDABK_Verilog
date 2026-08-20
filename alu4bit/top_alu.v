module top_alu (
  // NGÕ VÀO
  input  [3:0] sw_a,       // Toán hạng A
  input  [3:0] sw_b,       // Toán hạng B
  input  [3:0] sw_alu_op,  // Mã chọn phép toán

  // NGÕ RA HIỂN THỊ (RA LED 7 ĐOẠN HEX)
  output [6:0] hex_sign_a,   // LED dấu của A
  output [6:0] hex_val_a,
  output [6:0] hex_sign_b,   // LED dấu của B
  output [6:0] hex_val_b,

  output [6:0] hex3,
  output [6:0] hex_sign_res, // LED dấu kết quả
  output [6:0] hex_chuc,     // LED hàng chục kết quả
  output [6:0] hex_donvi,    // LED hàng đơn vị kết quả

  // CỜ BÁO TRẠNG THÁI TRÀN
  output led_overflow        // Cắm vào LEDG[8]
);
  // Dây trung gian nhận giá trị của result_o
  wire [4:0] res_wire;
  wire [3:0] abs_a;
  wire [3:0] abs_b;

  // Lấy trị tuyệt đối cho 2 đầu vào 4 bit
  // Phép gán liên tục
  assign abs_a = sw_a[3] ? -sw_a : sw_a;
  assign abs_b = sw_b[3] ? -sw_b : sw_b;

  alu4bit topmodule (
    .src1_i     ( sw_a         ),
    .src2_i     ( sw_b         ),
    .alu_op_i   ( sw_alu_op    ),
    .result_o   ( res_wire     ),
    .overflow_o ( led_overflow )
  );

  // Hiển thị dấu cho đầu vào
  seg7_sign a_sign (
    .is_neg ( sw_a[3]    ),
    .seg    ( hex_sign_a )
  );
  seg7_sign b_sign (
    .is_neg ( sw_b[3]    ),
    .seg    ( hex_sign_b )
  );

  // Hiển thị số đầu vào
  hex_to7seg a_val (
    .num     ( abs_a     ),
    .segment ( hex_val_a )
  );
  hex_to7seg b_val (
    .num     ( abs_b      ),
    .segment ( hex_val_b )
  );

  // Hiển thị cho kết quả
  display_result res_dis (
    .alu_res_in ( res_wire     ),
    .hex_chuc   ( hex_chuc     ),
    .hex_donvi  ( hex_donvi    ),
    .hex_sign   ( hex_sign_res )
  );

 // Hiển thị phép toán
  hex_to7seg op_val (
    .num     ( sw_alu_op ),
    .segment ( hex3      )
  );

  //sw_a[3:0]      --> SW[7:4]
  //sw_b[3:0]      --> SW[3:0]
  //led_overflow   --> LEDG[8]
  //sw_alu_op[3:0] --> SW[17:14]

  // hex_sign_a --> hex7
  // hex_val_a  --> hex6
  // hex_sign_b --> hex5
  // hex_val_b  --> hex4

  // hex_sign_res --> hex2
  // hex_chuc     --> hex1
  // hex_donvi    --> hex0

endmodule