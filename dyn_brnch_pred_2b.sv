module dyn_brnch_pred_2b(
			 input logic  clk,
			 input logic  rst_n,
			 input logic  brch_instr_detectd_ID,
			 input logic  brch_instr_detectd_IF,
			 input logic  brch_hazard_stall,
			 input logic  actual_brch_result,
			 output logic predict_br_taken
			 );

   //--------- Wires ----------//
   logic [1:0] 			      cur_br_state;
   logic 			      update_br_pred_state;
   //--------- Wires ----------//
   
   //-------- FSM state definitions -------//    
   localparam PREDICT_TAKEN_FIRST = 2'b11;
   localparam PREDICT_TAKEN_SECOND = 2'b10;
   localparam PREDICT_NOT_TAKEN_FIRST = 2'b00;
   localparam PREDICT_NOT_TAKEN_SECOND = 2'b01;   
   //-------- FSM state definitions -------//


   //-------- br pred 2b FSM Logic --------//
   assign predict_br_taken = cur_br_state[1] & brch_instr_detectd_IF;
   assign update_br_pred_state = brch_instr_detectd_ID & !brch_hazard_stall;
   
   always_ff@(posedge clk) begin
      if(!rst_n) begin
	 cur_br_state <= 2'b00;
      end
      else begin
	 case(cur_br_state)
	   PREDICT_TAKEN_FIRST: begin
	      if(update_br_pred_state) begin
		 if(actual_brch_result) cur_br_state <= PREDICT_TAKEN_FIRST;
		 else cur_br_state <= PREDICT_TAKEN_SECOND;
	      end
	      else begin
		 cur_br_state <= cur_br_state;
	      end
	   end

	   PREDICT_TAKEN_SECOND: begin
	      if(update_br_pred_state) begin
		 if(actual_brch_result) cur_br_state <= PREDICT_TAKEN_FIRST;
		 else cur_br_state <= PREDICT_NOT_TAKEN_FIRST;
	      end
	      else begin
		 cur_br_state <= cur_br_state;
	      end	      
	   end

	   PREDICT_NOT_TAKEN_FIRST: begin
	      if(update_br_pred_state) begin
		 if(actual_brch_result) cur_br_state <= PREDICT_NOT_TAKEN_SECOND;
		 else cur_br_state <= PREDICT_NOT_TAKEN_FIRST;
	      end
	      else begin
		 cur_br_state <= cur_br_state;
	      end
	   end
	   
	   PREDICT_NOT_TAKEN_SECOND: begin
	      if(update_br_pred_state) begin
		 if(actual_brch_result) cur_br_state <= PREDICT_TAKEN_FIRST;
		 else cur_br_state <= PREDICT_NOT_TAKEN_FIRST;
	      end
	      else begin
		 cur_br_state <= cur_br_state;
	      end
	   end
	 endcase

      end // else: !if(!rst_n)
   end // always_ff@ (posedge clk)
   //-------- Logic --------//

endmodule // dyn_brnch_pred_2b

