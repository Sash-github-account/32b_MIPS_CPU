module local_pred_table_regs(
			     input logic       clk,
			     input logic       rst_n,
			     input logic       upd_pred_state,
			     input logic [4:0] lpt_addr,
			     input logic       actual_brch_result,
			     output logic      prediction
			     );
   //-------- Wires ----------//
   logic [1:0] 				  lpt_regs[0:31];
   logic [1:0] 				  cur_rdout_state;
   logic [1:0] 				  new_state_for_cur_lpt_reg;
   //-------- Wires ----------//


   
   //-------- FSM state definitions -------//    
   localparam PREDICT_TAKEN_FIRST = 2'b11;
   localparam PREDICT_TAKEN_SECOND = 2'b10;
   localparam PREDICT_NOT_TAKEN_FIRST = 2'b00;
   localparam PREDICT_NOT_TAKEN_SECOND = 2'b01;   
   //-------- FSM state definitions -------//



   //------ Prediction -------//
   assign prediction = cur_rdout_state[1];
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

endmodule // local_pred_table_regs
