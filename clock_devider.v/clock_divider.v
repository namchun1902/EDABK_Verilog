module clock_divider #(
  parameter INPUT_FREQ = 50_000_000,
  parameter OUTPUT_FREQ = 1
) (
  input      clk,   // System clock 
  input      rst_n, // Active low reset
  output reg clk_o  // Output clock
);
  // 50% duty cycle clock divider
  localparam MAX_COUNT = (INPUT_FREQ / (2 * OUTPUT_FREQ)) - 1;

  reg [$clog2(MAX_COUNT + 1) - 1:0] count;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      clk_o <= 0;
      count <= 0;
    end else begin
      if (count == MAX_COUNT) begin
        count <= 0;
        clk_o <= ~clk_o;
      end else begin
        count <= count + 1;
      end
    end 
  end

endmodule
