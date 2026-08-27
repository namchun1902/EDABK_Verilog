module mode_control (
  input clk,
  input reset_n,
  input btn_mode,  // Xung kích hoạt khi bấm nút Mode (Đã qua edge detect)

  output reg set_sec,
  output reg set_min,
  output reg set_hour,
  output reg set_day,
  output reg set_month,
  output reg set_year,
  output reg set_century,

  // Cờ đang chỉnh sửa (Để nhấp nháy đèn)
  output reg is_editing
);
  
  localparam NORMAL     = 3'd0; // 000
  localparam SET_SEC    = 3'd1; // 001
  localparam SET_MIN    = 3'd2; // 010
  localparam SET_HOUR   = 3'd3; // 011
  localparam SET_DAY    = 3'd4; // 100
  localparam SET_MONTH  = 3'd5; // 101
  localparam SET_YEAR   = 3'd6; // 110
  localparam SET_CEN    = 3'd7; // 111

  // Reg lưu trạng thái
  reg [2:0] current_state;
  reg [2:0] next_state;

  // Next state logic
  always @(*) begin
    next_state = current_state;

    if (btn_mode) begin
      if (current_state == SET_CEN) next_state = NORMAL;
      else                          next_state = next_state + 3'd1;
    end
  end

  // State register
  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) current_state <= 3'd0;
    else          current_state <= next_state;
  end

  // Output logic
  always @(*) begin
    set_sec     = 1'b0;
    set_min     = 1'b0;
    set_hour    = 1'b0;
    set_day     = 1'b0;
    set_month   = 1'b0;
    set_year    = 1'b0;
    set_century = 1'b0;
    is_editing  = 1'b1; // 7 trạng thái trừ NORMAL đều là chỉnh

    case (current_state)
      NORMAL:    is_editing  = 1'b0;
      SET_SEC:   set_sec     = 1'b1;
      SET_MIN:   set_min     = 1'b1;
                 set_sec     = 1'b0;
      SET_HOUR:  set_hour    = 1'b1;
                 set_min     = 1'b0;
      SET_DAY:   set_day     = 1'b1;
                 set_hour    = 1'b0;
      SET_MONTH: set_month   = 1'b1;
                 set_day     = 1'b0;
      SET_YEAR:  set_year    = 1'b1;
                 set_month   = 1'b0;
      SET_CEN:   set_century = 1'b1;
                 set_year    = 1'b0;
      default:   is_editing  = 1'b0;
    endcase
  end
endmodule