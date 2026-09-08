module fsm (
  input wire clk,
  input wire rst_n,
  input wire start,
  input wire i_last,

  output reg i_inc,
  output reg i_clr,
  output reg acc_en,
  output reg acc_clr,

  // Cờ báo tính xong
  output reg done
);

  localparam S_IDLE = 2'b00;
  localparam S_WARM = 2'b01;
  localparam S_MAC  = 2'b10;
  localparam S_DONE = 2'b11;

  // Reg lưu trạng thái
  reg [1:0] current_state;
  reg [1:0] next_state;

  // State register
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state  <= S_IDLE;
    else        current_state  <= next_state;
  end

  // Next state logic
  always @(current_state or start or i_last) begin
    next_state = current_state;

    case (current_state)
      S_IDLE:  if (start) next_state = S_WARM;
               else       next_state = S_IDLE;
      S_WARM:  next_state = S_MAC;
      S_MAC:   if (i_last) next_state = S_DONE;
               else        next_state = S_MAC;
      S_DONE:  next_state = S_IDLE;
      default: next_state = S_IDLE;
    endcase
  end

  // Output logic
  always @(current_state) begin
    case (current_state)
      S_IDLE: begin
                i_inc   = 0;
                i_clr   = 0;
                acc_en  = 0;
                acc_clr = 0;
                done    = 0;
      end
      S_WARM: begin 
                i_inc   = 0;
                i_clr   = 1;
                acc_clr = 1;
                acc_en  = 0;
                done    = 0;
      end
      S_MAC:  begin
                i_inc   = 1;
                i_clr   = 0;
                acc_en  = 1;
                acc_clr = 0;
                done    = 0;
      end
      S_DONE: begin
                i_inc   = 0;
                i_clr   = 0;
                acc_en  = 0;
                acc_clr = 0;
                done    = 1;
      end
      default: begin
                i_inc   = 0;
                i_clr   = 0;
                acc_en  = 0;
                acc_clr = 0;
                done    = 0;
      end
    endcase
  end
endmodule