module counter #(
  parameter WIDTH = 6
) (
  input  wire            clk,
  input  wire            rst_n,
  input  wire            i_inc, // Tín hiệu FSM
  input  wire            i_clr, // Tín hiệu FSM       
  output reg [WIDTH-1:0] q      // Đầu ra đi vào SRAM
);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= 0;
    end else if (i_clr) begin
      q <= 0;
    end else if (i_inc) begin
      q <= q + 1;
    end else begin
      q <= q;
    end
  end
endmodule