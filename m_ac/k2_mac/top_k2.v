module top_k2 (
  input  wire               clk,
  input  wire               rst_n,
  input  wire               start,
  input  wire signed [15:0] sram_data_a,
  input  wire signed [15:0] sram_data_b,

  output wire [5:0]         sram_addr,
  output wire               done,
  output wire signed [39:0] mac_sum
);

  // Dây trung gian
  wire               i_inc;
  wire               i_clr;
  wire               acc_en;
  wire               acc_clr;
  wire               i_last;  // Từ bộ so sánh ra
  wire signed [31:0] p_prod;  // Kết quả ra từ bộ mult

  fsm fsm_inst (
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .start   ( start   ),
    .i_last  ( i_last  ),
    .i_inc   ( i_inc   ),
    .i_clr   ( i_clr   ),
    .acc_en  ( acc_en  ),
    .acc_clr ( acc_clr ),
    .done    ( done    )
  );

  counter counter_inst (
    .clk   ( clk       ),
    .rst_n ( rst_n     ),
    .i_inc ( i_inc     ),
    .i_clr ( i_clr     ),
    .q     ( sram_addr )
  );

  comparator comparator_inst (
    .i      ( sram_addr ),
    .i_last ( i_last    )
  );

  multiplier multiplier_inst (
    .a ( sram_data_a ),
    .b ( sram_data_b ),
    .p ( p_prod      )
  );

  accumulator accumulator_inst (
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .acc_en  ( acc_en  ),
    .acc_clr ( acc_clr ),
    .p       ( p_prod  ),
    .sum     ( mac_sum )
  );

endmodule