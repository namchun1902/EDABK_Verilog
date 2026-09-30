module accumulator #(
  parameter P_WIDTH = 32,
  parameter SUM_WIDTH = 40
) (
  input  wire                        clk,
  input  wire                        rst_n,
  input  wire                        acc_en,          // Từ FSM
  input  wire                        acc_clr,         // Từ FSM
  input  wire signed [P_WIDTH-1:0]   p,               // Tích từ bộ nhân
  output reg  signed [SUM_WIDTH-1:0] sum
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sum <= 0;
    end else if (acc_clr) begin
      sum <= 0;
    end else if (acc_en) begin
      sum <= sum + p; 
    end
  end
  
endmodule