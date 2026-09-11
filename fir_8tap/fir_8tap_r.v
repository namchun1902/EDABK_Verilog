module fir_8tap_r (
  input wire clk,
  input wire rst_n,
  input wire signed [15:0] x,
  input wire signed [15:0] h[0:7],

  output wire signed [34:0] y
);

  reg signed [34:0] d[0:6];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      d[0] <= 0;
      d[1] <= 0;
      d[2] <= 0;
      d[3] <= 0;
      d[4] <= 0;
      d[5] <= 0;
      d[6] <= 0;
    end else begin
      d[6] <= h[7] * x;
      d[5] <= h[6]*x + d[6];
      d[4] <= h[5]*x + d[5];
      d[3] <= h[4]*x + d[4];
      d[2] <= h[3]*x + d[3];
      d[1] <= h[2]*x + d[2];
      d[0] <= h[1]*x + d[1];
    end
  end
  
  assign y = h[0]*x + d[0]

endmodule