module pipeline_sccomp(clk, rstn, sw_i, reg_sel, reg_data, disp_seg_o, disp_an_o);
   input          clk;
   input          rstn;
   input [15:0]   sw_i;  // 15-speed, 14-11: instr, reg, alu, dmem; 1-pause; 0-display
   input [4:0]    reg_sel;
   output [31:0]  reg_data;
   output [7:0]   disp_seg_o;
   output [7:0]   disp_an_o;
   
   // link between every part
   wire [31:0]    instr;
   wire [31:0]    PC;
   wire           MemWrite;
   wire [31:0]    dm_addr, dm_din, dm_dout;
   wire [2:0] dm_type;
   wire rst = ~rstn;

   wire cpu_pause;
   assign cpu_pause = sw_i[1];

   // divide clock for display
   reg [31:0] clkdiv;
   wire clk_cpu;
   wire clk_select;

   // for display
   reg [63:0] display_data;
   reg [63:0] led_disp_data = 64'hFFFFFFFFFFFFFFFF;
   parameter REG_ADDR_NUM = 32;
   parameter DMEM_ADDR_NUM = 128;
   wire [31:0] alu_disp_data;
   reg [31:0] reg_disp_data;
   reg [31:0] dmem_data;
   reg [4:0] reg_addr;
   reg [6:0] dmem_addr;

   //clock divider
   always @(posedge clk or negedge rstn) begin
      if (!rstn)
         clkdiv <= 0;
      else
         clkdiv <= clkdiv + 1'b1;
   end
   assign clk_select = (sw_i[15]) ? clkdiv[26] : clk;  //speed up and slow down, 0 stands for speed up, 1 stands for slow down
   assign clk_cpu = cpu_pause ? 1'b0 : clk_select;

  // instantiation of pipeline CPU   
   pipeline_cpu U_pipeline_CPU(
         .clk(clk_cpu),                 // input:  cpu clock
         .reset(rst),               // input:  reset
         .inst_in(instr),           // input:  instruction
         .Data_in(dm_dout),         // input:  data to cpu  
         .mem_w(MemWrite),          // output: memory write signal
         .PC_out(PC),               // output: PC
         .Addr_out(dm_addr),        // output: address from cpu to memory
         .Data_out(dm_din),         // output: data from cpu to memory
         .DMType_out(dm_type),         // output: data memory type
         .reg_sel(reg_sel),         // input:  register selection
         .reg_data(reg_data)        // output: register data
         );

   // instantiation of data memory  
   dm    U_DM(
         .clk(clk_cpu),           // input:  cpu clock
         .DMWr(MemWrite),     // input:  ram write
         .addr(dm_addr), // input:  ram address
         .din(dm_din),        // input:  data to ram
         .DMType(dm_type),
         .dout(dm_dout)       // output: data from ram
         );
         
  // instantiation of instruction memory (used for simulation)
  // in vivado, this need to be replaced with a block memory
   im    U_IM ( 
      .addr(PC[8:2]),     // input:  rom address
      .dout(instr)        // output: instruction
   );

   seg7x16 u_seg7x16 (
      .clk(clk),
      .rstn(rstn),
      .mode(sw_i[0]),
      .data(display_data),
      .seg(disp_seg_o),
      .sel(disp_an_o)
   );

   assign alu_disp_data = U_pipeline_CPU.EXMEM_ALUOut; // ALU output

   //this always block is used to demostrate the state of each component
   always @(posedge clk_cpu or negedge rstn) begin
      //clear
      if (!rstn) begin
         reg_addr <= 0;
         dmem_addr <= 0;
         led_disp_data <= 64'hFFFFFFFFFFFFFFFF;
      //display other parts' contents
      end else begin
         if(sw_i[13] == 1)begin
               if(reg_addr == REG_ADDR_NUM)begin
                  reg_addr <= 0;
                  reg_disp_data <= 32'hFFFFFFFF;
               end else begin
                  reg_addr <= reg_addr + 1'b1;
                  reg_disp_data <= U_pipeline_CPU.U_RF.rf[reg_addr];
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
                  dmem_data = U_DM.dmem[dmem_addr][31:0];
                  //dmem_data = {dmem_addr, {dmem_data[27:0]}};  //we need to display the adderss too?
               end
         end
      end
   end

   //accrording to swirtch, pick the corresponding signal to displays
   always @(sw_i) begin
      if (sw_i[0] == 1'b0) begin  // if sw_i[0] is 0, display the current state of the pipeline
         case (sw_i[14:11])
               4'b1000: display_data = instr; // ROM
               4'b0100: display_data = reg_disp_data; // RF
               4'b0010: display_data = alu_disp_data; // ALU
               4'b0001: display_data = dmem_data; // DMEM
               default: display_data = instr;// ROM
         endcase
      end else begin  // if sw_i[0] is 1, display specific data in linear order
         display_data = led_disp_data;
      end
   end
        
endmodule