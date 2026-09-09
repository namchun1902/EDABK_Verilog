module adder_tree (
  input wire signed [31:0] p0,
  input wire signed [31:0] p1,
  input wire signed [31:0] p2,
  input wire signed [31:0] p3,

  output wire signed [33:0] partial_sum
);

  assign partial_sum = p0 + p1 + p2 + p3;
  
endmodule