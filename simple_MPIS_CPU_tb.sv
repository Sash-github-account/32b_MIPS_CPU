module tb;
   logic 	   clk;
   logic 	   reset_n;
   logic [31:0]    instruction[0:7];
   logic [31:0]    data_mem_rd_data;
   logic [31:0]    inst_mem_rd_addr;
   logic [31:0]    data_mem_addr;
   logic [31:0]    data_mem_wrdata;
   logic 	   memwrite_ctrl;
   logic 	   memread_ctrl;
   logic [31:0]    data_mem[0:4];
   logic [31:0]    instr_mem_addr;
   logic [31:0]    data_in;
   
   assign instr_mem_addr  = (inst_mem_rd_addr>>2);
   assign data_in = data_mem[data_mem_addr];


   initial begin
      $dumpfile("dump1.vcd"); $dumpvars;
      clk <= 0;
      reset_n = 0;
      instruction[0] <= {6'd35,5'd0,5'd1,16'd0}; // load mem0 to reg1
      instruction[1] <= {6'd35,5'd0,5'd2,16'd1}; // load mem1 to reg2
      instruction[2] <= {6'd35,5'd0,5'd4,16'd2}; // load mem2 to reg4
      instruction[3] <= {6'd0,5'd1,5'd2,5'd3,5'd0,6'b100000}; //add reg1, reg2 in reg3
      instruction[5] <= {6'd43,5'd0,5'd3,16'd3};
      instruction[4] <= {6'd4,5'd4,5'd3,-16'd4}; // br if reg4 == reg3
      //instruction[6] <= {6'b000010,26'h0};// jmp back to start
      instruction[6] <= {6'd0,5'd2,5'd3,5'd3,5'd0,6'b100000};
      instruction[7] <= {6'd43,5'd0,5'd4,-16'd4}; 
      data_mem[0] <= 32'd1;
      data_mem[1] <= 32'd5;
      data_mem[2] <= 32'd5;
      
      
      #250 reset_n <= 1;
      
      #380 $finish;
   end

   always #2 clk <= !clk;

  // simple_MIPS_CPU i_simple_MIPS_CPU(
  CPU_MIPS_32b_5stage i_simple_MIPS_CPU(
				     .clk(clk),
				     .rst_n(reset_n),
				     .instruction_i(instruction[inst_mem_rd_addr]),
				     .inst_mem_rd_addr_to_instmem(inst_mem_rd_addr)
				     ); 
endmodule
