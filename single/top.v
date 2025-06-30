`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/06 09:14:11
// Design Name: 
// Module Name: top
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

module top(
    input clk,
    input rstn,
    input [15:0] sw_i,
    output [7:0] disp_seg_o,
    output [7:0] disp_an_o
);

reg [31:0] clkdiv;
wire clk_cpu;

//clock divider
always @(posedge clk or negedge rstn) begin
    if (!rstn)
        clkdiv <= 0;
    else
        clkdiv <= clkdiv + 1'b1;
end

assign clk_cpu = (sw_i[15]) ? clkdiv[27] : clkdiv[25];  //如果不行的话就把频率再降低一点，应该能够在这个频率下完成所有操作

// led
reg [63:0] display_data;
reg [5:0] led_data_addr;
reg [63:0] led_disp_data;

//rom
wire [31:0] instr;
reg [63:0] rom_addr;

//reg
reg [31:0] reg_data;
reg [4:0] reg_addr;
wire[31:0] rf_rd1, rf_rd2;

//alu
reg [31:0] alu_disp_data;
wire [31:0] alu_output;
reg [2:0] alu_disp;
wire zero;

//dmem
reg [31:0] dmem_data;
reg [31:0] dmem_addr;
wire [31:0] dmem_output;

//decoder
wire [6:0] op;
wire [6:0] funct7;
wire [2:0] funct3;
wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;
wire [11:0] iimm;
wire [11:0] simm;
wire [4:0] iimm_shamt;
wire [11:0] bimm;
wire [19:0] uimm,jimm;

parameter LED_DATA_NUM = 19;
parameter ROM_ADDR_NUM = 12; //change 64 into 12 because their only 12 instr
parameter REG_ADDR_NUM = 32;
parameter DMEM_ADDR_NUM = 16;
reg [63:0] LED_DATA [18:0];

initial begin
    LED_DATA[0] = 64'hC6F6F6F0C6F6F6F0;
    LED_DATA[1] = 64'hF9F6F6CFF9F6F6CF;
    LED_DATA[2] = 64'hFFC6F0FFFFC6F0FF;
    LED_DATA[3] = 64'hFFC0FFFFFFC0FFFF;
    LED_DATA[4] = 64'hFFA3FFFFFFA3FFFF;
    LED_DATA[5] = 64'hFFFFA3FFFFFFA3FF;
    LED_DATA[6] = 64'hFFFF9CFFFFFF9CFF;
    LED_DATA[7] = 64'hFF9EBCFFFF9EBCFF;
    LED_DATA[8] = 64'hFF9CFFFFFF9CFFFF;
    LED_DATA[9] = 64'hFFC0FFFFFFC0FFFF;
    LED_DATA[10] = 64'hFFA3FFFFFFA3FFFF;
    LED_DATA[11] = 64'hFFA7B3FFFFA7B3FF;
    LED_DATA[12] = 64'hFFC6F0FFFFC6F0FF;
    LED_DATA[13] = 64'hF9F6F6CFF9F6F6CF;
    LED_DATA[14] = 64'h9EBEBEBC9EBEBEBC;
    LED_DATA[15] = 64'h2737373327373733;
    LED_DATA[16] = 64'h505454EC505454EC;
    LED_DATA[17] = 64'h744454F8744454F8;
    LED_DATA[18] = 64'h0062080000620800;
end

npc U_NPC(
.PC(U_PC.PC),
.NPCOp(U_CTRL.NPCOp),
.Imm(U_EXT.immout),
.aluout(U_ALU.C),
.NPC(NPC));

pc U_PC(
.clk(clk_cpu),
.rstn(rstn),
.NPC(U_NPC.NPC),
.pause(sw_i[1]),
.test(sw_i[5:2]),
.PC(PC));

dist_mem_gen_0 U_IM(.a(U_PC.PC[8:2]),.spo(instr));

//decode
assign op = instr[6:0];
assign funct7 = instr[31:25];
assign funct3 = instr[14:12];
assign rs1 = instr[19:15];
assign rs2 = instr[24:20];
assign rd = instr[11:7];

assign iimm=instr[31:20];//addi 指令立即数，lw指令立即数
assign simm={instr[31:25],instr[11:7]}; //sw指令立即数
assign iimm_shamt=instr[24:20];
assign bimm={instr[31],instr[7],instr[30:25],instr[11:8]};
assign uimm=instr[31:12];
assign jimm={instr[31],instr[19:12],instr[20],instr[30:21]};

ctrl U_CTRL(
    .Op(op),
    .Funct7(funct7),
    .Funct3(funct3),
    .Zero(zero),
    .RegWrite(RegWrite),
    .MemWrite(MemWrite),
    .EXTOp(EXTOp),
    .ALUOp(ALUOp),
    .NPCOp(NPCOp),
    .ALUSrc(ALUSrc), // output: ALU source for B
    .DMType(DMType), // output: dm r/w type
    .WDSel(WDSel) // (register) write data selection (MemtoReg)
);

regfile U_RF(
    .clk(clk_cpu),
    .rst(rstn),
    .RFWr(U_CTRL.RegWrite),
    .sw(sw_i),
    .A1(rs1),
    .A2(rs2),
    .A3(rd),
    .WD(U_WB_MUX.WD),
    .RD1(RD1),
    .RD2(RD2)
);

ext U_EXT(
    .iimm_shamt(iimm_shamt),
    .iimm(iimm),
    .simm(simm),
    .bimm(bimm),
	.uimm(uimm),
	.jimm(jimm),
    .EXTOp(U_CTRL.EXTOp),
    .immout(immout)
);

wb_mux U_WB_MUX(
    .WDSel(U_CTRL.WDSel),
    .aluout(U_ALU.C),
    .dout(U_DM.dout),
    .PC(U_PC.PC),
    .WD(WD)
);

alu_mux U_ALU_MUX(
    .immout(U_EXT.immout),
    .RD2(U_RF.RD2),
    .ALUSrc(U_CTRL.ALUSrc),
    .B(B)
);

alu U_ALU(
    .A(U_RF.RD1),
    .B(U_ALU_MUX.B),
    .ALUOp(U_CTRL.ALUOp),
    .C(alu_output),
    .zero(zero)  
);

dm U_DM(
     .clk(clk_cpu),
     .DMWr(MemWrite),  //avoid unexpected modification
     .addr(U_ALU.C),  //store instr
     .din(U_RF.RD2),
     .DMType(U_CTRL.DMType),
     .dout(dmem_output)
);

seg7x16 u_seg7x16 (
    .clk(clk),
    .rstn(rstn),
    .mode(sw_i[0]),
    .data(display_data),
    .seg(disp_seg_o),
    .sel(disp_an_o)
);

//this always block is used to demostrate the state of each component
always @(posedge clk_cpu or negedge rstn) begin
    //clear
    if (!rstn) begin
        led_data_addr <= 6'd0;
        rom_addr <= 0;
        reg_addr <= 0;
        alu_disp <= 0;
        dmem_addr <= 0;
        led_disp_data <= 64'hFFFFFFFFFFFFFFFF;
    
    // sw_i[0]=1 sleep
    end else if (sw_i[0] == 1'b1)begin                                               
        if (led_data_addr == LED_DATA_NUM) begin
            led_data_addr <= 6'd0;
            led_disp_data <= 64'hFFFFFFFFFFFFFFFF;
        end else begin
            led_disp_data <= LED_DATA[led_data_addr];           
            led_data_addr <= led_data_addr + 1'b1;
        end
    
    //display other parts' contents
    end else begin
        //display ROM //这部分目前有点问题，没办法暂停PC去查看各部分的状态，可以考虑在PC模块加一个pause信号（sw_i控制）
        if(sw_i[14] == 1'b1)begin
            if(sw_i[1] == 1'b0)begin
                if (rom_addr == ROM_ADDR_NUM)begin
                    rom_addr <= 0;
                end else begin
                    rom_addr <= rom_addr + 1;
                end
            end
            else begin rom_addr = rom_addr; end
        end
        //display REG_FILE
        else if(sw_i[13] == 1)begin
            if(reg_addr == REG_ADDR_NUM)begin
                reg_addr<=0;
                reg_data <= 32'hFFFFFFFF;
            end else begin
                reg_addr <= reg_addr + 1'b1;
                reg_data <= U_RF.rf[reg_addr];
            end
        end
        //display ALU
        else if(sw_i[12] == 1'b1) begin
            case(alu_disp)
            3'b000: alu_disp_data <= U_ALU.A;
            3'b001: alu_disp_data <= U_ALU.B;
            3'b010: alu_disp_data <= U_ALU.C;
            3'b011:  alu_disp_data <= {31'b0, U_ALU.zero};                    // Show Zero flag
            3'b100:  alu_disp_data <= 32'hFFFFFFFF;                     // Show FFFFF
            default: alu_disp_data <= 32'h0;
            endcase
            if(alu_disp == 3'b100) begin
                alu_disp <= 3'b000;
            end
            else begin
                alu_disp <= alu_disp + 1'b1;
            end
        end
        //display datamem
        else if(sw_i[11] == 1'b1) begin
            if(dmem_addr == DMEM_ADDR_NUM)begin
                dmem_addr <= 0;
                dmem_data = 32'hFFFFFFFF;
            end
            else begin
                dmem_addr <= dmem_addr + 1'b1;
                dmem_data = U_DM.dmem[dmem_addr][7:0];
                //dmem_data = {dmem_addr, {dmem_data[27:0]}};  //we need to display the adderss too?
            end
        end
        
    end
end


//accrording to swirtch, pick the corresponding signal to displays
always @(sw_i) begin
    if (sw_i[0] == 1'b0) begin
        case (sw_i[14:11])
            4'b1000: display_data = instr; // ROM
            4'b0100: display_data = reg_data; // RF
            4'b0010: display_data = alu_disp_data; // ALU
            4'b0001: display_data = dmem_data; // DMEM
            default: display_data = instr;//? ? ?ROM
        endcase
    end else begin
        display_data = led_disp_data;
    end
end


endmodule