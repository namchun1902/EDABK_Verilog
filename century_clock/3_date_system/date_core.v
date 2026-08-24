// Nối dây khối ngày tháng năm

module date_core (
  input clk,
  input reset_n,
  input tick_1DAY,

  input set_day,
  input set_month,
  input set_century,
  input set_year,
  input inc,
  input dec,
  input rst_num,

  // Ngõ ra dữ liệu
  output wire [4:0] day,
  output wire [3:0] month,
  output wire [6:0] century,
  output wire [6:0] year
);

  // Dây trung gian
  wire       w_tick_1MONTH;
  wire       w_tick_1YEAR;
  wire       w_is_leap;
  wire [4:0] w_max_day;

  // Đếm tháng
  month_counter inst_month (
    .clk     ( clk          ),
    .reset_n ( reset_n      ),
    .set     ( set_month    ),
    .tick_up ( w_tick_1MONTH    ),
    .inc     ( inc          ),
    .dec     ( dec          ),
    .rst_num ( rst_num      ),
    .month   ( month        ),
    .ena_out ( w_tick_1YEAR)
  );

  // Đếm năm
  year_counter inst_year (
    .clk         ( clk                    ),
    .reset_n     ( reset_n                ),
    .set         ( set_century | set_year ),
    .tick_up     ( w_tick_1YEAR           ),
    .inc         ( inc                    ),
    .dec         ( dec                    ),
    .rst_num     ( rst_num                ),
    .set_century ( set_century            ),
    .set_year    ( set_year               ),
    .century     ( century                ),
    .year        ( year                   )
  );

  // Xét năm nhuận
  leap_year_check leap_year (
    .century ( century   ),
    .year    ( year      ),
    .is_leap ( w_is_leap )
  );

  // Xét số ngày trong tháng
  day_in_month dim (
    .month   ( month     ),
    .is_leap ( w_is_leap ),
    .max_day ( w_max_day )
  );

  // Đếm ngày
  day_counter inst_day (
    .clk     ( clk           ),
    .reset_n ( reset_n       ),
    .set     ( set_day       ),
    .tick_up ( tick_1DAY     ),
    .inc     ( inc           ),
    .dec     ( dec           ),
    .rst_num ( rst_num       ),
    .max_day ( w_max_day     ),
    .day     ( day           ),
    .ena_out ( w_tick_1MONTH )
  );
endmodule