`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/02 19:50:38
// Design Name: 
// Module Name: regfile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module regfile(
    input clk,                    // Clock input
    input rst,                    // Reset signal
    input RFWr,                  // Write enable
    input [15:0] sw,           // Switch inputs
    input [4:0] A1, A2, A3,      // Register addresses
    input [31:0] WD,             // Write data
    output reg [31:0] RD1, RD2   // Read data outputs
    );
    integer i;
    reg [31:0] rf [0:31];  //mock the 32 registers
    initial begin
        for(i = 0; i < 32; i = i + 1) begin
            rf[i] <= 0;
        end
    end
    
    //Read operation
    always @(*)begin
        // to ensure the r0 always be 0, we ignore the original data in rf[0], instead returning 0 when some behaviour tends to achieve r0
        RD1 = (A1 == 0) ? 32'b0 : rf[A1];
        RD2 = (A2 == 0) ? 32'b0 : rf[A2];
    end

    //Write operation
    always @(posedge clk or negedge rst)begin
        if(!rst) begin
            for(i = 0; i < 32; i = i + 1) begin
                rf[i] <= 0;
            end
        end
        else begin
            if(RFWr && (!sw[1])) begin
                rf[A3] <= WD;
            end
            rf[0] <= 32'b0;  //做一下维护，虽然没什么必要
        end
    end
    
endmodule
