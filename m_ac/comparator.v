module comparator #(
  parameter N = 64
) (
  input wire [$clog2(N)-1:0] i,
  output wire i_last
);

  assign i_last = (i == (N-1));

endmodule