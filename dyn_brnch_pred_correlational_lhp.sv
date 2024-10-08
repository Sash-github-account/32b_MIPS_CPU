module dyn_brnch_pred_correlational_lhp (
				     input logic       clk,
				     input logic       rst_n,
				     input logic [4:0] branch_addr_lw_5b,
				     input logic       brch_instr_detectd_ID,
				     input logic       brch_instr_detectd_IF,
				     input logic       brch_hazard_stall,
				     input logic       actual_brch_result,
				     output logic      predict_br_taken
				     );


   //------ Wires----------//
   logic [4:0] 					       lpt_ram_addr;
   logic [4:0] 					       branch_addr_lw_5b_int;
   logic [4:0] 					       branch_addr_to_lht;
   logic 					       update_br_pred_state;
   logic 					       prediction;
   
   //------ Wires----------//

   //----- Prediction and update logic --------//
   assign predict_br_taken = prediction & brch_instr_detectd_IF;
   assign update_br_pred_state = brch_instr_detectd_ID & !brch_hazard_stall;
   assign branch_addr_to_lht = (brch_instr_detectd_IF) ? branch_addr_lw_5b : branch_addr_lw_5b_int;
   //----- Prediction and update logic --------//

   //----- Addr updation logic ----------//
   always_ff@(posedge clk) begin
      if(!rst_n) begin
	 branch_addr_lw_5b_int <= 5'h00;
      end
      else begin
	 if(brch_instr_detectd_ID | brch_instr_detectd_IF) branch_addr_lw_5b_int <= branch_addr_lw_5b;
	 else branch_addr_lw_5b_int <= branch_addr_lw_5b_int;
      end
   end
   //----- Addr updation logic ----------//


   
   //-------- LHT ----------//   
   local_history_table_shft_regs i_lht_ram(
					   .clk(clk),
					   .rst_n(rst_n),
					   .update_shft_reg(update_br_pred_state),
					   .shft_value(actual_brch_result),
					   .shft_reg_addr_for_updtn(branch_addr_to_lht),
					   .lht_entry_to_lpt(lpt_ram_addr)
					   );
   //-------- LHT ----------//   

   
   //-------- LPT ----------//
   local_pred_table_regs i_lpt_ram(
				   .clk(clk),
				   .rst_n(rst_n),
				   .upd_pred_state(update_br_pred_state),
				   .actual_brch_result(actual_brch_result),
				   .lpt_addr(lpt_ram_addr),
				   .prediction(prediction)
				   );
   //-------- LPT ----------//   

endmodule // dyn_brnch_pred_correlational
