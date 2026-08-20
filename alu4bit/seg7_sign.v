module seg7_sign(
  input wire       is_neg,
  output reg [6:0] seg
);

  always @(*) begin
    if (is_neg) seg = 7'b011_1111; // Dấu -
    else        seg = 7'b111_1111;
  end
  
endmodule