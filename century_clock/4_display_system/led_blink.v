module led_blink (
  input clk,
  input rst_n,
  output led
);
  tick_generator_1hz led_blink_1hz(
    .clk       ( clk   ),
    .rst_n     ( rst_n ),
    .tick_1HZ  (       ),
    .blink_1HZ ( led   )
  );
endmodule