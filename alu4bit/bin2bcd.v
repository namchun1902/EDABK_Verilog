module bin2bcd (
    input      [4:0] bin,
    output reg [7:0] bcd
);
  integer i;

  always @(*) begin
    bcd = 8'd0;
    for (i = 0; i <= 4; i = i + 1) begin
      if (bcd[3:0] >= 5) bcd[3:0] = bcd[3:0] + 3;
      bcd = {bcd[6:0], bin[4-i]};
    end
  end

endmodule