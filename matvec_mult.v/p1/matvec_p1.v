`timescale 1ns/1ps

module matvec_p1 (
    input clk,
    input rst_n,
    input start,

    // Nạp A và x trước khi start; không ghi trong lúc tính toán.
    input        A_we,
    input  [5:0] A_waddr,
    input signed [15:0] A_wdata,

    input        x_we,
    input  [2:0] x_waddr,
    input signed [15:0] x_wdata,

    output [319:0] y_out,

    output done
);

    reg [2:0] r;
    reg [2:0] c;

    reg r_clr;
    reg r_en;

    reg c_clr;
    reg c_en;

    reg [2:0] r_next;
    reg [2:0] c_next;

    always @(*) begin

        r_next = r;
        c_next = c;

        if (c < 3'd7) begin

            r_next = r;
            c_next = c + 1'b1;

        end

        else if (r < 3'd7) begin

            r_next = r + 1'b1;
            c_next = 3'd0;

        end

        else begin

            r_next = r;
            c_next = c;

        end

    end

    always @(posedge clk) begin

        if (!rst_n) begin

            r <= 3'd0;
            c <= 3'd0;

        end
        else begin

            if (r_clr)
                r <= 3'd0;
            else if (r_en)
                r <= r + 1'b1;

            if (c_clr)
                c <= 3'd0;
            else if (c_en)
                c <= c + 1'b1;

        end

    end

    reg signed [15:0] x_mem [0:7];

    wire signed [15:0] x_data;

    always @(posedge clk) begin

        if (x_we)
            x_mem[x_waddr] <= x_wdata;

    end

    assign x_data = x_mem[c];

    reg signed [15:0] A_mem [0:63];
    reg signed [15:0] A_dout;

    wire [5:0] addr_A;

    wire [5:0] addr_current;
    wire [5:0] addr_next;

    // A lưu theo hàng: địa chỉ = r * 8 + c.
    assign addr_current = {r, c};
    assign addr_next    = {r_next, c_next};

    localparam [1:0]
        S_IDLE = 2'd0,
        S_WARM = 2'd1,
        S_CALC = 2'd2,
        S_DONE = 2'd3;

    reg [1:0] state;
    reg [1:0] next_state;

    // A đọc đồng bộ, trễ 1 chu kỳ. CALC đọc trước phần tử kế tiếp
    // để A_dout khớp với x_mem[c] sau khi cập nhật chỉ số.
    assign addr_A =
        (state == S_CALC) ? addr_next :
                            addr_current;

    always @(posedge clk) begin

        if (A_we) begin

            A_mem[A_waddr] <= A_wdata;

        end
        else begin

            A_dout <= A_mem[addr_A];

        end

    end

    wire signed [31:0] product;

    assign product = A_dout * x_data;

    wire signed [39:0] product_ext;

    // Mở rộng dấu lên 40 bit để cộng dồn đúng cả tích âm.
    assign product_ext =
        {{8{product[31]}}, product};

    reg signed [39:0] acc;

    wire signed [39:0] sum;

    reg acc_clr;
    reg acc_en;

    assign sum = acc + product_ext;

    always @(posedge clk) begin

        if (!rst_n)
            acc <= 40'sd0;

        else if (acc_clr)
            acc <= 40'sd0;

        else if (acc_en)
            acc <= sum;

    end

    reg signed [39:0] y_mem [0:7];

    reg y_en;

    integer i;

    always @(posedge clk) begin

        if (!rst_n) begin

            for (i = 0; i < 8; i = i + 1)
                y_mem[i] <= 40'sd0;

        end

        else if (y_en) begin

            // Ghi sum thay vì acc để tính cả tích cuối hàng ở cạnh clock này.
            y_mem[r] <= sum;

        end

    end

    assign y_out[39:0]    = y_mem[0];
    assign y_out[79:40]   = y_mem[1];
    assign y_out[119:80]  = y_mem[2];
    assign y_out[159:120] = y_mem[3];
    assign y_out[199:160] = y_mem[4];
    assign y_out[239:200] = y_mem[5];
    assign y_out[279:240] = y_mem[6];
    assign y_out[319:280] = y_mem[7];

    wire c_last;
    wire r_last;

    assign c_last = (c == 3'd7);
    assign r_last = (r == 3'd7);

    always @(posedge clk) begin

        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;

    end

    always @(*) begin

        next_state = state;

        r_clr = 1'b0;
        r_en  = 1'b0;

        c_clr = 1'b0;
        c_en  = 1'b0;

        acc_clr = 1'b0;
        acc_en  = 1'b0;

        y_en = 1'b0;

        case (state)

            S_IDLE: begin

                if (start) begin

                    r_clr   = 1'b1;
                    c_clr   = 1'b1;
                    acc_clr = 1'b1;

                    next_state = S_WARM;

                end

            end

            // Chờ A[0][0] được đọc ra trước khi bắt đầu nhân và cộng dồn.
            S_WARM: begin

                next_state = S_CALC;

            end

            S_CALC: begin

                if (!c_last) begin

                    acc_en = 1'b1;

                    c_en = 1'b1;

                    next_state = S_CALC;

                end

                else if (!r_last) begin

                    y_en = 1'b1;

                    acc_clr = 1'b1;

                    c_clr = 1'b1;
                    r_en  = 1'b1;

                    next_state = S_CALC;

                end

                else begin

                    y_en = 1'b1;

                    next_state = S_DONE;

                end

            end

            S_DONE: begin

                next_state = S_IDLE;

            end

            default: begin

                next_state = S_IDLE;

            end

        endcase

    end

    // done lên 1 trong một chu kỳ, sau khi cả 8 kết quả đã được ghi.
    assign done = (state == S_DONE);

endmodule