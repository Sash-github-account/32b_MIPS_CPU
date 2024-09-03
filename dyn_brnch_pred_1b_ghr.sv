module dyn_brnch_pred_1b_ghr(
			 input logic  clk,
			 input logic  rst_n,
			 input logic  brch_instr_detectd_ID,
			 input logic  brch_instr_detectd_IF,
			 input logic  actual_brch_result,
			 output logic predict_br_taken
			 );

   //--------- Wires ----------//
   logic 			      cur_br_state;
   localparam PREDICT_TAKEN = 1'b1;
   localparam PREDICT_NOT_TAKEN = 1'b0;
   //--------- Wires ----------//


   //-------- Logic --------//
   assign predict_br_taken = cur_br_state & brch_instr_detectd_IF;
   
   always_ff@(posedge clk) begin
      if(!rst_n) begin
	 cur_br_state <= 1'b0;
      end
      else begin
	 case(cur_br_state)
	   PREDICT_TAKEN: begin
	      if(brch_instr_detectd_ID) begin
		 if(actual_brch_result) cur_br_state <= PREDICT_TAKEN;
		 else cur_br_state <= PREDICT_NOT_TAKEN;
	      end
	      else begin
		 cur_br_state <= cur_br_state;
	      end
	   end

	   PREDICT_NOT_TAKEN: begin
	      if(brch_instr_detectd_ID) begin
		 if(actual_brch_result) cur_br_state <= PREDICT_TAKEN;
		 else cur_br_state <= PREDICT_NOT_TAKEN;
	      end
	      else begin
		 cur_br_state <= cur_br_state;
	      end
	   end
	 endcase

      end // else: !if(!rst_n)
   end // always_ff@ (posedge clk)
   //-------- Logic --------//

endmodule // dyn_brnch_pred_1b
