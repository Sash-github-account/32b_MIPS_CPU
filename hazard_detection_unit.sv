module hazard_detection_unit(
			     input logic       IDEX_memread_ctrl,
			     input logic [4:0] IDEX_reg_rt,
			     input logic [4:0] IFID_reg_rs,
			     input logic [4:0] IFID_reg_rt,
			     output logic      hazard_detected
			     );




   //******* Wires **********//
   logic 				       compare_rt_rs_regs;
   logic 				       compare_rt_rt_regs;
   //******* Wires **********//


   //******* Logic *********//
   assign compare_rt_rs_regs = (IDEX_reg_rt == IFID_reg_rs);
   assign compare_rt_rt_regs = (IDEX_reg_rt == IFID_reg_rt);
   assign hazard_detected = IDEX_memread_ctrl & (compare_rt_rs_regs | compare_rt_rt_regs);
   //******* Logic *********//

endmodule // hazard_detection_unit



