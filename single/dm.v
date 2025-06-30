`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/06 11:18:12
// Design Name: 
// Module Name: dm
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

`define DM_BYTE 3'b011
`define DM_HWORD 3'b001
`define DM_WORD 3'b000

`define dm_word 3'b000
`define dm_halfword 3'b001
`define dm_halfword_unsigned 3'b010
`define dm_byte 3'b011
`define dm_byte_unsigned 3'b100

module dm(
    input clk,  //100MHZ CLK
    input DMWr,  //write signal
    //input [5:0] addr,
    input [8:0]	addr,
    input [31:0] din,
    input [2:0] DMType, 
    //output reg[31:0] dout
    output [31:0] dout 
 );
    reg [31:0] dd;
    reg [7:0] dmem[511:0];
    always @(posedge clk) begin
      if (DMWr) begin
		case(DMType)
			`dm_word:begin
		dmem[addr] <= din[7:0];
		dmem[addr+1] <= din[15:8];
		dmem[addr+2] <= din[23:16];
		dmem[addr+3] <= din[31:24];
			end
			`dm_halfword:begin
		dmem[addr] <= din[7:0];
		dmem[addr+1] <= din[15:8];
			end
			`dm_halfword_unsigned:begin
		dmem[addr] <= din[7:0];
		dmem[addr+1] <= din[15:8];
			end
			`dm_byte:dmem[addr] <= din[7:0];
			`dm_byte_unsigned:dmem[addr] <= din[7:0];
		endcase
      end
	$display("DMTy = 0x%x,",DMType);
	$display("addr = 0x%x,",addr);
	//$display("dmem[addr] = 0x%2x",dmem[addr]);
	end
	
always @(*) begin

		case(DMType)
			`dm_word: dd <= {dmem[addr+3],dmem[addr+2],dmem[addr+1],dmem[addr]};
			`dm_halfword: dd <= {{16{dmem[addr+1][7]}},dmem[addr+1],dmem[addr]};
			`dm_halfword_unsigned: dd <= {16'b0,dmem[addr+1],dmem[addr]};
			`dm_byte: dd <= {{24{dmem[addr][7]}},dmem[addr]};
			`dm_byte_unsigned: dd <= {24'b0,dmem[addr]};
		endcase
end
assign dout=dd;
endmodule    
 
//    reg[7:0] dmem [15:0]; //every union is a byte
//    wire [5:0] byte_addr = addr;
//    integer i;
//    // Initialize the mem = 0
//    initial begin
//        for(i = 0; i < 16; i = i + 1) begin
//            dmem[i] = 8'b0;  // 每个字节初始化为0
//        end
//    end
    
//    always@(*)begin
//        case(DMType)
//            `DM_BYTE: dout = {{24{dmem[byte_addr][7]}}, dmem[byte_addr]};  //sign expand
//            `DM_HWORD: dout = {{16{dmem[byte_addr+1][7]}}, dmem[byte_addr+1], dmem[byte_addr]};
//            `DM_WORD: dout = {dmem[byte_addr+3], dmem[byte_addr+2], dmem[byte_addr+1], dmem[byte_addr]};
//            default: dout = 32'b0;
//        endcase
//    end
    
//    always@(posedge clk)begin
//        if(DMWr)begin
//            case(DMType)
//                `DM_BYTE: dmem[byte_addr] <= din[7:0];
//                `DM_HWORD: begin
//                    dmem[byte_addr+1] <= din[15:8];
//                    dmem[byte_addr] <= din[7:0];
//                end
//                `DM_WORD: begin
//                    dmem[byte_addr] <= din[7:0];
//                    dmem[byte_addr+1] <= din[15:8];
//                    dmem[byte_addr+2] <= din[23:16];
//                    dmem[byte_addr+3] <= din[31:24];
//                end
//            endcase
//        end
//    end
    
//endmodule
