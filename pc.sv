module pc(
	  input logic 	      clk,
	  input logic 	      rst_n,
	  input logic [25:0]  instruction_jmp_imm,
	  input logic 	      hazard_detected,
	  input logic 	      load_exceptn_vec_addr,
	  input logic [31:0]  exception_vec_addr,
	  input logic [31:0]  branch_address,
	  input logic 	      br_ctrl_mux_sel,
	  input logic 	      jump_ctrl,
	  output logic [31:0] pc_plus_4,
	  output logic [31:0] final_nxt_pc_mux,
	  output logic [31:0] cur_pc
	  );


   //*********Declarations***********//
   localparam HALT_PC = 5;
   logic [3:0] 		      pc_plus_4_jump_msb;
   logic [27:0] 	      instruction_jump_imm_shft_l_2;
   logic [31:0] 	      jump_address;
   logic [31:0] 	      jmp_or_pcp4_mux;
   logic [31:0] 	      pc_plus_4_br_addr_mux;
   logic 		      is_halt_pc;
   //********************************//


   //******Comb logic********//
   assign pc_plus_4 = (hazard_detected) ? cur_pc : (cur_pc + 4);
   assign pc_plus_4_jump_msb = pc_plus_4[31:28];
   assign instruction_jump_imm_shft_l_2 = {instruction_jmp_imm,2'b0};
   assign jump_address = {pc_plus_4_jump_msb, instruction_jump_imm_shft_l_2};
   assign pc_plus_4_br_addr_mux = (br_ctrl_mux_sel & !hazard_detected) ? branch_address : pc_plus_4;
   assign jmp_or_pcp4_mux = (jump_ctrl) ? jump_address : pc_plus_4_br_addr_mux;
   assign final_nxt_pc_mux = (load_exceptn_vec_addr) ? exception_vec_addr : jmp_or_pcp4_mux;
   //assign is_halt_pc = ((final_nxt_pc_mux >> 2) == HALT_PC);
   assign is_halt_pc = 0;
   //************************//


   //*********PC Seq logic**********//
   always@(posedge clk) begin
      if(!rst_n) cur_pc <= 32'h0;
      else cur_pc <= (!is_halt_pc) ? final_nxt_pc_mux : cur_pc;
   end
   //******************************//

endmodule // pc
