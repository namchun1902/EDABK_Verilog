module uart_baudrate
    #(  parameter FCLK = 50000000, // 50 MHz
        parameter BAUDRATE = 115200,
        parameter OS = 1 // TX: OS = 1; RX: OS = 16
    )
    (input  clk,
    input   rst_n,
    output reg tick_last);

    // Tính giá trị D
    localparam integer D = (FCLK / (OS * BAUDRATE)); // D = round(f_clk / (os*baudreate))
    localparam integer COUNTER_WIDTH = $clog2(D);

    reg [COUNTER_WIDTH-1:0] count;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            count <= 0;
            tick_last <= 0;
        end
        else if (count == D - 1) begin
            count <= 0;
            tick_last <= 1'b1;
        end
        else begin
            count <= count + 1'b1;
            tick_last <= 0;
        end
    end
endmodule