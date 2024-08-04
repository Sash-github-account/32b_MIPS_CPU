module hazard_detection_unit(
			     input logic       clk,
			     input logic       rst_n,
			     input logic       IDEX_memread_ctrl,
			     input logic [4:0] IDEX_reg_rt,
			     input logic [4:0] IFID_reg_rs,
			     input logic [4:0] IFID_reg_rt,
			     output logic      hazard_detected
			     );




   //******* Wires **********//
   logic 				       compare_rt_rs_regs;
   logic 				       compare_rt_rt_regs;
   logic 				       haz_reg1;
   logic 				       haz_reg2;
   logic 				       hazard_detected_init;
   //******* Wires **********//


   //******* Logic *********//
   assign compare_rt_rs_regs = (IDEX_reg_rt == IFID_reg_rs);
   assign compare_rt_rt_regs = (IDEX_reg_rt == IFID_reg_rt);
   assign hazard_detected_init = IDEX_memread_ctrl & (compare_rt_rs_regs | compare_rt_rt_regs);
   assign hazard_detected = hazard_detected_init;
   //******* Logic *********//

   //******* gen hazard signal optional delay *******//
   always_ff@(posedge clk) begin
      if(!rst_n) begin
	 haz_reg1 <= 0;
	 haz_reg2 <= 0;
      end
      else begin
	 haz_reg1 <= hazard_detected_init;
	 haz_reg2 <= haz_reg1;
      end
   end
endmodule // hazard_detection_unit



