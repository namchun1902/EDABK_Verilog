module fsm_p2 (
  input wire clk,
  input wire rst_n,
  input wire start,
  input wire r_last,

  output reg r_clr,
  output reg r_inc,
  output reg write_en,

  output reg done
);

  localparam S_IDLE  = 2'b00;
  localparam S_RUN   = 2'b01;
  localparam S_FLUSH = 2'b10;
  localparam S_DONE  = 2'b11;

  // Reg luu trang thai
  reg [1:0] current_state;
  reg [1:0] next_state;

  // State register
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state <= S_IDLE;
    else        current_state <= next_state; 
  end

  // Next state logic
  always @(current_state or start or r_last) begin
    next_state = current_state;

    case (current_state)
      S_IDLE: begin
        if (start) next_state = S_RUN;
        else       next_state = S_IDLE;
      end
      S_RUN: begin
        if (r_last) next_state = S_FLUSH;
        else        next_state = S_RUN;
      end
      S_FLUSH: next_state = S_DONE;
      S_DONE:  next_state = S_IDLE;
    endcase
  end

  // Output logic
  always @(current_state) begin
    {r_clr, r_inc, write_en, done} = {4'b0};

    case (current_state)
      S_IDLE: begin
        r_clr = 1;
        done  = 0;
      end
      S_RUN: begin
        r_clr    = 0;
        r_inc    = 1;
        write_en = 1;
      end
      S_FLUSH: begin
        // Đã đc gán mặc định về 0
      end
      S_DONE: begin
        done = 1;
      end
      default: begin
      end 
    endcase
  end
endmodule