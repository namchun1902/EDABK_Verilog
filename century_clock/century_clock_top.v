module century_clock_top (
  // 1. Xung nhịp hệ thống
  input wire clk_50M, 
    
  // 2. Nút bấm vật lý
  input wire key_rst_n,   // Nút Reset
  input wire key_mode,    // Nút chuyển chế độ
  input wire key_inc,     // Nút tăng
  input wire key_dec,     // Nút giảm
  input wire key_rst_num, // Nút reset một cụm số

  // 3. 8 cụm LED 7 thanh
  output wire [6:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);
  // TÍN HIỆU NÚT BẤM
  wire w_btn_mode, w_btn_inc, w_btn_dec, w_btn_rst_num;

  // DÂY XUNG CLOCK
  wire w_tick_1HZ, w_tick_1MIN, w_blink_1HZ;

  // DÂY ĐIỀU KHIỂN TỪ FSM
  wire w_is_editing;
  wire w_set_sec, w_set_min, w_set_hour;
  wire w_set_day, w_set_month, w_set_year, w_set_century;

  // DÂY DỮ LIỆU THỜI GIAN, NGÀY THÁNG
  wire [5:0] w_sec, w_min;
  wire [4:0] w_hour, w_day;
  wire [3:0] w_month;
  wire [6:0] w_year, w_century;
  wire w_tick_1DAY;             // Dây báo qua ngày mới nối từ Time sang Date

  //0. HỆ THỐNG XUNG NHỊP
  tick_generator_1hz tick_gen (
    .clk       ( clk_50M     ),
    .rst_n     ( key_rst_n   ),
    .tick_1HZ  ( w_tick_1HZ  ),
    .blink_1HZ ( w_blink_1HZ )
  );

//1. HỆ THỐNG XỬ LÝ INPUT

  // Xử lý nút Mode
  // Dây trung gian từ debounce sang edge detector
  wire w_debounce_mode;
  debounce debounce_mode (
    .clk        ( clk_50M         ),
    .rst_n      ( key_rst_n       ),
    .button_in  ( key_mode        ),
    .button_out ( w_debounce_mode )
  );
  edge_detector ed_mode (
    .clk       ( clk_50M         ),
    .reset_n   ( key_rst_n       ),
    .btn_in    ( w_debounce_mode ),
    .btn_pulse ( w_btn_mode      )
  );

  // Xử lý nút inc
  wire w_debounce_inc;
  debounce debounce_inc (
    .clk        ( clk_50M         ),
    .rst_n      ( key_rst_n       ),
    .button_in  ( key_inc         ),
    .button_out ( w_debounce_inc  )
  );
  edge_detector ed_inc (
    .clk       ( clk_50M         ),
    .reset_n   ( key_rst_n       ),
    .btn_in    ( w_debounce_inc  ),
    .btn_pulse ( w_btn_inc       )
  );

  // Xử lý nút dec
  wire w_debounce_dec;
  debounce debounce_dec (
    .clk        ( clk_50M         ),
    .rst_n      ( key_rst_n       ),
    .button_in  ( key_dec         ),
    .button_out ( w_debounce_dec  )
  );
  edge_detector ed_dec (
    .clk       ( clk_50M         ),
    .reset_n   ( key_rst_n       ),
    .btn_in    ( w_debounce_dec  ),
    .btn_pulse ( w_btn_dec       )
  );

    // Xử lý nút dec
  wire w_debounce_rst_num;
  debounce debounce_rst_num (
    .clk        ( clk_50M            ),
    .rst_n      ( key_rst_n          ),
    .button_in  ( key_rst_num        ),
    .button_out ( w_debounce_rst_num )
  );
  edge_detector ed_rst_num (
    .clk       ( clk_50M            ),
    .reset_n   ( key_rst_n          ),
    .btn_in    ( w_debounce_rst_num ),
    .btn_pulse ( w_btn_rst_num      )
  );

// 2. Bộ điều khiển FSM
  mode_control mode_fsm (
    .clk         ( clk_50M       ),
    .reset_n     ( key_rst_n     ),
    .btn_mode    ( w_btn_mode    ),
    .set_sec     ( w_set_sec     ),
    .set_min     ( w_set_min     ),
    .set_hour    ( w_set_hour    ),
    .set_day     ( w_set_day     ),
    .set_month   ( w_set_month   ),
    .set_century ( w_set_century ),
    .set_year    ( w_set_year    ),
    .is_editing  ( w_is_editing  )
  );

//3. Bộ xử lý thời gian
  time_core time_inst (
    .clk       ( clk_50M       ),
    .reset_n   ( key_rst_n     ),
    .tick_1HZ  ( w_tick_1HZ    ),
    .set_sec   ( w_set_sec     ),
    .set_min   ( w_set_min     ),
    .set_hour  ( w_set_hour    ),
    .inc       ( w_btn_inc     ),
    .dec       ( w_btn_dec     ),
    .rst_num   ( w_btn_rst_num ),
    .sec       ( w_sec         ),
    .min       ( w_min         ),
    .hour      ( w_hour        ),
    .tick_1DAY ( w_tick_1DAY   ),
    .tick_1MIN ( w_tick_1MIN   )
  );

//4. Bộ xử lý ngày tháng
  date_core date_inst (
    .clk         ( clk_50M       ),
    .reset_n     ( key_rst_n     ),
    .tick_1DAY   ( w_tick_1DAY   ),
    .set_day     ( w_set_day     ),
    .set_month   ( w_set_month   ),
    .set_century ( w_set_century ),
    .set_year    ( w_set_year    ),
    .inc         ( w_btn_inc     ),
    .dec         ( w_btn_dec     ),
    .rst_num     ( w_btn_rst_num ),
    .day         ( w_day         ),
    .month       ( w_month       ),
    .century     ( w_century     ),
    .year        ( w_year        )
  );

//5. Khối điều khiển hiển thị
  display_control inst_display (
    .clk         ( clk_50M       ),
    .rst_n       ( key_rst_n     ),
    .sec         ( w_sec         ),
    .min         ( w_min         ),
    .hour        ( w_hour        ),
    .day         ( w_day         ),
    .month       ( w_month       ),
    .century     ( w_century     ),
    .year        ( w_year        ),
    .is_editing  ( w_is_editing  ),
    .set_sec     ( w_set_sec     ),
    .set_min     ( w_set_min     ),
    .set_hour    ( w_set_hour    ),
    .set_day     ( w_set_day     ),
    .set_month   ( w_set_month   ),
    .set_year    ( w_set_year    ),
    .set_century ( w_set_century ),
    .tick_1MIN   ( w_tick_1MIN   ), // Gắn dây đếm phút vào để lật trang tự động
    .blink_1HZ   ( w_blink_1HZ   ),
    .hex7        ( HEX7          ),
    .hex6        ( HEX6          ),
    .hex5        ( HEX5          ),
    .hex4        ( HEX4          ), 
    .hex3        ( HEX3          ), 
    .hex2        ( HEX2          ),
    .hex1        ( HEX1          ),
    .hex0        ( HEX0          )
  );

endmodule