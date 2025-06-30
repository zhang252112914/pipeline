`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 09:59:04
// Design Name: 
// Module Name: seg7x16
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


module seg7x16(
    input clk,
    input rstn,
    input mode,
    input [63:0] data,
    output reg [7:0] seg,
    output reg [7:0] sel
);

    wire clk_1k;
    reg [2:0] addr;
    reg [7:0] seg_data;
    reg [63:0] data_store;
    
    clock_divider #(
        .COUNT(50000)
    ) cd_1khz (
        .clk_in(clk),
        .reset(~rstn),
        .clk_out(clk_1k)
    );
    
    always @(posedge clk_1k or negedge rstn) begin
        if (!rstn) begin
            addr <= 3'b000;
            sel <= 8'b11111111;
        end else begin
            if (addr == 3'b111) begin
                addr <= 3'b000;
                sel <= 8'b11111110;
            end else begin
                sel <= {sel[6:0], sel[7]};
                addr <= addr + 1;
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            data_store <= 0;
        end else begin
            data_store <= data;
        end
    end
    
    always @(*) begin
        if (mode == 1'b0) begin
            case (addr)
                0 : seg_data = data_store[3:0];
                1 : seg_data = data_store[7:4];
                2 : seg_data = data_store[11:8];
                3 : seg_data = data_store[15:12];
                4 : seg_data = data_store[19:16];
                5 : seg_data = data_store[23:20];
                6 : seg_data = data_store[27:24];
                7 : seg_data = data_store[31:28];
                default: seg_data = 0;
            endcase
        end else begin
            case (addr)
                0 : seg_data = data_store[7:0];
                1 : seg_data = data_store[15:8];
                2 : seg_data = data_store[23:16];
                3 : seg_data = data_store[31:24];
                4 : seg_data = data_store[39:32];
                5 : seg_data = data_store[47:40];
                6 : seg_data = data_store[55:48];
                7 : seg_data = data_store[63:56];
                default: seg_data = 0;
            endcase
        end
    end
    
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            seg <= 8'b11111111;
        end else if (mode == 1'b0) begin
            case (seg_data)
                4'h0: seg = 8'b11000000;
                4'h1: seg = 8'b11111001;
                4'h2: seg = 8'b10100100;
                4'h3: seg = 8'b10110000;
                4'h4: seg = 8'b10011001;
                4'h5: seg = 8'b10010010;
                4'h6: seg = 8'b10000010;
                4'h7: seg = 8'b11111000;
                4'h8: seg = 8'b10000000;
                4'h9: seg = 8'b10010000;
                4'ha: seg = 8'b10001000;
                4'hb: seg = 8'b10000011;
                4'hc: seg = 8'b11000110;
                4'hd: seg = 8'b10100001;
                4'he: seg = 8'b10000110;
                4'hf: seg = 8'b10001110;
                default: seg = 8'b11111111;
            endcase
        end else begin
            seg = seg_data;
        end
    end

endmodule