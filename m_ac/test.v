
reg [15:0] sram_a_bank0 [0:15];
reg [15:0] sram_a_bank1 [0:15];
reg [15:0] sram_a_bank2 [0:15];
reg [15:0] sram_a_bank3 [0:15];


//tb
// Sinh dữ liệu và nạp vào bank
for (i = 0; i < 16; i = i + 1) begin
    sram_a_bank0[i] = random_vector[i*4 + 0]; // Nạp a0, a4, a8...
    sram_a_bank1[i] = random_vector[i*4 + 1]; // Nạp a1, a5, a9...
    sram_a_bank2[i] = random_vector[i*4 + 2]; // Nạp a2, a6, a10...
    sram_a_bank3[i] = random_vector[i*4 + 3]; // Nạp a3, a7, a11...
end