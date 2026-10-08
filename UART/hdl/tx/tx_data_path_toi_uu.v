module tx_data_path #(
    parameter DATA_NUM = 8
)(
    input  wire                clk,
    input  wire                rst_n,
    input  wire                tick_last,   // Xung enable sinh ra từ bộ chia baud
    input  wire [1:0]          data_num,    // Cấu hình số bit dữ liệu (00: 5b, 01: 6b, 10: 7b, 11: 8b)
    input  wire                stop_num,    // Cấu hình số bit dừng (0: 1 bit, 1: 2 bit)
    input  wire                clr_bit,     // Tín hiệu clear bộ đếm bit từ FSM
    input  wire                clr_stop,    // Tín hiệu clear bộ đếm stop từ FSM
    input  wire                load_reg,    // Tín hiệu cho phép nạp dữ liệu song song vào PISO
    input  wire                shift_reg,   // Tín hiệu cho phép dịch dữ liệu trong PISO
    input  wire [1:0]          tx_sel,      // Tín hiệu từ FSM chọn kênh ngõ ra cho TX (Đã sửa thành 2-bit)
    input  wire [DATA_NUM-1:0] tx_data,     // Dữ liệu gốc 8-bit cần truyền
    input  wire                parity_type, // Loại parity (1: chẵn/even, 0: lẻ/odd)
    output wire                bit_last,    // Cờ báo hiệu đã đếm đủ số bit dữ liệu
    output wire                stop_last,   // Cờ báo hiệu đã đếm đủ số bit dừng (Đã bổ sung dấu phẩy)
    output reg                 tx           // Chân dữ liệu nối tiếp truyền ra ngoài (Đã sửa thành reg)
);

    //---------------------------------------------------------
    // 1. KHỐI BỘ ĐẾM BIT DỮ LIỆU (BIT_CNT)
    //---------------------------------------------------------
    reg [2:0] bit_cnt; 
    reg [2:0] max_val;

    // Chọn giá trị max_val dựa trên cấu hình data_num
    // Chỉ nhạy cảm với sự thay đổi của đầu vào data_num
    always @(data_num) begin
        case(data_num)
            2'b00:   max_val = 3'd4; // 5 bit (đếm từ 0 đến 4)
            2'b01:   max_val = 3'd5; // 6 bit (đếm từ 0 đến 5)
            2'b10:   max_val = 3'd6; // 7 bit (đếm từ 0 đến 6)
            2'b11:   max_val = 3'd7; // 8 bit (đếm từ 0 đến 7)
            default: max_val = 3'd7; // Mặc định an toàn là 8 bit
        endcase
    end

    // Bộ đếm lên đồng bộ với xung clk, chạy khi có tick_last
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            bit_cnt <= 3'd0;
        end
        else if(clr_bit) begin
            bit_cnt <= 3'd0;       // Reset bộ đếm khi FSM yêu cầu
        end
        else if(tick_last) begin
            bit_cnt <= bit_cnt + 3'd1; // Chỉ tăng 1 đơn vị mỗi chu kỳ baud
        end
    end

    // So sánh để phát cờ kết thúc đếm bit dữ liệu
    assign bit_last = (bit_cnt == max_val);


    //---------------------------------------------------------
    // 2. KHỐI BỘ ĐẾM BIT DỪNG (STOP_CNT)
    //---------------------------------------------------------
    reg [1:0] stop_cnt; 
    reg [1:0] max_stop_val;

    // Chọn giá trị giới hạn cho stop bit
    // Chỉ nhạy cảm với cấu hình stop_num
    always @(stop_num) begin
        case(stop_num)
            1'b0:    max_stop_val = 2'd1; // 1 stop bit -> Đếm đến 1 - 1 = 0
            1'b1:    max_stop_val = 2'd2; // 2 stop bit -> Đếm đến 2 - 1 = 1
            default: max_stop_val = 2'd1; 
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            stop_cnt <= 2'd0; 
        end
        else if(clr_stop) begin
            stop_cnt <= 2'd0;
        end
        else if(tick_last) begin
            stop_cnt <= stop_cnt + 2'd1;
        end
    end

    assign stop_last = (stop_cnt == max_stop_val - 2'd1);


    //---------------------------------------------------------
    // 3. KHỐI TÍNH TOÁN PARITY
    //---------------------------------------------------------
    reg  [DATA_NUM-1:0] mask;
    wire [DATA_NUM-1:0] masked_data; // Đã sửa kiểu reg thành wire vì gán bằng lệnh assign
    wire                even_parity_cal;
    wire                parity_bit;

    // Tạo mặt nạ để che các bit không sử dụng (dựa theo data_num)
    always @(data_num) begin
        case(data_num)
            2'b00:   mask = 8'b0001_1111; // Lọc lấy 5 bit LSB
            2'b01:   mask = 8'b0011_1111; // Lọc lấy 6 bit LSB
            2'b10:   mask = 8'b0111_1111; // Lọc lấy 7 bit LSB
            2'b11:   mask = 8'b1111_1111; // Lấy cả 8 bit
            default: mask = 8'b1111_1111;
        endcase
    end

    // Tính toán Parity (Mạch tổ hợp tự động cập nhật)
    assign masked_data     = tx_data & mask;  // Loại bỏ các bit rác phía trên
    assign even_parity_cal = ^masked_data;    // Phép XOR thu gọn để tính parity chẵn (Even)
    assign parity_bit      = parity_type ? even_parity_cal : ~even_parity_cal; // Chọn chẵn/lẻ


    //---------------------------------------------------------
    // 4. THANH GHI DỊCH PISO (Parallel-In Serial-Out)
    //---------------------------------------------------------
    reg  [DATA_NUM-1:0] reg_data;
    wire                serial_out;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            reg_data <= {DATA_NUM{1'b1}}; 
        end
        else if(load_reg) begin
            reg_data <= tx_data;          // Nạp dữ liệu song song từ ngõ vào
        end
        else if(shift_reg) begin
            // Dịch phải 1 bit (đẩy LSB ra ngoài), chèn 1 vào MSB để giữ đường tx ở mức cao
            reg_data <= {1'b1, reg_data[DATA_NUM-1:1]}; 
        end
    end

    // Dữ liệu nối tiếp luôn là bit có trọng số thấp nhất (LSB)
    assign serial_out = reg_data[0];


    //---------------------------------------------------------
    // 5. KHỐI DỒN KÊNH ĐẦU RA (OUTPUT MUX)
    //---------------------------------------------------------
    // Khối tổ hợp chỉ nhạy cảm với tín hiệu chọn và 2 ngõ ra động
    always @(tx_sel or serial_out or parity_bit) begin
        case(tx_sel)
            2'b00:   tx = 1'b0;       // Kéo xuống 0 để truyền Start bit
            2'b01:   tx = 1'b1;       // Kéo lên 1 để truyền Stop bit (hoặc duy trì mức IDLE)
            2'b10:   tx = serial_out; // Đẩy luồng dữ liệu nối tiếp ra ngoài
            2'b11:   tx = parity_bit; // Xuất bit kiểm tra chẵn lẻ
            default: tx = 1'b1;       // Trạng thái an toàn mặc định là mức nghỉ (Idle)
        endcase
    end

endmodule