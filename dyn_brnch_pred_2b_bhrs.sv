module dyn_brnch_pred_2b_bhrs(
			     input logic       clk,
			     input logic       rst_n,
			     input logic       brch_instr_detectd_ID,
			     input logic       brch_instr_detectd_IF,
			     input logic brch_hazard_stall,
			     input logic [4:0] branch_addr_lw_5b,
			     input logic       actual_brch_result,
			     output logic      prediction
			     );
   //-------- Wires ----------//
   logic [1:0] 				  lpt_regs[0:31];
   logic [1:0] 				  cur_rdout_state;
   logic [1:0] 				  new_state_for_cur_lpt_reg;
         logic 					       upd_pred_state;
      logic [4:0] branch_addr_lw_5b_int;
      logic [4:0] lpt_addr;
   //-------- Wires ----------//


   
   //-------- FSM state definitions -------//    
   localparam PREDICT_TAKEN_FIRST = 2'b11;
   localparam PREDICT_TAKEN_SECOND = 2'b10;
   localparam PREDICT_NOT_TAKEN_FIRST = 2'b00;
   localparam PREDICT_NOT_TAKEN_SECOND = 2'b01;   
   //-------- FSM state definitions -------//


   
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

   

   //------ Prediction -------//
   assign prediction = cur_rdout_state[1]  & brch_instr_detectd_IF;
   assign upd_pred_state =  brch_instr_detectd_ID & !brch_hazard_stall;
   //------ Prediction -------//
   
    
   
   //----- LPT regs --------//
   assign cur_rdout_state = lpt_regs[lpt_addr];
   
   always_ff@(posedge clk) begin
      if(!rst_n) begin
	 for (int i=0; i<32; i=i+1) begin
	    lpt_regs[i] <= 2'b00;
	 end	 
      end
      else begin
	 if(upd_pred_state)begin
	    lpt_regs[lpt_addr] <= new_state_for_cur_lpt_reg;
	 end
      end
   end
   //----- LPT regs --------//


   
   //------ State update logic ---------//
   always_comb begin
      new_state_for_cur_lpt_reg = 2'b00;
      
      case(cur_rdout_state)
	PREDICT_TAKEN_FIRST: begin
	   if(upd_pred_state) begin
	      if(actual_brch_result) new_state_for_cur_lpt_reg = PREDICT_TAKEN_FIRST;
	      else new_state_for_cur_lpt_reg = PREDICT_TAKEN_SECOND;
	   end
	   else begin
	      new_state_for_cur_lpt_reg = cur_rdout_state;
	   end
	end

	PREDICT_TAKEN_SECOND: begin
	   if(upd_pred_state) begin
	      if(actual_brch_result) new_state_for_cur_lpt_reg = PREDICT_TAKEN_FIRST;
	      else new_state_for_cur_lpt_reg = PREDICT_NOT_TAKEN_FIRST;
	   end
	   else begin
	      new_state_for_cur_lpt_reg = cur_rdout_state;
	   end	      
	end

	PREDICT_NOT_TAKEN_FIRST: begin
	   if(upd_pred_state) begin
	      if(actual_brch_result) new_state_for_cur_lpt_reg = PREDICT_NOT_TAKEN_SECOND;
	      else new_state_for_cur_lpt_reg = PREDICT_NOT_TAKEN_FIRST;
	   end
	   else begin
	      new_state_for_cur_lpt_reg = cur_rdout_state;
	   end
	end
	
	PREDICT_NOT_TAKEN_SECOND: begin
	   if(upd_pred_state) begin
	      if(actual_brch_result) new_state_for_cur_lpt_reg = PREDICT_TAKEN_FIRST;
	      else new_state_for_cur_lpt_reg = PREDICT_NOT_TAKEN_FIRST;
	   end
	   else begin
	      new_state_for_cur_lpt_reg = cur_rdout_state;
	   end
	end

	default: new_state_for_cur_lpt_reg = 2'b00;
      endcase     
   end
   //------ State update logic ---------//   

endmodule // dyn_brnch_pred_2b_bhrs
