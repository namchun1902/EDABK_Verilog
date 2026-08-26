module cra_16bit #(
  parameter DATA_WIDTH = 16
) (
  input  wire [DATA_WIDTH - 1 : 0] A,
  input  wire [DATA_WIDTH - 1 : 0] B,
  input  wire                      Cin,
  output wire [DATA_WIDTH - 1 : 0] Sum,
  output wire                      Cout
);
  
  wire [DATA_WIDTH : 0] carry;

  assign carry[0] = Cin;
  assign Cout     =carry[DATA_WIDTH];

  genvar i;
  generate
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin: cra
      full_adder fa_inst (
        .a   ( A[i]       ),
        .b   ( B[i]       ),
        .ci  ( carry[i]   ),
        .sum ( Sum[i]     ),
        .co  ( carry[i+1] )
      );
    end
  endgenerate

endmodule