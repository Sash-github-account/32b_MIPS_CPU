module dyn_brnch_pred_1b_lhr(
		             input logic       clk,
			     input logic       rst_n,
			     input logic       upd_pred_state,
			     input logic [4:0] lpt_addr,
			     input logic       actual_brch_result,
			     output logic      prediction
			     );
   //-------- Wires ----------//
   logic  				       lpt_regs[0:31];
   logic  				       cur_rdout_state;
   logic  				       new_state_for_cur_lpt_reg;
   //-------- Wires ----------//


   
   //-------- FSM state definitions -------//    
   localparam PREDICT_TAKEN= 1'b1;
   localparam PREDICT_NOT_TAKEN = 1'b0;   
   //-------- FSM state definitions -------//



   //------ Prediction -------//
   assign prediction = cur_rdout_state;
   //------ Prediction -------//
   
    
   
   //----- BHRs --------//
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
   //----- BHRs --------//

   //-------- Logic --------//
   assign predict_br_taken = cur_br_state & brch_instr_detectd_IF;
   
   always_comb begin
      new_state_for_cur_lpt_reg = 1'b0;
      
	 case(cur_rdout_state)
	   PREDICT_TAKEN: begin
	      if(upd_pred_state) begin
		 if(actual_brch_result) new_state_for_cur_lpt_reg = PREDICT_TAKEN;
		 else new_state_for_cur_lpt_reg = PREDICT_NOT_TAKEN;
	      end
	      else begin
		 new_state_for_cur_lpt_reg = cur_rdout_state;
	      end
	   end

	   PREDICT_NOT_TAKEN: begin
	      if(upd_pred_state) begin
		 if(actual_brch_result) new_state_for_cur_lpt_reg = PREDICT_TAKEN;
		 else new_state_for_cur_lpt_reg = PREDICT_NOT_TAKEN;
	      end
	      else begin
		 new_state_for_cur_lpt_reg = cur_rdout_state;
	      end
	   end

	   default:  new_state_for_cur_lpt_reg = 1'b0;
	 endcase

      end // else: !if(!rst_n)
   end // always_ff@ (posedge clk)
   //-------- Logic --------//

endmodule // dyn_brnch_pred_1b
