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

  localparam S_IDLE = 3'b000;
  localparam S_INIT = 3'b001;
  localparam S_WARM = 3'b010;
  localparam S_MAC  = 3'b011;
  localparam S_WAIT = 3'b100;
  localparam S_DONE = 3'b101;

  // Reg lưu trạng thái
  reg [2:0] current_state;
  reg [2:0] next_state;

  // State register
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state  <= S_IDLE;
    else        current_state  <= next_state;
  end

  // Next state logic
  always @(current_state or start or i_last) begin
    next_state = current_state;

    case (current_state)
      S_IDLE: begin
        if (start) next_state= S_INIT;
        else       next_state = S_IDLE;
      end
      S_INIT: next_state = S_WARM;
      S_WARM: next_state = S_MAC;
      S_MAC: begin
        if (i_last) next_state = S_WAIT;
        else        next_state = S_MAC;
      end
      S_WAIT: next_state = S_DONE;
      S_DONE: next_state = S_IDLE;
      default: next_state = S_IDLE;
    endcase
  end

  // Output logic
  always @(current_state) begin
       {i_inc,
       i_clr,
       acc_clr,
       acc_en} = {4'b0};
       done    =  0;
    case (current_state)
      S_IDLE: begin
        {i_inc,
         i_clr,
         acc_clr,
         acc_en} = {4'b0000};
         done    = 0;
      end
      S_INIT: begin
        i_inc   = 0;
        i_clr   = 1;
        acc_en  = 0;
        acc_clr = 1;
        done    = 0;
      end
      S_WARM: begin 
        i_inc   = 1;
        i_clr   = 0;
        acc_en  = 0;
        acc_clr = 0;
        done    = 0;
      end
      S_MAC:  begin
        i_inc   = 1;
        acc_en  = 1;
        i_clr   = 0;
        acc_clr = 0;
        done    = 0;
      end
      S_WAIT: begin
        i_inc   = 0;
        acc_en  = 1;
        i_clr   = 0;
        acc_clr = 0;
        done    = 0;
      end
      S_DONE: begin
        i_inc   = 0;
        acc_en  = 0;
        i_clr   = 0;
        acc_clr = 0;
        done    = 1;
      end
      default: begin
        i_inc   = 0;
        acc_en  = 0;
        i_clr   = 0;
        acc_clr = 0;
        done    = 0;
      end
    endcase
  end
endmodule