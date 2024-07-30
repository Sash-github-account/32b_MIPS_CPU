// reference : Computer Organization and design; David A. Patterson, John L. Hennessy
/*`include "alu.sv"
`include "alu_control.sv"
`include "cpu_main_ctrl.sv"
`include "pc.sv"
`include "registers.sv"*/

module simple_MIPS_CPU(
		       input logic 	   clk,
		       input logic 	   rst_n,
		       output logic 	   memread_ctrl,
				 output logic[0:7] LED_o
		       );


   //**********Declarations*************//
	localparam [31:0] INSTR_FOR_LED_OUT = 3;
   logic [4:0] 				   write_register_in_mux;
   logic [31:0] 			   reg_write_data_mux;
   logic [31:0] 			   alu_result;
   logic [1:0] 				   aluop_ctrl;
   logic [3:0] 				   alu_ctrl;
   logic 				   alusrc_ctrl;
   logic 				   memtoreg_ctrl;
   logic 				   regdst_ctrl; 
   logic [31:0] 			   read_data_1;
   logic [31:0] 			   read_data_2;
   logic [31:0] 			   alu_op_2_mux;
   logic [31:0] 			   br_instr_offset_sign_extd;
	logic [31:0]  instruction;
	logic [31:0]  data_mem_addr;
	logic [31:0]  data_mem_wrdata;
	logic [31:0] inst_mem_rd_addr;
	logic [31:0] inst_mem_rd_addr_to_instmem;
	logic [31:0] data_mem_rd_data;
	logic led_load;
	logic [7:0] led_data;
	logic [7:0] reg_led_o;
	logic pc_halted;
   //***********************************//


   //************** Comb logic ***************//
   assign write_register_in_mux = (regdst_ctrl) ? instruction[15:11] : instruction[20:16];
   assign reg_write_data_mux = (memtoreg_ctrl) ? data_mem_rd_data : alu_result;
   assign br_instr_offset_sign_extd = (instruction[15]) ? {16'hffff,instruction[15:0]} : {16'h0000,instruction[15:0]};
   assign alu_op_2_mux = (alusrc_ctrl) ? br_instr_offset_sign_extd : read_data_2;
   assign data_mem_addr = alu_result;
   assign data_mem_wrdata = read_data_2;
   assign led_load = (inst_mem_rd_addr == INSTR_FOR_LED_OUT) ? 1'b1:1'b0;
	assign led_data = inst_mem_rd_addr[7:0];
	assign inst_mem_rd_addr_to_instmem = inst_mem_rd_addr>>2;
	//***********************************//
	
	
   //************Instantiations*********//

   pc_non_pipe i_pc(
	   .clk(clk),
	   .rst_n(rst_n),
	   .instruction_jmp_imm(instruction[25:0]),
	   .instruction_beq_offset(br_instr_offset_sign_extd),
	   .branch_ctrl(branch_ctrl),
	   .zero_alu(zero_alu),
	   .jump_ctrl(jump_ctrl),
		.final_nxt_pc_mux(),
	   .cur_pc(inst_mem_rd_addr),
		.pc_halted(pc_halted)
	   );

   registers1 i_registers1(
			 .clk(clk),
			 .rst_n(rst_n),
			 .read_register_1(instruction[25:21]),
			 .read_register_2(instruction[20:16]),
			 .write_register(write_register_in_mux),
			 .write_data(reg_write_data_mux),
			 .regwrite_ctrl(regwrite_ctrl),
			 .read_data_1(read_data_1),
			 .read_data_2(read_data_2),
			 .reg_led_o(reg_led_o)
			 );

   alu i_alu(
	     .op_1(read_data_1),
	     .op_2(alu_op_2_mux),
	     .alu_ctrl(alu_ctrl),
	     .alu_result(alu_result),
	     .zero_alu(zero_alu)
	     );

   alu_control i_alu_control(
			     .instruction_funct(instruction[5:0]),
			     .alu_op_ctrl(aluop_ctrl),
			     .alu_ctrl(alu_ctrl)
			     );
   
   cpu_main_ctrl i_cpu_main_ctrl(
				 .instruction_opcode(instruction[31:26]),
				 .aluop_ctrl(aluop_ctrl),
				 .regdst_ctrl(regdst_ctrl),
				 .jump_ctrl(jump_ctrl),
				 .branch_ctrl(branch_ctrl),
				 .memread_ctrl(memread_ctrl),
				 .memwrite_ctrl(memwrite_ctrl),
				 .memtoreg_ctrl(memtoreg_ctrl),
				 .alusrc_ctrl(alusrc_ctrl),
				 .regwrite_ctrl(regwrite_ctrl)
				 ); 
				
	instr_rom		i_instr_rom (
	.address(inst_mem_rd_addr_to_instmem),
	.clock(clk),
	.q(instruction));	
	
	data_ram i_data_ram(
	.address(data_mem_addr),
	.clock(clk),
	.data(data_mem_wrdata),
	.wren(memwrite_ctrl),
	.q(data_mem_rd_data));
	
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
