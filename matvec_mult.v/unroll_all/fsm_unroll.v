module fsm_unroll (
  input  wire clk,
  input  wire start,
  input  wire rst_n,

  output reg  en,
  output reg  write_en,

  output reg  done
);

  localparam IDLE = 2'b00;
  localparam LOAD = 2'b01;
  localparam RUN  = 2'b10;
  localparam DONE = 2'b11;

  // Reg luu trang thai
  reg [1:0] next_state;
  reg [1:0] current_state;

  // State register
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state <= IDLE;
    else        current_state <= next_state;
  end

  // Next state logic
  always @(current_state or start) begin
    next_state = current_state;

    case (current_state)
      IDLE: begin
        if (start) next_state = LOAD;
        else       next_state = IDLE;
      end
      LOAD: next_state = RUN;
      RUN: next_state = DONE;
      DONE: next_state = IDLE;
    endcase
  end

  // Output logic
  always @(current_state) begin
    {en, write_en, done} = {3'b0};

    case (current_state)
      IDLE: begin
        en       = 0;
        write_en = 0;
        done     = 0;
      end
      LOAD: begin
        en       = 1;
      end
      RUN: begin
        en       = 0;
        write_en = 1;
      end
      DONE: begin
        write_en = 0;
        done     = 1;
      end
      default: begin
        en       = 0;
        write_en = 0;
        done     = 0;
      end
    endcase
  end
endmodule