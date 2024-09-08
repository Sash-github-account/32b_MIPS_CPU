   module exception_hndlr(
			  input logic 	      clk,
			  input logic 	      rst_n,
			  input logic 	      alu_ovrflw_exception_detected,
			  input logic 	      decode_exception_detected,
			  input logic [31:0]  cur_pc_plus_4_EX,
			  input logic [31:0]  cur_pc_plus_4_ID,
			  output logic 	      exceptn_flush_ID_stg,
			  output logic 	      excceptn_flush_EX_stg,
			  output logic [31:0] exception_vec_addr,
			  output logic 	      load_exceptn_vec_addr
		       );
   //***** Wires *******//
   logic [31:0] 		    exceptn_pc_reg;
   logic [31:0] 		    exceptn_cause_reg;
   logic [31:0] 		    exceptn_cause_reg_mask;
   logic [1:0] 			    upd_excptn_pc_reg;
   //***** Wires *******//

   
   //******* Params ********//
   localparam UNDEF_INSTR_CAUSE_REG_VAL = 10;
   localparam ARITH_OVRFLW_CAUSE_REG_VAL = 12;
   localparam UNDEF_INSTR_EXCPTN_VEC = 32'h80000000;
   localparam ARITH_OVRFLW_EXCPTN_VEC = 32'h80000180;
   localparam INSTR_NUM_BYTES = 4;
   //******* Params ********//
   
  
   //****** Logic *******//
   assign exceptn_cause_reg_mask = 32'b00000000000000000000000000011111;
   assign exceptn_flush_ID_stg = decode_exception_detected | alu_ovrflw_exception_detected;
   assign excceptn_flush_EX_stg = alu_ovrflw_exception_detected;
   assign upd_excptn_pc_reg = {exceptn_flush_ID_stg, excceptn_flush_EX_stg};  
   //****** Logic *******//


   //***** Exception vector address calc *******//
   always@(*) begin
      exception_vec_addr = 32'h0;
      load_exceptn_vec_addr = 1'b0;
      case(upd_excptn_pc_reg)
	 2'b00:  begin
	    exception_vec_addr = 32'h0;
	    load_exceptn_vec_addr = 1'b0;
	 end
	 2'b01:  begin 
	    exception_vec_addr = ARITH_OVRFLW_EXCPTN_VEC;
	    load_exceptn_vec_addr = 1'b1;
	 end
	 2'b10:  begin 
	    exception_vec_addr = UNDEF_INSTR_EXCPTN_VEC;
	    load_exceptn_vec_addr = 1'b1;
	 end
	 2'b11:  begin 
	    exception_vec_addr = ARITH_OVRFLW_EXCPTN_VEC;
	    load_exceptn_vec_addr = 1'b1;
	 end
	 default: begin
	    exception_vec_addr = 32'h0;
	    load_exceptn_vec_addr = 1'b0;
	 end
      endcase
   end
   //***** Exception vector address calc *******//
   

   //***** Exception registers ********//
   always_ff@(posedge clk) begin
      if(!rst_n) begin
	 exceptn_pc_reg <= 32'h00000000;
      end
      else begin
	 case(upd_excptn_pc_reg)
	   2'b00: exceptn_pc_reg <= exceptn_pc_reg; // no exceptions detected
	   2'b01: exceptn_pc_reg <= cur_pc_plus_4_EX - (INSTR_NUM_BYTES*2); // exception detected in EX stage
	   2'b10: exceptn_pc_reg <= cur_pc_plus_4_ID - (INSTR_NUM_BYTES*1); // exception detected in ID stage
	   2'b11: exceptn_pc_reg <= cur_pc_plus_4_EX - (INSTR_NUM_BYTES*2); // exception detected in both EX & ID stages
	   default: exceptn_pc_reg <= exceptn_pc_reg; // no exceptions detected	   
	 endcase
      end
   end

   always_ff@(posedge clk) begin
      if(!rst_n) begin
	 exceptn_cause_reg <= 32'h0000;
      end
      else begin
	 case(upd_excptn_pc_reg)
	   2'b00: exceptn_cause_reg <= exceptn_cause_reg; // no exceptions detected
	   2'b01: exceptn_cause_reg <= exceptn_cause_reg_mask & ARITH_OVRFLW_CAUSE_REG_VAL; // exception detected in EX stage
	   2'b10: exceptn_cause_reg <= exceptn_cause_reg_mask & UNDEF_INSTR_CAUSE_REG_VAL; // exception detected in ID stage
	   2'b11: exceptn_cause_reg <= exceptn_cause_reg_mask & ARITH_OVRFLW_CAUSE_REG_VAL; // exception detected in both EX & ID stages
	   default: exceptn_cause_reg <= exceptn_cause_reg; // no exceptions detected	   
	 endcase
      end
   end
   //***** Exception registers ********//


endmodule // exception_hndlr


   
