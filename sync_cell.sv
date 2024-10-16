module sync_cell(
		 input logic clk,
		 input logic rst_n,
		 input logic data_in,
		 output logic syncd_data_out
		 );


   //========= Wires ========//
   logic 		      dflop1;
   logic 		      dflop2;
   //========= Wires ========//

   //========= Sync logic =========//
   assign syncd_data_out = dflop2;
   
   always_ff@(posedge clk)begin
      if(!rst_n) begin
	 dflop1 <= 1'b0;
	 dflop2 <= 1'b0;
      end
      else begin
	 dflop1 <= data_in;
	 dflop2 <= dflop1;
      end
   end
   //========= Sync logic =========//

endmodule // sync_cell
