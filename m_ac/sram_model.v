// File: sram_model.v
// Description: Behavioral model of a single-port SRAM with a 1-cycle read latency.
// This is for SIMULATION ONLY and is NOT synthesizable.

module sram_model #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 6
)(
    input wire clk,
    input wire [ADDR_WIDTH-1:0] addr,
    output reg [DATA_WIDTH-1:0] data_out
);

    // Memory array
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    // Initialize memory from a file (optional, but very useful)
    // Example: initial $readmemh("a.txt", mem);
    // For now, we can initialize with sample data for testing.
    initial begin
        integer i;
        for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin
            mem[i] = i; // Example: data equals address
        end
    end

    // Read logic with 1-cycle latency
    // When 'addr' changes, 'data_out' will be updated on the *next* positive clock edge.
    always @(posedge clk) begin
        data_out <= mem[addr];
    end

endmodule