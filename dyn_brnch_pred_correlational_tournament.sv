module dyn_brnch_pred_correlational_tournament (
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
   logic [4:0] 						      lpt_ram_addr_ghr;
   logic [4:0] 						      lpt_ram_addr_bhrt;
   logic 						      update_br_pred_state;
   logic 						      update_chooser_state;
   logic 						      prediction;
   logic 						      prediction_global;
   logic 						      prediction_local;
   logic 						      prediction_chooser;
   logic 						      result_for_chooser_upd;
   logic 						      ghr_is_correct;
   logic 						      lhr_is_correct;
   logic [4:0] 						      gshare_hash;
         logic [4:0] branch_addr_lw_5b_int;
      logic [4:0] lpt_addr;
   //------ Wires----------//

   //----- Prediction and update logic --------//
   assign predict_br_taken = prediction & brch_instr_detectd_IF;
   assign prediction = (prediction_chooser) ? prediction_global : prediction_local;
   assign result_for_chooser_upd = ghr_is_correct;
   assign ghr_is_correct = (prediction_global == actual_brch_result);
   assign lhr_is_correct = (prediction_local == actual_brch_result);
   assign update_chooser_state = (ghr_is_correct ^ lhr_is_correct) & update_br_pred_state;
   assign update_br_pred_state = brch_instr_detectd_ID & !brch_hazard_stall;
   assign gshare_hash = lpt_addr ^ lpt_ram_addr_ghr;
   //----- Prediction and update logic --------//

     //----- Addr updation logic ----------//
   assign lpt_addr = (brch_instr_detectd_IF) ? branch_addr_lw_5b : branch_addr_lw_5b_int;
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
 
   //-------- GHR ----------//   
   global_history_register i_ghr(
				 .clk(clk),
				 .rst_n(rst_n),
				 .upd_ghr(update_br_pred_state),
				 .actual_br_result_for_shft_reg(actual_brch_result),
				 .ghr_index_for_lpt(lpt_ram_addr_ghr)
				 );
   //-------- GHR ----------//   

   
   //-------- PHT ----------//
   local_pred_table_regs i_lpt_ram_for_global(
				   .clk(clk),
				   .rst_n(rst_n),
				   .upd_pred_state(update_br_pred_state),
				   .actual_brch_result(actual_brch_result),
				   .lpt_addr(gshare_hash),
				   .prediction(prediction_global)
				   );
   //-------- PHT ----------//  
   

   //-------- LHT ----------//   
   local_history_table_shft_regs i_lht_ram(
					   .clk(clk),
					   .rst_n(rst_n),
					   .update_shft_reg(update_br_pred_state),
					   .shft_value(actual_brch_result),
					   .shft_reg_addr_for_updtn(lpt_addr),
					   .lht_entry_to_lpt(lpt_ram_addr_bhrt)
					   );
   //-------- LHT ----------//   

   
   //-------- LPT ----------//
   local_pred_table_regs i_lpt_ram_for_local(
				   .clk(clk),
				   .rst_n(rst_n),
				   .upd_pred_state(update_br_pred_state),
				   .actual_brch_result(actual_brch_result),
				   .lpt_addr(lpt_ram_addr_bhrt),
				   .prediction(prediction_local)
				   );
   //-------- LPT ----------//

   
   //-------- LPT chooser ----------//
   local_pred_table_regs i_lpt_ram_chooser(
				   .clk(clk),
				   .rst_n(rst_n),
				   .upd_pred_state(update_chooser_state),
				   .actual_brch_result(result_for_chooser_upd),
				   .lpt_addr(lpt_ram_addr_bhrt),
				   .prediction(prediction_chooser)
				   );
   //-------- LPT chooser ----------//


   
endmodule // dyn_brnch_pred_correlational
