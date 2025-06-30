// Forwarding Unit
// Handles data hazards through forwarding
module forwarding_unit(
    input [4:0] rs1_EX,          // source register 1 in EX stage
    input [4:0] rs2_EX,          // source register 2 in EX stage
    input [4:0] rd_MEM,          // destination register in MEM stage
    input [4:0] rd_WB,           // destination register in WB stage
    input RegWrite_MEM,          // register write enable in MEM stage
    input RegWrite_WB,           // register write enable in WB stage
    
    output reg [1:0] forwardA,   // forwarding control for ALU input A
    output reg [1:0] forwardB    // forwarding control for ALU input B
);

    // Forward control encoding:
    // 00: No forwarding (use data from ID/EX register)
    // 01: Forward from WB stage (MEM/WB register)
    // 10: Forward from MEM stage (EX/MEM register)

    always @(*) begin
        // Default: no forwarding
        forwardA = 2'b00;
        forwardB = 2'b00;
        
        // EX hazard (forwarding from MEM stage)
        // Forward if:
        // 1. MEM stage writes to a register
        // 2. The register being written is not x0
        // 3. The register being written matches rs1 or rs2 in EX stage
        if (RegWrite_MEM && (rd_MEM != 0) && (rd_MEM == rs1_EX)) begin
            forwardA = 2'b10;
        end
        
        if (RegWrite_MEM && (rd_MEM != 0) && (rd_MEM == rs2_EX)) begin
            forwardB = 2'b10;
        end
        
        // MEM hazard (forwarding from WB stage)
        // Forward if:
        // 1. WB stage writes to a register
        // 2. The register being written is not x0  
        // 3. The register being written matches rs1 or rs2 in EX stage
        // 4. EX hazard condition is not met (MEM stage has higher priority)
        if (RegWrite_WB && (rd_WB != 0) && (rd_WB == rs1_EX) && 
            !(RegWrite_MEM && (rd_MEM != 0) && (rd_MEM == rs1_EX))) begin
            forwardA = 2'b01;
        end
        
        if (RegWrite_WB && (rd_WB != 0) && (rd_WB == rs2_EX) &&
            !(RegWrite_MEM && (rd_MEM != 0) && (rd_MEM == rs2_EX))) begin
            forwardB = 2'b01;
        end
    end

endmodule
