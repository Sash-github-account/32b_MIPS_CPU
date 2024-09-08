module brnch_pred_hndlr_2b_correl_dyn(
				      input logic 	 clk,
				      input logic 	 rst_n,
				      input logic [5:0]  opcode_for_brnch_instr_detect_IF,
				      input logic [5:0]  opcode_for_brnch_instr_detect_ID,
				      input logic 	 EXMEM_regwrite_ctrl,
				      input logic [4:0]  branch_addr_lw_5b,
				      input logic [4:0]  EXMEM_reg_rd,
				      input logic [4:0]  IFID_reg_rs,
				      input logic [4:0]  IFID_reg_rt,
				      input logic 	 MEMWB_regwrite_ctrl,
				      input logic [4:0]  MEMWB_reg_rd,
				      input logic [31:0] read_data_1_from_regfile,
				      input logic [31:0] read_data_2_from_regfile,
				      input logic [31:0] EXMEM_alu_output,
				      input logic [31:0] MEMWB_mux_output,
				      input logic 	 IDEX_regwrite_ctrl,
				      input logic [4:0]  IDEX_reg_rd,
				      input logic 	 IDEX_memread_ctrl,
				      input logic 	 IDEX_memtoreg_ctrl,
				      input logic 	 IDEX_alusrc_ctrl,
				      output logic 	 branch_hazard_stall,
				      output logic 	 br_prediction,
				      output logic 	 flush
				      );

   //****** Wires ******//
   logic 						 IDEX_IFID_reg_comp;
   logic 						 regctrl_n_brnch_detect;
   logic 						 branch_hazard_del;
   logic 						 branch_hazard_aluop;
   logic 						 branch_hazard_ldop;
   logic [31:0] 					 read_data_1_after_fwdng;
   logic [31:0] 					 read_data_2_after_fwdng;
   logic 						 branch_instr_detected_ID;
   logic 						 actual_branch_result;
   logic 						 br_prediction_ID;
   logic 						 br_prediction_i;
   
   //****** Wires ******//

   //****** detect branch instr in IF ********//
   assign branch_instr_detected_IF = (opcode_for_brnch_instr_detect_IF == 6'b000100);
   //****** detect branch instr in IF ********//

   
   //*** actual branch comparison result calc Logic ****//
   assign actual_branch_result = (branch_instr_detected_ID) ? (read_data_1_after_fwdng == read_data_2_after_fwdng) : 0;
   //************//

   //***** Flush : br mis-pred ******//
   assign   br_prediction = br_prediction_i & !branch_hazard_stall;
   assign flush = (actual_branch_result != br_prediction_ID) & !branch_hazard_stall;
   //***** Flush : br mis-pred ******//
   
   
   //******* branch hazard detection **********//
   assign branch_instr_detected_ID = (opcode_for_brnch_instr_detect_ID == 6'b000100);
   assign IDEX_IFID_reg_comp = ((IDEX_reg_rd == IFID_reg_rs)|(IDEX_reg_rd == IFID_reg_rt));
   assign regctrl_n_brnch_detect = (IDEX_regwrite_ctrl & branch_instr_detected_ID);
   assign branch_hazard_aluop =  regctrl_n_brnch_detect & IDEX_IFID_reg_comp;
   assign branch_hazard_ldop = regctrl_n_brnch_detect & (IDEX_alusrc_ctrl == 2'b01) & IDEX_memtoreg_ctrl & IDEX_memread_ctrl & IDEX_IFID_reg_comp;
   assign branch_hazard_stall = (branch_hazard_aluop | branch_hazard_ldop) | branch_hazard_del;

   always_ff@(posedge clk) begin
      if(!rst_n) begin
	 br_prediction_ID <= 0;
      end
      else begin
	 if(!branch_hazard_stall) begin
	    br_prediction_ID <= br_prediction_i;
	 end
	 else begin
	    br_prediction_ID <= br_prediction_ID;
	 end
      end
   end

   always_ff@(posedge clk) begin
      if(!rst_n) begin
	 branch_hazard_del <= 0;
      end
      else begin
	 branch_hazard_del <= branch_hazard_ldop;
      end
   end
   //*****************************************//

   
   dyn_brnch_pred_correlational_tournament i_dyn_brnch_pred_2b(
							   .clk(clk),
							   .rst_n(rst_n),
							   .branch_addr_lw_5b(branch_addr_lw_5b),
							   .brch_instr_detectd_ID(branch_instr_detected_ID),
							   .brch_instr_detectd_IF(branch_instr_detected_IF),
							   .brch_hazard_stall(branch_hazard_stall),
							   .actual_brch_result(actual_branch_result),
							   .predict_br_taken(br_prediction_i)
							   );

   
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


