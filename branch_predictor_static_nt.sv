module branch_predictor_hndlr_static_nt(
					input logic 	   clk,
					input logic 	   rst_n,
					//input logic 	   branch_instr_detected,
					input logic [5:0] opcode_for_brnch_instr_detect,
					input logic 	   EXMEM_regwrite_ctrl,
					input logic [4:0]  EXMEM_reg_rd,
					input logic [4:0]  IFID_reg_rs,
					input logic [4:0]  IFID_reg_rt,
					input logic 	   MEMWB_regwrite_ctrl,
					input logic [4:0]  MEMWB_reg_rd,
					input logic [31:0] read_data_1_from_regfile,
					input logic [31:0] read_data_2_from_regfile,
					input logic [31:0] EXMEM_alu_output,
					input logic [31:0] MEMWB_mux_output,
					input logic 	   IDEX_regwrite_ctrl,
					input logic [4:0]  IDEX_reg_rd,
					input logic 	   IDEX_memread_ctrl,
					input logic 	   IDEX_memtoreg_ctrl,
					input logic 	   IDEX_alusrc_ctrl,
					output logic 	   branch_hazard_stall,
					output logic 	   branch_taken_IF_flush
			);

   //****** Wires ******//
   logic 				   IDEX_IFID_reg_comp;
   logic 				   regctrl_n_brnch_detect;
   logic 				   branch_hazard_del;
   logic branch_hazard_aluop;
   logic branch_hazard_ldop;
   logic[31:0] read_data_1_after_fwdng;
   logic[31:0] read_data_2_after_fwdng;
   logic 	   branch_instr_detected;
   //****** Wires ******//
   
   //*** actual branch comparison result calc Logic ****//
   assign branch_taken_IF_flush = (branch_instr_detected) ? (read_data_1_after_fwdng == read_data_2_after_fwdng) : 0;
   //************//

   //******* branch hazard detection **********//
   assign branch_instr_detected = (opcode_for_brnch_instr_detect == 6'b000100);
   assign IDEX_IFID_reg_comp = ((IDEX_reg_rd == IFID_reg_rs)|(IDEX_reg_rd == IFID_reg_rt));
   assign regctrl_n_brnch_detect = (IDEX_regwrite_ctrl & branch_instr_detected);
   assign branch_hazard_aluop =  regctrl_n_brnch_detect & IDEX_IFID_reg_comp;
   assign branch_hazard_ldop = regctrl_n_brnch_detect & (IDEX_alusrc_ctrl == 2'b01) & IDEX_memtoreg_ctrl & IDEX_memread_ctrl & IDEX_IFID_reg_comp;
   assign branch_hazard_stall = (branch_hazard_aluop | branch_hazard_ldop) | branch_hazard_del;

   always_ff@(posedge clk) begin
      if(!rst_n) begin
	 branch_hazard_del <= 0;
      end
      else begin
	 branch_hazard_del <= branch_hazard_ldop;
      end
   end

   //*****************************************//


      forwarding_unit i_branch_forwarding_unit(
				     .EXMEM_regwrite_ctrl(EXMEM_regwrite_ctrl	),
				     .EXMEM_reg_rd(EXMEM_reg_rd	),
				     .IDEX_reg_rs(IFID_reg_rs	),
				     .IDEX_reg_rt(IFID_reg_rt	),
				     .MEMWB_regwrite_ctrl(MEMWB_regwrite_ctrl	),
				     .MEMWB_reg_rd(MEMWB_reg_rd	),
				     .reg_read_data_1_in(read_data_1_from_regfile),
				     .reg_read_data_2_in(read_data_2_from_regfile),
				     .EXMEM_alu_output(EXMEM_alu_output),
				     .MEMWB_mux_output(MEMWB_mux_output),
				     .read_data_1(read_data_1_after_fwdng),
				     .read_data_2(read_data_2_after_fwdng)
				     );
   

endmodule // branch_predictor_static_nt

   
