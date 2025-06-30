module pipeline_sccomp(clk, rstn, sw_i, reg_sel, reg_data, disp_seg_o, disp_an_o);
   input          clk;
   input          rstn;
   input [15:0]   sw_i;
   input [4:0]    reg_sel;
   output [31:0]  reg_data;
   
   // link between every part
   wire [31:0]    instr;
   wire [31:0]    PC;
   wire           MemWrite;
   wire [31:0]    dm_addr, dm_din, dm_dout, dm_type;
   
   wire rst = ~rstn;

   // divide clock for display
   reg [31:0] clkdiv;
   wire clk_cpu;

   // for display
   reg [63:0] display_data;
   reg [5:0] led_data_addr;
   reg [63:0] led_disp_data;

   //clock divider
   always @(posedge clk or negedge rstn) begin
      if (!rstn)
         clkdiv <= 0;
      else
         clkdiv <= clkdiv + 1'b1;
   end
   assign clk_cpu = (sw_i[15]) ? clkdiv[26] : clkdiv[0];  //speed and slow down

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
      end else begin
         //display ROM,
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