`timescale 1ns/ 1ps

module adder4bit_tb_random;
  // stim rộng hơn số bit đầu vào đúng 1 bit
  reg  [9:0] stim;
  wire [3:0] s;
  wire       co;

  integer error;
  integer i;
  integer seed = 2024;

  adder4bit adder4bit_DUT (
    .sum   ( s         ),
    .c_out ( co        ),
    .a     ( stim[8:5] ),
    .b     ( stim[4:1] ),
    .c     ( stim[0]   )
  );

  initial begin
    error = 0;
    stim = $random(seed);

    for (i = 0; i < 512; i = i + 1) begin
      #5; // Đợi mạch tính toán xong

      if ({co, s} !== stim[8:5] + stim[4:1] + stim[0]) begin
        error = error + 1;
      end

      #5 stim = $random;
    end
    if (error == 0) 
      $display("PASS");
    else 
      $display("FAIL: %0d loi", error);
      
    $stop;
  end


endmodule