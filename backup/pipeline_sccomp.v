module pipeline_sccomp(clk, rstn, reg_sel, reg_data);
   input          clk;
   input          rstn;
   input [4:0]    reg_sel;
   output [31:0]  reg_data;
   
   // link between every part
   wire [31:0]    instr;
   wire [31:0]    PC;
   wire           MemWrite;
   wire [31:0]    dm_addr, dm_din, dm_dout, dm_type;
   
   wire rst = ~rstn;

  // instantiation of pipeline CPU   
   pipeline_cpu U_pipeline_CPU(
         .clk(clk),                 // input:  cpu clock
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
         .clk(clk),           // input:  cpu clock
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
endmodule