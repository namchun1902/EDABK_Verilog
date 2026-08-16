module alu4bit (
  input  wire [3:0] src1_i,
  input  wire [3:0] src2_i,
  input  wire [2:0] alu_op_i,
  output reg  [3:0] result_o,
  output reg        overflow_o
);
  localparam ADD = 3'b000, SUB = 3'b001, AND = 3'b010, OR = 3'b011;
  localparam XOR = 3'b100, NAND = 3'b101, SHL = 3'b110, PASS = 3'b111;

  always @(*) begin
    overflow_o = 1'b0;
    case(alu_op_i)
      ADD: begin
        result_o   = src1_i + src2_i;
        overflow_o = (src1_i[3] & src2_i[3] & ~result_o[3]) | (~src1_i[3] & ~src2_i[3] & result_o[3]);
      end
      SUB: begin
        result_o   = src1_i - src2_i;
        overflow_o = (src1_i[3] & ~src2_i[3] & ~result_o[3]) | (~src1_i[3] & src2_i[3] & result_o[3]);
      end
      AND:    result_o = src1_i & src2_i;
      OR:     result_o = src1_i | src2_i;
      XOR:    result_o = src1_i ^ src2_i;
      NAND:   result_o = ~(src1_i & src2_i);
      SHL:    result_o = src1_i << 1;
      PASS:   result_o = src1_i;
      default result_o = 4'b0000;
    endcase
  end

endmodule