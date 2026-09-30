module multiplier (
  input  wire signed [15:0] a,
  input  wire signed [15:0] b,
  output wire signed [31:0] p
);
 
  assign p = a * b;

endmodule
