module top_k4 (
  input wire               clk,
  input wire               rst_n,
  input wire               start,

  output wire [5:0]         sram_addr,
  output wire               done,
  output wire signed [39:0] mac_sum
);

  // Dây trung gian
  wire               i_inc;
  wire               i_clr;
  wire               acc_en;
  wire               acc_clr;
  wire               i_last;
  wire               valid_in;
  wire signed [31:0] prod;
  
  // FF sau bộ nhân
  reg [31:0] mult_out;
  // 2 FF làm trễ valid_in
  reg v1;
  reg v2;

  fsmk4 fsmk4_inst (
    .clk      ( clk      ),
    .rst_n    ( rst_n    ),
    .start    ( start    ),
    .i_last   ( i_last   ),
    .i_inc    ( i_inc    ),
    .i_clr    ( i_clr    ),
    .acc_clr  ( acc_clr  ),
    .valid_in ( valid_in ),
    .done     ( done     )
  );

  counter counter_inst (
    .clk   ( clk       ),
    .rst_n ( rst_n     ),
    .i_inc ( i_inc     ),
    .i_clr ( i_clr     ),
    .q     ( sram_addr )     
  );

  wire signed [15:0] sram_data_a;
  wire signed [15:0] sram_data_b;
  // SRAM nạp mất 1 chu kỳ
  sram_model sram_model_a (
    .clk      ( clk         ),
    .addr     ( sram_addr   ),
    .data_out ( sram_data_a )
  );
  sram_model sram_model_b (
    .clk      ( clk         ),
    .addr     ( sram_addr   ),
    .data_out ( sram_data_b )
  );

  comparator comparator_inst (
    .i      ( sram_addr ),
    .i_last ( i_last    )
  );

  multiplier multiplier_inst (
    .a ( sram_data_a ),
    .b ( sram_data_b ),
    .p ( prod        )
  );

  // Chèn 1 thanh ghi sau bộ nhân
  always @(posedge clk) begin
      mult_out <= prod;
  end

  // Chèn 2 FF nối tiếp để trễ valid_in
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      v1 <= 0;
      v2 <= 0;
    end else begin
      v1 <= valid_in;
      v2 <= v1;
    end
  end

  accumulator accumulator_inst(
    .clk     ( clk      ),
    .rst_n   ( rst_n    ),
    .acc_en  ( v2       ),
    .acc_clr ( acc_clr  ),
    .p       ( mult_out ),
    .sum     ( mac_sum  )
  );
endmodule