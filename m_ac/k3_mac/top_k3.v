module top_k3 (
  input wire clk,
  input wire rst_n,
  input wire start,

  output wire               done,
  output wire signed [39:0] mac_sum
);

  // Chia bank
  wire signed [15:0] sram_data_a [0:3];
  wire signed [15:0] sram_data_b [0:3];

  // Dây ra từ bộ đếm
  wire [3:0] index;
  
  // Kết quả của 4 bộ mult
  wire signed [31:0] p0;
  wire signed [31:0] p1;
  wire signed [31:0] p2;
  wire signed [31:0] p3;

  // Dây trung gian
  wire               i_inc;
  wire               i_clr;
  wire               acc_en;
  wire               acc_clr;
  wire               i_last;  // Từ bộ so sánh ra

  // Kết quả ra từ cây cộng 3 tầng
  wire signed [33:0] partial_sum;

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

  counter #(
    .WIDTH(4)
  ) counter_inst (
    .clk   ( clk   ),
    .rst_n ( rst_n ),
    .i_inc ( i_inc ),
    .i_clr ( i_clr ),
    .q     ( index )
  );

  comparator #(
    .N(16)
  ) comparator_inst (
    .i      ( index  ),
    .i_last ( i_last )
  );

  // Bốn bộ nhân
  multiplier multiplier_inst0 (
    .a ( sram_data_a[0] ),
    .b ( sram_data_b[0] ),
    .p ( p0             )
  );

  multiplier multiplier_inst1 (
    .a ( sram_data_a[1] ),
    .b ( sram_data_b[1] ),
    .p ( p1             )
  );

  multiplier multiplier_inst2 (
    .a ( sram_data_a[2] ),
    .b ( sram_data_b[2] ),
    .p ( p2             )
  );

  multiplier multiplier_inst3 (
    .a ( sram_data_a[3] ),
    .b ( sram_data_b[3] ),
    .p ( p3             )
  );

  // Cây cộng
  adder_tree adder_tree_inst (
    .p0          ( p0          ),
    .p1          ( p1          ),
    .p2          ( p2          ),
    .p3          ( p3          ),
    .partial_sum ( partial_sum )
  );

  // ACC
  accumulator #(
    .P_WIDTH   (34),
    .SUM_WIDTH (40)
  ) accumulator_inst (
    .clk     ( clk         ),
    .rst_n   ( rst_n       ),
    .acc_en  ( acc_en      ),
    .acc_clr ( acc_clr     ),
    .p       ( partial_sum ),
    .sum     ( mac_sum     )
  );

  // Nạp dữ liệu vào sram mất 1 chu kỳ
  // i
  sram_model #(
    .ADDR_WIDTH (4)
  ) sram_model_ai (
    .clk      ( clk            ),
    .addr     ( index         ),
    .data_out ( sram_data_a[0] )
  ); 
  sram_model #(
    .ADDR_WIDTH (4)
  ) sram_model_bi (
    .clk      ( clk            ),
    .addr     ( index         ),
    .data_out ( sram_data_b[0] )
  ); 

  // i+1
  sram_model #(
    .ADDR_WIDTH (4)
  ) sram_model_ai1 (
    .clk      ( clk            ),
    .addr     ( index         ),
    .data_out ( sram_data_a[1] )
  ); 
  sram_model #(
    .ADDR_WIDTH (4)
  ) sram_model_bi1 (
    .clk      ( clk            ),
    .addr     ( index         ),
    .data_out ( sram_data_b[1] )
  );
  
  // i+2
  sram_model #(
    .ADDR_WIDTH (4)
  ) sram_model_ai2 (
    .clk      ( clk            ),
    .addr     ( index         ),
    .data_out ( sram_data_a[2] )
  ); 
  sram_model #(
    .ADDR_WIDTH (4)
  ) sram_model_bi2 (
    .clk      ( clk            ),
    .addr     ( index         ),
    .data_out ( sram_data_b[2] )
  );

  // i+3
  sram_model #(
    .ADDR_WIDTH (4)
  ) sram_model_ai3 (
    .clk      ( clk            ),
    .addr     ( index         ),
    .data_out ( sram_data_a[3] )
  ); 
  sram_model #(
    .ADDR_WIDTH (4)
  ) sram_model_bi3 (
    .clk      ( clk            ),
    .addr     ( index         ),
    .data_out ( sram_data_b[3] )
  );

endmodule