`timescale 1ns / 1ps

module tb_top_p2;

  // Parameters
  localparam CLK_PERIOD = 10; // 10ns period -> 100MHz clock

  // Signals to connect to the dut_p2
  reg clk;
  reg rst_n;
  reg start;
  reg signed [127:0] x_in;
  wire done;

  // Instantiate the Device Under Test (dut_p2)
  top_p2 dut_p2 (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .x_in(x_in),
    .done(done)
  );

  // Clock Generator
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end
    integer cycle_counter;
    integer i;
  // Main Test Sequence
  initial begin

    // 1. Initialize and Reset the system
    $display("--- Starting Testbench for top_p2 ---");
    rst_n = 1'b0; // Assert reset
    start = 1'b0;
    x_in  = 128'd0;
    # (CLK_PERIOD * 5);
    rst_n = 1'b1; // De-assert reset
    $display("[%0t] System reset released.", $time);
    # (CLK_PERIOD);

    // 2. Load random data into x_in vector
    // $random generates a 32-bit number, so we concatenate 4 of them.
    x_in = {$random, $random, $random, $random};
    $display("Input vector x_in loaded with random data:");
    for (i = 0; i < 8; i = i + 1) begin
      // Display each 16-bit element of the vector
      $display("x[%0d] = %h", i, x_in[(i*16)+15 -: 16]);
    end
    # (CLK_PERIOD);

    // 3. Start the process and begin measuring cycles
    $display("[%0t] Asserting start signal...", $time);
    start <= 1;
    @(posedge clk);
    start <= 0;
    
    cycle_counter = 0;
    $display("Waiting for 'done' signal to go high...");

    // This loop counts clock cycles until 'done' is asserted
    while (done == 0) begin
      @(posedge clk);
      cycle_counter = cycle_counter + 1;
    end
    
    // 4. Report the results
    $display("[%0t] 'done' signal detected!", $time);
    @(posedge clk); // Wait one more cycle for results to be fully stable in y_ram
    
    $display("--- Calculation Finished ---");
    $display("Total cycles from start to done: %0d", cycle_counter);
    
    $display("Output vector y (from internal dut_p2.y_ram):");
    for (i = 0; i < 8; i = i + 1) begin
      // Accessing internal signals for verification requires hierarchical path
      $display("y[%0d] = %h (%d)", i, dut_p2.y_ram[i], dut_p2.y_ram[i]);
    end

    // 5. Finish the simulation
    $display("--- Testbench Finished ---");
    $finish;
  end

endmodule