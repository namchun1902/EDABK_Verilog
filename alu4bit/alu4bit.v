module alu4bit (
  input  wire       [3:0] src1_i,
  input  wire       [3:0] src2_i,
  input  wire       [3:0] alu_op_i,
  output reg signed [4:0] result_o,
  output reg              overflow_o
);
  localparam ADD = 4'b0000, SUB = 4'b0001, XOR = 4'b0010, OR = 4'b0011;
  localparam AND = 4'b0100, SLL = 4'b0101, SRL = 4'b0110, SRA = 4'b0111;
  localparam SLT = 4'b1000;

  wire signed [4:0] a_signed = $signed(src1_i);
  wire signed [4:0] b_signed = $signed(src2_i);

  always @(*) begin
    overflow_o = 1'b0;
    case(alu_op_i)
      ADD: begin
        result_o   = a_signed + b_signed;
        overflow_o = (result_o[4] ^ result_o[3]);
      end
      SUB: begin
        result_o   = a_signed - b_signed;
        overflow_o = (result_o[4] ^ result_o[3]);
      end
      XOR: result_o = src1_i ^ src2_i;
      OR: result_o = src1_i | src2_i;
      AND: result_o = src1_i & src2_i;
      SLL: result_o = a_signed << 1;
      SRL: result_o = src1_i >> 1;
      SRA: result_o = a_signed >>> 1;
      SLT: result_o = (a_signed < b_signed) ? 5'b00001 : 5'b00000;
      default: result_o = 5'b00000;
    endcase
  end

endmodule