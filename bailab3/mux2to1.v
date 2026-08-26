module mux2to1 (
  input  wire d0,
  input  wire d1,
  input  wire sel,
  output wire out
);
  assign out = sel ? d1 : d0;
  
endmodule
