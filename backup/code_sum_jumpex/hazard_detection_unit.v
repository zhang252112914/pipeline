// Hazard Detection Unit
// Handles load-use hazards and control hazards
module hazard_detection_unit(
    input [4:0] rs1_ID,           // source register 1 in ID stage
    input [4:0] rs2_ID,           // source register 2 in ID stage  
    input [4:0] rd_EX,            // destination register in EX stage
    input [4:0] rd_MEM,           // destination register in MEM stage
    input RegWrite_EX,            // register write enable in EX stage
    input RegWrite_MEM,           // register write enable in MEM stage
    input MemRead_EX,             // memory read in EX stage (load instruction)
    input branch_taken,           // branch taken signal
    
    output reg stall,             // stall the pipeline
    output reg flush_IFID,        // flush IF/ID register
    output reg flush_IDEX         // flush ID/EX register
);

    // Load-use hazard detection
    wire load_use_hazard;
    assign load_use_hazard = MemRead_EX && RegWrite_EX && rd_EX != 0 &&
                            ((rd_EX == rs1_ID) || (rd_EX == rs2_ID));

    always @(*) begin
        // Default values
        stall = 1'b0;
        flush_IFID = 1'b0;
        flush_IDEX = 1'b0;
        
        // Handle load-use hazard
        if (load_use_hazard) begin
            stall = 1'b1;        // Stall IF and ID stages
            flush_IDEX = 1'b1;   // Insert bubble in EX stage
        end
        
        // Handle control hazard (branch taken)
        if (branch_taken) begin
            flush_IFID = 1'b1;   // Flush wrong instruction in IF/ID
            flush_IDEX = 1'b1;   // Flush wrong instruction in ID/EX
        end
    end

endmodule
