module hex_to7seg (
  input  wire [3:0] num,
  output reg  [6:0] segment //gfe_dcba
);
  
  // 0 bật, 1 tắt
  always @(*) begin
    case (num)
      4'b0000: segment = 7'b100_0000; //0
      4'b0001: segment = 7'b111_1001; //1
      4'b0010: segment = 7'b010_0100; //2
      4'b0011: segment = 7'b011_0000; //3
      4'b0100: segment = 7'b001_1001; //4
      4'b0101: segment = 7'b001_0010; //5
      4'b0110: segment = 7'b000_0010; //6
      4'b0111: segment = 7'b111_1000; //7
      4'b1000: segment = 7'b000_0000; //8
      4'b1001: segment = 7'b001_0000; //9  
      default: segment = 7'b100_0001; //U
    endcase
  end
  
endmodule