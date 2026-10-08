.data
  # Matrix A: 64
  Matrix_A: .word 1, 2, 3, 4, 5, 6, 7, 8
            .word 1, 1, 1, 1, 1, 1, 1, 1
            .word 1, 1, 1, 1, 1, 1, 1, 1
            .word 1, 1, 1, 1, 1, 1, 1, 1
            .word 1, 1, 1, 1, 1, 1, 1, 1
            .word 1, 1, 1, 1, 1, 1, 1, 1
            .word 1, 1, 1, 1, 1, 1, 1, 1
            .word 1, 1, 1, 1, 1, 1, 1, 1

  # Vector X: 8
  Vector_X: .word 1, 1, 1, 1, 1, 1, 1, 1

  # Vector Y (output): 8 
  Vector_Y: .word 0, 0, 0, 0, 0, 0, 0, 0

.text
.globl main
main:
  # Base Addresses
  la s0, Matrix_A      # base address Matrix A
  la s1, Vector_X      # base address Vector X
  la s2, Vector_Y      # base address Vector Y

  mv t0, s0            # con trỏ trượt cho A (copy địa chỉ s0(A) vào t0)
  mv t1, s2            # con trỏ trượt cho Y (copy địa chỉ s2(Y) vào t1)
  li t2, 8             # t2 = dem 8 hang


outer_loop:
  beqz t2, end_program # Xong 8 thi xuong end_program ngay

  li t3, 0             # Bien t3 = sum of row
  mv t4, s1            # t4 = reset con tro ve dau vector X(s1)
  li t5, 8             # t5 = dem 8 cot (vong trong)

inner_loop:
  lw t6, 0(t0)         # Load phan tu cua A
  lw a3, 0(t4)         # Load phan tu cua X
  
  mul t6, t6, a3       # Nhan 2 phan tu
  add t3, t3, t6       # Cong don

  addi t0, t0, 4       # Tro sang word tiep theo cua A
  addi t4, t4, 4       # Tro sang word tiep theo cua X
  addi t5, t5, -1      # Giam dem cot
  bnez t5, inner_loop  # Neu t5 chua ve 0 thi lap lai

end_inner:
  sw t3, 0(t1)         # Luu sum vao Vector Y
  addi t1, t1, 4       # Tien con tro Vector Y
  addi t2, t2, -1      # Giam dem hang
  j outer_loop         # jump ve outer_loop

end_program:
  li a7, 10            # System call thoat chuong trinh
  ecall