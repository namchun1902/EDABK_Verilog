module top_p2 (
  input wire clk,
  input wire rst_n,
  input wire start,
  input wire signed [127:0] x_in,

  output wire done
);

  // Chia bank và thanh ghi
  wire signed [15:0] sram_data_a[0:7];
  reg  signed [15:0] x[0:7]; // Tin hieu qua thanh ghi x 8*16b
 
  // Dia chi hang tu bo dem
  wire [2:0] r;

  // Ket qua cua 8 bo multiplier
  wire signed [31:0] p[0:7];

  // Day trung gian
  wire r_inc;
  wire r_clr;
  wire write_en;
  wire r_last;

  // Ket qua sau khi qua 3 tang cong
  wire signed [34:0] mac_sum;
  // Thanh ram y 35bit, 8 phan tu (8x35bit)
  reg signed [34:0] y_ram[0:7];

  // Nap du lieu vao sram mat 1 chu ky
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin: SRAM_BANK_A
      sram_model sram_model_inst (
        .clk      ( clk            ),
        .r        ( r              ), // Hang
        .data_out ( sram_data_a[i] )
      );
    end
  endgenerate

  // Thanh ghi du lieu x, chi can nap 1 lan
  genvar j;
  generate
    for (j = 0; j < 8;j = j + 1) begin: REGISTER
      always @(posedge clk or negedge rst_n) begin
        if (!rst_n) x[j] <= 0;
        else        x[j] <= x_in[(j*16)+15 : (j*16)];
      end
    end
  endgenerate

  // FSM
  fsm_p2 fsm_inst (
    .clk      ( clk      ),
    .rst_n    ( rst_n    ),
    .start    ( start    ),
    .r_last   ( r_last   ),
    .r_clr    ( r_clr    ),
    .r_inc    ( r_inc    ),
    .write_en ( write_en ),
    .done     ( done     )
  );
  
  // Tin hieu write_en di qua 1 FF
  reg write_en_d2;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) write_en_d2 <= 0;
    else        write_en_d2 <= write_en;
  end

  counter #(
    .WIDTH(3)
  ) counter_inst (
    .clk   ( clk   ),
    .rst_n ( rst_n ),
    .i_inc ( r_inc ),
    .i_clr ( r_clr ),
    .q     ( r     )
  );

  comparator #(
    .N(8)
  ) comaparator_inst (
    .i      ( r      ),
    .i_last ( r_last )
  );

  // Tin hieu r qua 1 FF
  // De tao tre 1 chu ky nhu write_en
  reg [2:0] r_d1;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) r_d1 <= 0;
    else        r_d1 <= r;
  end

  // Luu vao thanh ram y
  always @(posedge clk ) begin
    if (write_en_d2) y_ram[r_d1] <= mac_sum;
    else             y_ram[r_d1] <= y_ram[r_d1]; 
  end

  // 8 bo multiplier
  genvar k;
  generate
    for (k = 0;k < 8; k = k + 1) begin: MULTIPLIER
      multiplier multiplier_inst (
        .a ( sram_data_a[k] ),
        .b ( x[k]           ),
        .p ( p[k]           )
      );
    end
  endgenerate

  // Cay cong 3 tang
  adder_tree adder_inst (
    .p0  ( p[0]    ),
    .p1  ( p[1]    ),
    .p2  ( p[2]    ),
    .p3  ( p[3]    ),
    .p4  ( p[4]    ),
    .p5  ( p[5]    ),
    .p6  ( p[6]    ),
    .p7  ( p[7]    ),
    .sum ( mac_sum )
  );

endmodule