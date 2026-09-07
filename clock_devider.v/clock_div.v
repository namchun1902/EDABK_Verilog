module fractional_clock_divider #(
    parameter INPUT_FREQ = 50_000_000,
    parameter OUTPUT_FREQ = 3  // Ví dụ tần số lẻ 3 Hz
) (
    input  wire clk,
    input  wire rst_n,
    output wire clk_o
);

    // Tính toán bước nhảy bằng số 64-bit để không bị tràn khi nhân với 2^32
    // 64'h100000000 chính là 2^32
    localparam [63:0] STEP_64 = (OUTPUT_FREQ * 64'h1_0000_0000) / INPUT_FREQ;
    
    // Ép kiểu về 32-bit cho thanh ghi phần cứng
    localparam [31:0] STEP = STEP_64[31:0]; 

    reg [31:0] phase_acc;

    // Block kiểm tra lỗi thông số
    initial begin
        if (OUTPUT_FREQ > (INPUT_FREQ / 2))
            $error("OUTPUT_FREQ phai nho hon hoac bang INPUT_FREQ / 2");
    end

    // Bộ tích lũy pha
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_acc <= 32'd0;
        end else begin
            phase_acc <= phase_acc + STEP;
        end
    end

    // Lấy bit cao nhất làm xung Clock đầu ra
    assign clk_o = phase_acc[31];

endmodule