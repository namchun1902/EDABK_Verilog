module bin2bcd_param #(
    parameter BIN_WIDTH  = 14, // Mặc định: 14 bit nhị phân (gánh được số 16383)
    parameter BCD_DIGITS = 4   // Mặc định: Xuất ra 4 chữ số (4 bit/chữ số -> 16 bit)
)(
    input      [BIN_WIDTH-1:0]      bin,
    output reg [BCD_DIGITS*4-1:0]   bcd
);
    
    integer i, j;

    always @(*) begin
        bcd = 0; // Khởi tạo toàn bộ bằng 0
        
        // Vòng lặp ngoài: Dịch bit tuần tự (Chạy BIN_WIDTH lần)
        for (i = 0; i < BIN_WIDTH; i = i + 1) begin
            
            // Vòng lặp trong: Quét qua TỪNG chữ số BCD để kiểm tra và cộng 3
            for (j = 0; j < BCD_DIGITS; j = j + 1) begin
                // Cú pháp [j*4 +: 4] nghĩa là: Bắt đầu từ vị trí j*4, lấy lên trên 4 bit.
                if (bcd[j*4 +: 4] >= 5) begin
                    bcd[j*4 +: 4] = bcd[j*4 +: 4] + 4'd3;
                end
            end
            
            // Dịch trái toàn bộ chuỗi BCD và nhét bit cao nhất của bin vào đuôi
            bcd = {bcd[BCD_DIGITS*4-2 : 0], bin[BIN_WIDTH-1-i]};
        end
    end

endmodule