module fsmk4 (
  input wire clk,
  input wire rst_n,
  input wire start,
  input wire i_last,

  output reg i_inc,
  output reg i_clr,
  output reg acc_clr,
  output reg valid_in, // Tín hi?u cho phép ghi vào ACC (Ph?i qua 2 FF)

  output reg done
);

  localparam S_IDLE  = 3'b000;
  localparam S_RUN   = 3'b001;
  localparam S_WAIT1 = 3'b010;
  localparam S_WAIT2 = 3'b011;
  localparam S_DONE  = 3'b100;

  // reg lýu tr?ng thái 
  reg [2:0] current_state;
  reg [2:0] next_state;

  // State register
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state <= S_IDLE;
    else        current_state <= next_state;
  end

  // Next state logic
  always @(current_state or start or i_last) begin
    next_state = current_state;

    case (current_state)
      S_IDLE: begin
        if (start)  next_state = S_RUN;
        else        next_state = S_IDLE;
      end
      S_RUN:  if (i_last) next_state = S_WAIT1;
              else        next_state = S_RUN;
      S_WAIT1:      next_state = S_WAIT2;
      S_WAIT2:      next_state = S_DONE;
      S_DONE:       next_state = S_IDLE;
      default:      next_state = S_IDLE;
    endcase
  end

  // Output logic
  always @(current_state or i_last) begin
      i_clr    = 0;
      i_inc    = 0;
      acc_clr  = 0;
      valid_in = 0;
      done     = 0;

    case (current_state)
      S_IDLE: begin
        i_clr   = 1;
        acc_clr = 1;
      end
      S_RUN: begin
        i_clr    = 0;
        acc_clr  = 0;
        valid_in = 1;
        i_inc    = 1;
      end
      S_WAIT1: begin
      end
      S_WAIT2: begin
      end 
      S_DONE: done = 1;
      default: begin
      end
    endcase
  end
endmodule