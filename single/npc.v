`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/18 23:49:55
// Design Name: 
// Module Name: npc
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
`include "def.v"

module npc(
input [31:0]PC,
input [2:0]NPCOp,
input [31:0]Imm,
input [31:0]aluout,
output reg [31:0] NPC
    );
    wire [31:0] PCPLUS4;
    assign PCPLUS4 = PC + 4;
    
    always @(*) begin
        case(NPCOp)
          `NPC_PLUS4:  NPC = PCPLUS4;
          `NPC_BRANCH: NPC = PC+Imm;
          `NPC_JUMP:   NPC = PC+Imm;
		  `NPC_JALR:   NPC =aluout;
          default:     NPC = PCPLUS4;
       endcase  
    end
endmodule
