// Làm sạch tín hiệu, đảm bảo chỉ nhận 1 lần sườn
module edge_detector (
    input  clk,
    input  reset_n,
    input  btn_in,   // Nút bấm đã qua Debounce
    output btn_pulse // Xung chớp nhoáng 1 clock để kích đếm
);

    reg btn_sync; // Thanh ghi lưu trạng thái nút bấm ở chu kỳ trước

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            btn_sync <= 1'b0;
        end else begin
            btn_sync <= btn_in; // Cập nhật trạng thái
        end
    end

    // Xung pulse chỉ bằng 1 khi: Hiện tại nút đang ĐƯỢC BẤM (1) 
    // VÀ chu kỳ trước đó nút CHƯA BẤM (0)
    assign btn_pulse = btn_in && (!btn_sync);

endmodule