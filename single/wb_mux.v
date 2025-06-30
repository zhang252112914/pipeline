`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/15 00:40:52
// Design Name: 
// Module Name: wb_mux
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
`define WDSel_FromALU 2'b00
`define WDSel_FromMEM 2'b01
`define WDSel_FromPC 2'b10

module wb_mux(
    input [1:0] WDSel,
    input [31:0] aluout,
    input [31:0] dout,
    input [31:0] PC,
    output reg [31:0] WD
    );
    always @(*) begin
        case(WDSel)
            `WDSel_FromALU: WD <= aluout;
            `WDSel_FromMEM: WD <= dout;
            `WDSel_FromPC: WD <= PC + 4;
        endcase
    end
endmodule
