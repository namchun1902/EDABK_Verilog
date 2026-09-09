/*
Tích vô hướng ba kiến trúc - slide 24
Triển khai K2 (một MAC), K3 (bốn MAC) và K4 (pipeline ba tầng) cho N = 64, dữ liệu 16 bit có dấu.
Dùng chung một testbench, xác nhận cả ba cho cùng kết quả trên 1000 vector ngẫu nhiên.
Lập bảng so sánh số chu kỳ đo được, số bộ nhân và f_max sau tổng hợp.
*/


module K2 
#(  parameter N = 64,
    parameter SRAM_WIDTH = 16,
    parameter REG_WIDTH = 40,
    parameter PROD_WIDTH = 32) // Mul 16x16 -> 32b

(   input clk,
    input rst_n,
    input start,
    input signed [SRAM_WIDTH-1:0] a_dout, // Phần mô phỏng nối SRAM - nhiệm vụ của TB
    input signed [SRAM_WIDTH-1:0] b_dout,
    output reg signed [REG_WIDTH-1:0] acc,
    output reg done,
    output reg [6:0] i
);


    wire signed [PROD_WIDTH-1:0] prod;
    wire i_last;

    // -- FSM ---
    localparam [1:0]
        S_IDLE = 2'b00,
        S_WAIT = 2'b01, // Tránh tính dữ liệu rác giai đoạn đầu
        S_MAC = 2'b10,
        S_DONE = 2'b11;

    reg [1:0] state, nxt;

    reg acc_clr, acc_en;
    reg i_clr, i_inc;

    // ── ĐƯỜNG DỮ LIỆU: thanh ghi ──
    always @(posedge clk) begin
        if (acc_clr)     acc <= 0;
        else if (acc_en) acc <= acc + prod;
        if (i_clr)       i   <= 0;
        else if (i_inc)  i   <= i + 1;
    end

    // ── ĐƯỜNG DỮ LIỆU: tổ hợp và cờ trạng thái ──
    assign prod   = a_dout * b_dout;
    assign i_last = (i == N); // Tránh mất 1 chu kỳ cuối

    // ── ĐIỀU KHIỂN: thanh ghi trạng thái ──
    always @(posedge clk)
        if (!rst_n) state <= S_IDLE;
        else        state <= nxt;

    // ── ĐIỀU KHIỂN: trạng thái kế và tín hiệu điều khiển ──
    always @(state or start or i_last) begin
        nxt = state;
        {acc_clr, acc_en, i_clr, i_inc, done} = 5'b0;
        case (state)
            S_IDLE: if (start) begin
                    acc_clr = 1'b1; i_clr = 1'b1;
                    nxt = S_WAIT;
                    end
            S_WAIT: begin 
                    i_inc = 1'b1;
                    nxt = S_MAC; 
                    end
            S_MAC:  begin
                    acc_en = 1'b1; i_inc = 1'b1;
                    if (i_last) nxt = S_DONE;
                    end
            S_DONE: begin done = 1'b1; nxt = S_IDLE; end
            default: ;
        endcase
    end
endmodule