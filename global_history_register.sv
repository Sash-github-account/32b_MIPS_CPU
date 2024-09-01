module global_history_register(
			       input logic clk,
			       input logic rst_n,
			       input logic upd_ghr,
			       input logic actual_br_result_for_shft_reg,
			       output logic [4:0] ghr_index_for_lpt
			       );
   //--------- Wires ---------//
   //--------- Wires ---------//
   
   //-------- GHR logic --------//
   always_ff@(posedge clk) begin
      if(!rst_n) begin
	 ghr_index_for_lpt <= 5'h00;
      end
      else begin
	 if(upd_ghr) begin
	    ghr_index_for_lpt <= {actual_br_result_for_shft_reg, ghr_index_for_lpt[4:1]};
	 end
	 else begin
	    ghr_index_for_lpt <= ghr_index_for_lpt;
	 end
      end
   end
   //-------- GHR logic --------//

endmodule // global_history_register
