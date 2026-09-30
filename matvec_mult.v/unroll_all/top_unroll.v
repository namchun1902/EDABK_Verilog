module top_unroll (
  input wire                clk,
  input wire                rst_n,
  input wire                start,
  input wire signed [1023:0] A_in,  // 64 phan tu A (8x8), moi phan tu 16-bit
  input wire signed [127:0]  x_in,  // 8 phan tu x, moi phan tu 16-bit

  output wire               done
);
  // Thanh ghi trung gian
  // Thanh ghi A: 8 hang x 8 cot x 16-bit
  reg signed [15:0] A [0:7][0:7];
  // Thanh ghi x: 8 phan tu x 16-bit
  reg signed [15:0] x [0:7];

  // Ket qua 64 bo nhan: 8 hang x 8 cot x 32-bit
  wire signed [31:0] p [0:7][0:7];
  // Ket qua 8 cay cong: 8 x 35-bit
  wire signed [34:0] y_sum [0:7];

  // y_ram: 8 phan tu x 35-bit
  reg signed [34:0] y_ram [0:7];

  // Tin hieu dieu khien tu FSM
  wire en;
  wire write_en;

  // 1. FSM instance
  fsm_unroll fsm_inst (
    .clk      ( clk      ),
    .rst_n    ( rst_n    ),
    .start    ( start    ),
    .en       ( en       ),
    .write_en ( write_en ),
    .done     ( done     )
  );

  // 2. Nap thanh ghi x
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin: REG_X
      always @(posedge clk or negedge rst_n) begin
        if (!rst_n)  x[i] <= 0;
        else if (en) x[i] <= x_in[(i*16)+15: i*16];
      end
    end
  endgenerate

  // 3. Nap thanh ghi A
  genvar ar, ac;
  generate
    for (ar = 0; ar < 8; ar = ar + 1) begin: REG_A_HANG
      for (ac = 0; ac < 8; ac = ac + 1) begin: REG_A_COT
        always @(posedge clk or negedge rst_n) begin
          if (!rst_n)  A[ar][ac] <= 0;
          else if (en) A[ar][ac] <= A_in[(ar*8 + ac)*16 + 15: (ar*8 + ac)*16];
        end
      end
    end
  endgenerate

  // 4. Instance 64 bo nhan
  genvar r, c;
  generate
    for (r = 0; r < 8; r = r + 1) begin: HANG
      for (c = 0; c < 8; c = c + 1) begin: COT
        multiplier mult_inst (
          .a ( A[r][c] ),
          .b ( x[c]    ),
          .p ( p[r][c] )
        );
      end
    end
  endgenerate

  // 5. Adder tree
  genvar j;
  generate
    for (j = 0; j < 8; j = j + 1) begin: ADDER
      adder_tree adder_inst (
        .p0  ( p[j][0] ),
        .p1  ( p[j][1] ),
        .p2  ( p[j][2] ),
        .p3  ( p[j][3] ),
        .p4  ( p[j][4] ),
        .p5  ( p[j][5] ),
        .p6  ( p[j][6] ),
        .p7  ( p[j][7] ),
        .sum ( y_sum[j] )
      );
    end
  endgenerate

  // 6. Ghi vao Y_RAM
  genvar k;
  generate
    for (k = 0; k < 8; k = k + 1) begin: Y_RAM
      always @(posedge clk) begin
        if (write_en) y_ram[k] <= y_sum[k];
      end
    end
  endgenerate
  
endmodule
