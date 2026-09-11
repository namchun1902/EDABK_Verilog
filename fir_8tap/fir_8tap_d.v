module fir_8tap_d (
  input wire               clk,
  input wire               rst_n,
  input wire signed [15:0] x,
  input wire signed [15:0] h[0:7],

  output wire signed [34:0] y
);

  reg signed [15:0] d[0:7];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      d[0] <= 0;
      d[1] <= 0;
      d[2] <= 0;
      d[3] <= 0;
      d[4] <= 0;
      d[5] <= 0;
      d[6] <= 0;
      d[7] <= 0;
    end else begin
      d[0] <= x;
      d[1] <= d[0];
      d[2] <= d[1];
      d[3] <= d[2];
      d[4] <= d[3];
      d[5] <= d[4];
      d[6] <= d[5];
      d[7] <= d[6];
    end
  end

  assign y = h[0]*d[0] + h[1]*d[1] + h[2]*d[2] + h[3]*d[3] + h[4]*d[4] + h[5]*d[5] + h[6]*d[6] + h[7]*d[7];

endmodule