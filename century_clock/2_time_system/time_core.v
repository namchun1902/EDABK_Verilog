// Nối dây các khối đếm thời gian

module time_core (
  input clk,
  input reset_n,
  input tick_1HZ,

  input set_sec,
  input set_min,
  input set_hour,
  input inc,
  input dec,
  input rst_num,

  // Ngõ ra dữ liệu
  output wire [5:0] sec,
  output wire [5:0] min,
  output wire [4:0] hour,

  // Cờ báo qua ngày
  output wire tick_1DAY,
  output wire tick_1MIN
);

  // Dây trung gian
  wire w_tick_1HOUR;

  // Tạo khối giây
  counter_60 inst_second (
    .clk     ( clk           ),
    .reset_n ( reset_n       ),
    .set     ( set_sec       ),
    .tick_up ( tick_1HZ      ),
    .inc     ( 1'b0          ), // Không tăng giây được
    .dec     ( 1'b0          ), // Không giảm giây được
    .rst_num ( rst_num | inc ), // Bấm tăng hoặc reset đều reset
    .val     ( sec           ),
    .ena_out ( tick_1MIN   )
  );

  // Tạo khối phút
  counter_60 inst_minute (
    .clk     ( clk          ),
    .reset_n ( reset_n      ),
    .set     ( set_min      ),
    .tick_up ( tick_1MIN  ),
    .inc     ( inc          ),
    .dec     ( dec          ),
    .rst_num ( rst_num      ),
    .val     ( min          ),
    .ena_out ( w_tick_1HOUR )
  );

  // Tạo khối giờ
  counter_24 inst_hour (
    .clk     ( clk          ),
    .reset_n ( reset_n      ),
    .set     ( set_hour     ),
    .tick_up ( w_tick_1HOUR ),
    .inc     ( inc          ),
    .dec     ( dec          ),
    .rst_num ( rst_num      ),
    .hour    ( hour         ),
    .ena_out ( tick_1DAY    )
  );

endmodule