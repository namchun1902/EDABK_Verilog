module adder_tree (
  input  wire signed [31:0] p0, p1, p2, p3, p4, p5, p6, p7,
  output wire signed [34:0] sum
);

  assign sum = p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7;

endmodule