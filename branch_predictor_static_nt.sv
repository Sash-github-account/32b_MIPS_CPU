module branch_predictor_static_nt(
			input logic [31:0] reg1_val,
			input logic [31:0] reg2_val,
			input logic 	   branch_instr_detected,
			output logic 	   branch_taken
			);


   //*** Logic ****//
   assign branch_taken = (branch_instr_detected) ? (reg1_val == reg2_val) : 0;
   //************//
endmodule // branch_predictor_static_nt

   
