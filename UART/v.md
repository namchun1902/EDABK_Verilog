  Chào bạn, mình đã kiểm tra các file trong thư mục RX (uart_rx.v, uart_rx_controller.v, uart_rx_datapath.v) và đối chiếu với file ở phần interface (apb_datapath.v).        
                                                                                                                                                                             
  Hiện tại, đầu vào và đầu ra giữa khối RX và khối Interface chưa khớp nhau. Dưới đây là 5 điểm lệch và lỗi logic cụ thể cần khắc phục:                                      
                                                                                                                                                                             
  ### 1. Không khớp độ rộng dữ liệu rx_data                                                                                                                                  
                                                                                                                                                                             
  • Ở apb_datapath.v: Khai báo cổng nhận dữ liệu là 8 bit: input wire [7:0] rx_data.                                                                                         
  • Ở uart_rx.v: Lại xuất dữ liệu ra 9 bit: output wire [8:0] rx_data.                                                                                                       
  (Thực tế trong uart_rx_datapath.v, cấu hình tối đa chỉ hỗ trợ 8 bit dữ liệu, nên rx_data ở RX có thể an toàn sửa thành [7:0] để đồng bộ).                                  
                                                                                                                                                                             
  ### 2. Không khớp tên các tín hiệu
                                                                                                                                                                             
  Tuy bạn có thể map tên port khi gọi module top, nhưng việc sai khác tên sẽ dễ gây nhầm lẫn:

  • Báo hoàn thành: apb_datapath.v dùng rx_done, trong khi uart_rx.v dùng rx_valid.                                                                                          
  • Báo lỗi Parity: apb_datapath.v dùng parity_error, trong khi uart_rx.v dùng parity_err.                                                                                   
                                                                                                                                                                             
  ### 3. Thiếu cổng nhận tín hiệu clear_rx_done
                                                                                                                                                                             
  • Ở apb_datapath.v: Khi CPU đọc thanh ghi dữ liệu RX qua APB bus, khối datapath tạo ra tín hiệu output wire clear_rx_done để báo xuống RX rằng dữ liệu đã được xử lý xong, 
  hãy hạ cờ ngắt/hoàn thành xuống.                                                                                                                                           
  • Ở uart_rx.v: Hoàn toàn không có cổng input nào tên là clear_rx_done để nhận tín hiệu này.                                                                                
                                                                                                                                                                             
  ### 4. Lỗi Logic liên quan đến việc giữ trạng thái ngắt (Lỗi nghiêm trọng nhất)                                                                                            
                                                                                                                                                                             
  • Ở uart_rx_datapath.v: Các cờ trạng thái như rx_valid (tức rx_done), parity_err, frame_err được thiết kế dưới dạng xung đơn (1-clock pulse) (chỉ bật lên mức 1 trong đúng 
  1 chu kỳ clock).                                                                                                                                                           
  • Ở apb_datapath.v: Thanh ghi trạng thái lại bắt trực tiếp: stt_reg <= {29'b0, parity_error, rx_done, tx_done};                                                            
  • Hệ quả: Vì nó là xung đơn, giá trị báo có dữ liệu hoặc báo lỗi sẽ bị chớp tắt trong 1 nhịp clock và ngay lập tức trở về 0. CPU khi đọc thanh ghi stt_reg qua APB Bus sẽ  
  gần như luôn thấy toàn số 0.                                                                                                                                               
  • Cách giải quyết:                                                                                                                                                         
      • Cách 1 (Khuyên dùng): Bên uart_rx.v phải thêm một ngõ vào clear_rx_done (đã nói ở trên). Khi nhận xong data, cờ rx_valid phải giữ nguyên ở mức 1 (latch). Nó chỉ bị  
      hạ xuống mức 0 khi tín hiệu clear_rx_done kéo lên 1. Tương tự cho các cờ lỗi.                                                                                          
      • Cách 2: Khối apb_datapath.v phải có logic tự chốt (latch) lại các xung nhịp này vào stt_reg và tự xóa khi CPU đọc xong.                                              
                                                                                                                                                                             
                                                                                                                                                                             
  ### 5. Khối Interface bỏ quên lỗi Frame Error (frame_err)                                                                                                                  
                                                                                                                                                                             
  • Ở uart_rx.v: Có xuất tín hiệu báo lỗi khung output wire frame_err (lỗi liên quan đến stop bit).                                                                          
  • Ở apb_datapath.v: Không hề có cổng input cho frame_error và tín hiệu này cũng không được đưa vào trong thanh ghi stt_reg để CPU có thể kiểm tra.                         
  ──────                                                                                                                                                                     
  Tóm lại, để hai phần này lắp được vào nhau và CPU có thể đọc APB chuẩn, cần sửa code. Bạn muốn mình viết lại logic đồng bộ để sửa trực tiếp vào các file trên luôn không?  
  (Theo hướng sửa module RX để nó giữ cờ (latch) và nhận tín hiệu clear_rx_done).  