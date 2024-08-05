// reference : Computer Organization and design; David A. Patterson, John L. Hennessy
/*`include "alu.sv"
 `include "alu_control.sv"
 `include "cpu_main_ctrl.sv"
 `include "pc.sv"
 `include "registers.sv"*/

module CPU_MIPS_32b_5stage(
			   input logic 	      clk,
			   input logic 	      rst_n,
			   output logic       memread_ctrl,
			   output 	      inst_mem_rd_addr_to_instmem,
			   input logic [31:0] instruction_i, 
			   output logic [0:7] LED_o
			   );


   //**********Declarations*************//
   localparam [31:0] INSTR_FOR_LED_OUT = 3;
   logic [4:0] 				      write_register_in_mux;
   logic [31:0] 			      reg_write_data_mux;
   logic [31:0] 			      alu_result;
   logic [1:0] 				      aluop_ctrl;
   logic [3:0] 				      alu_ctrl;
   logic 				      alusrc_ctrl;
   logic 				      memtoreg_ctrl;
   logic 				      regdst_ctrl; 
   logic [31:0] 			      read_data_1_discon;
   logic [31:0] 			      read_data_2_discon;
   logic [31:0] 			      read_data_1;
   logic [31:0] 			      read_data_2;
   logic [31:0] 			      read_data_1_in_to_alu;
   logic [31:0] 			      read_data_2_in_to_alu;
   logic [31:0] 			      alu_op_2_mux;
   logic [31:0] 			      br_instr_offset_sign_extd;
   logic [31:0] 			      instruction;
   logic [31:0] 			      data_mem_addr;
   logic [31:0] 			      data_mem_wrdata;
   logic [31:0] 			      inst_mem_rd_addr;
   logic [31:0] 			      inst_mem_rd_addr_to_instmem;
   logic [31:0] 			      data_mem_rd_data;
   logic 				      led_load;
   logic [7:0] 				      led_data;
   logic [7:0] 				      reg_led_o;
   logic 				      pc_halted;
   logic 				      jump_ctrl;   
   logic 				      branch_ctrl;   
   logic 				      memwrite_ctrl;   
   logic 				      regwrite_ctrl;   
   logic 				      zero_alu;   
   logic [31:0] 			      branch_address;
   logic [1:0] 				      forward_a;
   logic [1:0] 				      forward_b;
   logic 				      hazard_detected;
   //***********************************//




   //************** Comb logic ***************//
   assign write_register_in_mux_to_EXMEM_pipe = (regdst_ctrl) ? instruction_15_11 : instruction_20_16;
   assign reg_write_data_mux = (memtoreg_ctrl) ? data_mem_rd_data : alu_result;
   assign br_instr_offset_sign_extd_to_IDEX_pipe = (instruction[15]) ? {16'hffff,instruction[15:0]} : {16'h0000,instruction[15:0]};
   assign alu_op_2_mux = (alusrc_ctrl) ? br_instr_offset_sign_extd : read_data_2_in_to_alu;
   assign data_mem_addr = alu_result_to_MEMWB_pipe;
   assign data_mem_wrdata_to_EXMEM_pipe = read_data_2_in_to_alu;
   assign led_load = (inst_mem_rd_addr == INSTR_FOR_LED_OUT) ? 1'b1:1'b0;
   assign led_data = inst_mem_rd_addr[7:0];
   assign inst_mem_rd_addr_to_instmem = inst_mem_rd_addr>>2;
   //***********************************//
   
   
   //************Instantiations*********//


   // IF/ID stage
   logic [31:0] 			      pc_plus_4_to_IFID_pipe;
   logic [31:0] 			      pc_plus_4_to_IDEX_pipe;
   
   always_ff@(posedge clk)begin
      if(!rst_n)begin
	 instruction <= 32'b0;
	 pc_plus_4_to_IDEX_pipe <= 32'h0;
      end
      else begin      
	 if(hazard_detected | branch_taken) begin
            instruction <= (branch_taken) ? 32'h0 : instruction;
	    pc_plus_4_to_IDEX_pipe <= pc_plus_4_to_IDEX_pipe;
	 end
	 else begin
            instruction <= instruction_i;
	    pc_plus_4_to_IDEX_pipe <= pc_plus_4_to_IFID_pipe;
	 end
      end
   end
   
   
   //ID/EX stage   
   logic [31:0] read_data_1_to_IDEX_pipe;
   logic [31:0] read_data_2_to_IDEX_pipe; 
   logic [1:0] 	aluop_ctrl_to_IDEX_pipe;
   logic 	regdst_ctrl_to_IDEX_pipe;
   logic 	jump_ctrl_to_IDEX_pipe;
   logic 	branch_ctrl_to_IDEX_pipe;
   logic 	memread_ctrl_to_IDEX_pipe;
   logic 	memwrite_ctrl_to_IDEX_pipe;
   logic 	memtoreg_ctrl_to_IDEX_pipe;
   logic 	alusrc_ctrl_to_IDEX_pipe;
   logic 	regwrite_ctrl_to_IDEX_pipe;
   logic [31:0] br_instr_offset_sign_extd_to_IDEX_pipe;
   logic [4:0] 	instruction_25_21;
   logic [4:0] 	instruction_15_11;
   logic [4:0] 	instruction_20_16;
   logic [4:0] 	reg_rs_from_IDEX;
   logic [4:0] 	reg_rd_from_IDEX;
   logic [4:0] 	reg_rt_from_IDEX;
   logic [5:0] 	instruction_5_0; 
   logic [31:0] pc_plus_4;

   assign reg_rs_from_IDEX = instruction_25_21;
   assign reg_rd_from_IDEX = instruction_15_11;
   assign reg_rt_from_IDEX = instruction_20_16;
 
   assign read_data_1_discon = 0;
   assign read_data_2_discon = 0;
  
   always_ff@(posedge clk)begin
      if(!rst_n)begin
	 read_data_1 <= 32'b0;
	 read_data_2 <= 32'b0;
	 aluop_ctrl <= 32'b0;
	 regdst_ctrl<= 32'b0;  
	 jump_ctrl_to_EXMEM_pipe     <= 0;
	 branch_ctrl_to_EXMEM_pipe   <= 0;
	 memread_ctrl_to_EXMEM_pipe  <= 0;
	 memwrite_ctrl_to_EXMEM_pipe <= 0;
	 memtoreg_ctrl_to_EXMEM_pipe <= 0;
	 alusrc_ctrl<= 32'b0;  
	 regwrite_ctrl_to_EXMEM_pipe <= 32'b0; 
	 instruction_25_21 <= 5'h0; 
	 instruction_15_11 <= 5'h0;
	 instruction_20_16 <= 5'h0;
	 br_instr_offset_sign_extd <= 32'h0;
	 instruction_5_0 <= 6'h0;
	 pc_plus_4 <= 32'h0;
      end
      else begin
	 read_data_1    <= read_data_1_to_IDEX_pipe ;
	 read_data_2    <= read_data_2_to_IDEX_pipe ;
	 aluop_ctrl    <=  aluop_ctrl_to_IDEX_pipe ;
	 regdst_ctrl   <= regdst_ctrl_to_IDEX_pipe;  
	 jump_ctrl_to_EXMEM_pipe     <= jump_ctrl_to_IDEX_pipe;    
	 branch_ctrl_to_EXMEM_pipe   <= branch_ctrl_to_IDEX_pipe;  
	 memread_ctrl_to_EXMEM_pipe  <= memread_ctrl_to_IDEX_pipe; 
	 memwrite_ctrl_to_EXMEM_pipe <= memwrite_ctrl_to_IDEX_pipe;
	 memtoreg_ctrl_to_EXMEM_pipe <= memtoreg_ctrl_to_IDEX_pipe;
	 alusrc_ctrl   <= alusrc_ctrl_to_IDEX_pipe;  
	 regwrite_ctrl_to_EXMEM_pipe <= regwrite_ctrl_to_IDEX_pipe;
	 instruction_25_21 <= instruction[25:21];
         instruction_15_11 <= instruction[15:11];
	 instruction_20_16 <= instruction[20:16];
	 instruction_5_0 <= instruction[5:0];
	 br_instr_offset_sign_extd <= br_instr_offset_sign_extd_to_IDEX_pipe;
	 pc_plus_4 <= pc_plus_4_to_IDEX_pipe;
      end
   end


   //EX/MEM stage
   logic jump_ctrl_to_EXMEM_pipe    ;
   logic branch_ctrl_to_EXMEM_pipe  ;
   logic memread_ctrl_to_EXMEM_pipe ;
   logic memwrite_ctrl_to_EXMEM_pipe;
   logic memtoreg_ctrl_to_EXMEM_pipe;
   logic regwrite_ctrl_to_EXMEM_pipe;
   logic [31:0] alu_result_to_EXMEM_pipe;
   logic 	zero_alu_to_EXMEM_pipe;
   logic [31:0] data_mem_wrdata_to_EXMEM_pipe;
   logic [4:0] 	write_register_in_mux_to_EXMEM_pipe;

   always_ff@(posedge clk) begin
      if(!rst_n) begin
	 jump_ctrl    <= 0;         
	 branch_ctrl  <= 0;         
	 memread_ctrl <= 0;         
	 memwrite_ctrl<= 0;         
	 memtoreg_ctrl_to_MEMWB_pipe <= 0;         
	 regwrite_ctrl_to_MEMWB_pipe <= 0;         
	 alu_result_to_MEMWB_pipe <= 0;     
	 zero_alu <= 0;       
	 data_mem_wrdata <= 0;
	 //branch_address <= 32'h0;
	 write_register_in_mux_to_MEMWB_pipe <= 0;
      end
      else begin
	 jump_ctrl <= jump_ctrl_to_EXMEM_pipe    ;         
	 branch_ctrl <= branch_ctrl_to_EXMEM_pipe  ;         
	 memread_ctrl <= memread_ctrl_to_EXMEM_pipe ;         
	 memwrite_ctrl <= memwrite_ctrl_to_EXMEM_pipe;         
	 memtoreg_ctrl_to_MEMWB_pipe <= memtoreg_ctrl_to_EXMEM_pipe;         
	 regwrite_ctrl_to_MEMWB_pipe <= regwrite_ctrl_to_EXMEM_pipe;         
	 alu_result_to_MEMWB_pipe <= alu_result_to_EXMEM_pipe;     
	 zero_alu <= zero_alu_to_EXMEM_pipe;       
	 data_mem_wrdata <= data_mem_wrdata_to_EXMEM_pipe;
	 //branch_address <= branch_address_to_EXMEM_pipe;
	 write_register_in_mux_to_MEMWB_pipe <= write_register_in_mux_to_EXMEM_pipe;
      end
   end



   //MEM/WB stage
   logic [4:0] write_register_in_mux_to_MEMWB_pipe;
   logic [31:0] alu_result_to_MEMWB_pipe;
   logic [31:0] data_mem_rd_data_to_MEMWB_pipe;   
   logic 	PCSrc;
   logic 	memtoreg_ctrl_to_MEMWB_pipe;
   logic 	regwrite_ctrl_to_MEMWB_pipe;
   
   assign PCSrc = branch_ctrl & zero_alu;

   always_ff@(posedge clk) begin
      if(!rst_n) begin
	 alu_result <= 32'h0;
	 data_mem_rd_data <= 32'h0;
	 write_register_in_mux <= 5'h0;
	 memtoreg_ctrl <= 0;
	 regwrite_ctrl <= 0;
      end
      else begin
	 alu_result <= alu_result_to_MEMWB_pipe;
	 data_mem_rd_data <= data_mem_rd_data_to_MEMWB_pipe;
	 write_register_in_mux <= write_register_in_mux_to_MEMWB_pipe;
	 memtoreg_ctrl <= memtoreg_ctrl_to_MEMWB_pipe;
	 regwrite_ctrl <= regwrite_ctrl_to_MEMWB_pipe;
      end
   end
   

   // branch address calculation
   logic [31:0] 	     br_instr_offset_sign_extdt_shft_l_2;
   logic [31:0] 	     branch_address_to_EXMEM_pipe;
   logic cpu_ctrl_stall;
   assign br_instr_offset_sign_extdt_shft_l_2 = br_instr_offset_sign_extd_to_IDEX_pipe << 2;
   assign branch_address = pc_plus_4_to_IDEX_pipe + br_instr_offset_sign_extdt_shft_l_2;
   assign cpu_ctrl_stall = (hazard_detected );

   forwarding_unit i_forwarding_unit(
				     .EXMEM_regwrite_ctrl(regwrite_ctrl_to_MEMWB_pipe	),
				     .EXMEM_reg_rd(write_register_in_mux_to_MEMWB_pipe	),
				     .IDEX_reg_rs(reg_rs_from_IDEX	),
				     .IDEX_reg_rt(reg_rt_from_IDEX	),
				     .MEMWB_regwrite_ctrl(regwrite_ctrl	),
				     .MEMWB_reg_rd(write_register_in_mux	),
				     .reg_read_data_1_in(read_data_1),
				     .reg_read_data_2_in(read_data_2),
				     .EXMEM_alu_output(alu_result_to_MEMWB_pipe),
				     .MEMWB_mux_output(reg_write_data_mux),
				     .read_data_1(read_data_1_in_to_alu),
				     .read_data_2(read_data_2_in_to_alu)
				     );

   hazard_detection_unit i_hazard_detection_unit(
						 .clk(clk),
						 .rst_n(rst_n),
						 .IDEX_memread_ctrl(memread_ctrl_to_EXMEM_pipe),
						 .IDEX_reg_rt(reg_rt_from_IDEX),
						 .IFID_reg_rs(instruction[25:21]),
						 .IFID_reg_rt(instruction[20:16]),
						 .hazard_detected(hazard_detected)
						 );
 
   branch_predictor_static_nt i_branch_predictor_static_nt(
							   .reg1_val(read_data_1_to_IDEX_pipe	),
							   .reg2_val(read_data_2_to_IDEX_pipe	),
							   .branch_instr_detected(branch_ctrl_to_IDEX_pipe),
							   .branch_taken(branch_taken)
							   );
  
   pc i_pc(
	   .clk(clk),
	   .rst_n(rst_n),
	   .instruction_jmp_imm(instruction[25:0]),
	   .hazard_detected(hazard_detected),
	   .branch_address(branch_address),
	   .br_ctrl_mux_sel(branch_taken),
	   .zero_alu(zero_alu),
	   .jump_ctrl(jump_ctrl),
	   .final_nxt_pc_mux(),
	   .pc_plus_4(pc_plus_4_to_IFID_pipe),
	   .cur_pc(inst_mem_rd_addr),
	   .pc_halted(pc_halted)
	   );

   regfile_larr i_registers1(
			   .clk(clk),
			   .rst_n(rst_n),
			   .read_register_1(instruction[25:21]),
			   .read_register_2(instruction[20:16]),
			   .write_register(write_register_in_mux),
			   .write_data(reg_write_data_mux),
			   .regwrite_ctrl(regwrite_ctrl),
			   .read_data_1(read_data_1_to_IDEX_pipe),
			   .read_data_2(read_data_2_to_IDEX_pipe),
			   .reg_led_o(reg_led_o)
			   );

   alu i_alu(
	     .op_1(read_data_1_in_to_alu),
	     .op_2(alu_op_2_mux),
	     .alu_ctrl(alu_ctrl),
	     .alu_result(alu_result_to_EXMEM_pipe),
	     .zero_alu(zero_alu_to_EXMEM_pipe)
	     );

   alu_control i_alu_control(
			     .instruction_funct(instruction_5_0),
			     .alu_op_ctrl(aluop_ctrl),
			     .alu_ctrl(alu_ctrl)
			     );
   
   cpu_main_ctrl i_cpu_main_ctrl(
				 .instruction_opcode(instruction[31:26]),
				 .hazard_detected(cpu_ctrl_stall),
				 .aluop_ctrl(aluop_ctrl_to_IDEX_pipe),
				 .regdst_ctrl(regdst_ctrl_to_IDEX_pipe),
				 .jump_ctrl(jump_ctrl_to_IDEX_pipe),
				 .branch_ctrl(branch_ctrl_to_IDEX_pipe),
				 .memread_ctrl(memread_ctrl_to_IDEX_pipe),
				 .memwrite_ctrl(memwrite_ctrl_to_IDEX_pipe),
				 .memtoreg_ctrl(memtoreg_ctrl_to_IDEX_pipe),
				 .alusrc_ctrl(alusrc_ctrl_to_IDEX_pipe),
				 .regwrite_ctrl(regwrite_ctrl_to_IDEX_pipe)
				 ); 
   
   //	instr_rom		i_instr_rom (
   //	.address(inst_mem_rd_addr_to_instmem),
   //	.clock(clk),
   //	.q(instruction));	
   
   data_ram i_data_ram(
		       .address(data_mem_addr[5:0]),
		       .clock(clk),
		       .data(data_mem_wrdata),
		       .wren(memwrite_ctrl),
		       .q(data_mem_rd_data_to_MEMWB_pipe));
   
   blink i_blnk(
		.clk(clk), // 50MHz input clock
		.cnt_en(led_load),
		.LED() // LED ouput
		);
   
   led_out_8b i_led_o(
		      .clk(clk),
		      .rst_n(rst_n),
		      .led_load_data(reg_led_o),
		      .led_load(regwrite_ctrl), //(instruction == 32'hAC030003)
		      .LED_o(LED_o)
		      );
   //**********************************//

endmodule // simple_MIPS_CPU
