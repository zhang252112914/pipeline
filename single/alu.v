`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/06 08:55:13
// Design Name: 
// Module Name: alu
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
`define ALUOp_nop 5'b00000
`define ALUOp_lui 5'b00001
`define ALUOp_auipc 5'b00010
`define ALUOp_add 5'b00011
`define ALUOp_sub 5'b00100
`define ALUOp_bne 5'b00101
`define ALUOp_blt 5'b00110
`define ALUOp_bge 5'b00111
`define ALUOp_bltu 5'b01000
`define ALUOp_bgeu 5'b01001
`define ALUOp_slt 5'b01010
`define ALUOp_sltu 5'b01011
`define ALUOp_xor 5'b01100
`define ALUOp_or 5'b01101
`define ALUOp_and 5'b01110
`define ALUOp_sll 5'b01111
`define ALUOp_srl 5'b10000
`define ALUOp_sra 5'b10001

module alu(
input signed [31:0] A, B,
input [4:0] ALUOp,
input [31:0] PC,
output signed [31:0] C,
output reg zero
    );
    
    reg signed [31:0] res;
    assign C = res;
    
    always@(*) begin
        case(ALUOp)
            `ALUOp_nop:res=A;
            `ALUOp_lui:res=B;
            `ALUOp_auipc:res=PC+B;
            `ALUOp_add:res=A+B;
            `ALUOp_sub:res=A-B;
            `ALUOp_bne:res={31'b0,(A==B)};
            `ALUOp_blt:res={31'b0,(A>=B)};
            `ALUOp_bge:res={31'b0,(A<B)};
            `ALUOp_bltu:res={31'b0,($unsigned(A)>=$unsigned(B))};
            `ALUOp_bgeu:res={31'b0,($unsigned(A)<$unsigned(B))};
            `ALUOp_slt:res={31'b0,(A<B)};
            `ALUOp_sltu:res={31'b0,($unsigned(A)<$unsigned(B))};
            `ALUOp_xor:res=A^B;
            `ALUOp_or:res=A|B;
            `ALUOp_and:res=A&B;
            `ALUOp_sll:res=A<<B;
            `ALUOp_srl:res=A>>B;
            `ALUOp_sra:res=A>>>B;
            default: res = 0;
        endcase
        zero = (res == 32'b0);
    end
    
endmodule
