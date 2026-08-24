// Làm sạch tín hiệu, đảm bảo chỉ nhận 1 lần bấm
module debounce #(
    // Tái sử dụng với các kích thước
    parameter CLK_FREQ = 50_000_000,    // Clock frequency in Hz
    parameter DEBOUNCE_TIME_MS = 20     // Debounce time in milliseconds
) (
    input wire clk,           // System clock
    input wire rst_n,         // Active low reset
    input wire button_in,     // Raw button input (noisy)
    output reg button_out     // Debounced button output
);

    // Calculate counter value for debounce time
    localparam COUNTER_MAX = (CLK_FREQ / 1000) * DEBOUNCE_TIME_MS; // Tính toán 
    localparam COUNTER_WIDTH = $clog2(COUNTER_MAX + 1); // Tìm size: log2()

    // Internal registers
    reg [COUNTER_WIDTH-1:0] counter;
    reg button_sync_0, button_sync_1;

    // Double-flop synchronizer to avoid metastability
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            button_sync_0 <= 1'b0;
            button_sync_1 <= 1'b0;
        end else begin
            button_sync_0 <= button_in; // btn_0 lấy btn_in
            button_sync_1 <= button_sync_0; // btn_1 lấy btn_0 (ban đầu) / 2 lệnh diễn ra cùng lúc
        end
    end

    // Debounce logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            button_out <= 1'b0;
        end else begin
            if (button_sync_1 != button_out) begin
                // Input differs from output, start/continue counting
                counter <= counter + 1;
                if (counter >= COUNTER_MAX) begin // ~ Giữ >= 20ms 
                    button_out <= button_sync_1; // Nhận trạng thái đã ổn định
                    counter <= 0;
                end
            end else begin
                // Input matches output, reset counter
                counter <= 0;
            end
        end
    end

endmodule