`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/18 23:44:46
// Design Name: 
// Module Name: pc
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


module pc(
input clk,
input rstn,
input [31:0]NPC,
input [3:0]test,
input pause,
output reg[31:0]PC
    );
    always@(posedge clk, posedge rstn)begin
        if(!rstn)begin
            case(test)
            4'b0000:PC <= 32'h0000_0000; //beq
            4'b0001:PC <= 32'h0000_0080; //bne
            4'b0010:PC <= 32'h0000_0100; //blt
            4'b0011:PC <= 32'h0000_0180; //bge
            4'b0100:PC <= 32'h0000_0200; //bltu
            4'b0101:PC <= 32'h0000_0280; //bgeu
            4'b0110:PC <= 32'h0000_0300; //jal
            4'b0111:PC <= 32'h0000_037c; //jalr   
            4'b1000:PC <= 32'h0000_03f0; //sll
            4'b1001:PC <= 32'h0000_0410; //srl 
            4'b1010:PC <= 32'h0000_0430; //sra 
            endcase
        end
        else if (!pause) PC <= NPC;
        else PC <= PC;
    end
endmodule
