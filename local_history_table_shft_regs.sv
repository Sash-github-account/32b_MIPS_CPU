module local_history_table_shft_regs(
			   input logic clk,
			   input logic rst_n,
			   input logic update_shft_reg,
			   input logic shft_value,
			   input logic[4:0] shft_reg_addr_for_updtn,
			   output logic[4:0] lht_entry_to_lpt
			   );
   //-------- Wires ---------//
   logic [4:0] 				     lht_shft_regs[0:31];
   
   //-------- Wires ---------//

   //-------- LHT shft regs ----------//
   assign lht_entry_to_lpt = lht_shft_regs[shft_reg_addr_for_updtn];
   
   always_ff@(posedge clk) begin
      if(!rst_n)begin
	 for (int i=0; i<32; i=i+1) begin
	    lht_shft_regs[i] <= 5'h00;
	 end
      end
      else begin
	 if(update_shft_reg)begin
	    lht_shft_regs[shft_reg_addr_for_updtn] <= {shft_value, lht_entry_to_lpt[4:1]};
	 end
      end
   end
   //-------- LHT shft regs ----------//

endmodule // local_history_table

   
