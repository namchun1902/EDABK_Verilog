#include <iostream>

int main() {
    // Matrix A: 64 phần tử (Mảng 1 chiều)
    int Matrix_A[64] = {
        1, 2, 3, 4, 5, 6, 7, 8,
        1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1
    };

    // Vector X: 8 phần tử
    int Vector_X[8] = {1, 1, 1, 1, 1, 1, 1, 1};

    // Vector Y (output): 8 phần tử
    int Vector_Y[8] = {0, 0, 0, 0, 0, 0, 0, 0};

    // ----------------- .text -----------------
    
    // Base Addresses (la s0, la s1, la s2)
    int* ptr_A = Matrix_A;   // mv t0, s0 (Con trỏ trượt cho Matrix A)
    int* ptr_Y = Vector_Y;   // mv t1, s2 (Con trỏ trượt cho Vector Y)
    
    int row_count = 8;       // li t2, 8  (Đếm 8 hàng)

// outer_loop:
    while (row_count != 0) { // beqz t2, end_program
        
        int sum = 0;               // li t3, 0 (Biến lưu tổng của 1 hàng)
        int* ptr_X = Vector_X;     // mv t4, s1 (Reset con trỏ về đầu Vector X)
        int col_count = 8;         // li t5, 8 (Đếm 8 cột)

// inner_loop:
        do { 
            int a_val = *ptr_A;    // lw t6, 0(t0)
            int x_val = *ptr_X;    // lw t7, 0(t4)
            
            sum += (a_val * x_val);// mul t6, t6, t7  &&  add t3, t3, t6

            ptr_A++;               // addi t0, t0, 4 (Tăng con trỏ A lên 1 int / 4 bytes)
            ptr_X++;               // addi t4, t4, 4 (Tăng con trỏ X lên 1 int / 4 bytes)
            col_count--;           // addi t5, t5, -1
            
        } while (col_count != 0);  // bnez t5, inner_loop

// end_inner:
        *ptr_Y = sum;              // sw t3, 0(t1) (Lưu kết quả tính được vào Vector Y)
        ptr_Y++;                   // addi t1, t1, 4 (Tiến con trỏ Y lên 1 int)
        row_count--;               // addi t2, t2, -1 (Giảm đếm hàng)

    } // j outer_loop

// end_program:
    // In kết quả mảng Vector Y ra màn hình để kiểm chứng
    std::cout << "Ket qua Vector Y: ";
    for(int i = 0; i < 8; i++) {
        std::cout << Vector_Y[i] << " ";
    }
    std::cout << std::endl;

    return 0; // li a7, 10 && ecall
}
