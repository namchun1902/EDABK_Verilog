module clock_devider (
  input      clk,
  input      rst_n,
  output reg clk_1HZ // LED
);

  parameter MAX_COUNT = 24_999_999;

  reg [24:0] counter_value;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      counter_value <= 25'd0;
    end else begin
      if (counter_value == MAX_COUNT) begin
        counter_value <= 25'd0;
      end else begin
        counter_value <= counter_value + 25'd1;
      end
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      clk_1HZ <= 0;
    end else begin
      if (counter_value == MAX_COUNT) begin
        clk_1HZ <= ~clk_1HZ;
      end else begin
        clk_1HZ <= clk_1HZ;
      end
    end
  end
endmodule