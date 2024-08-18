module forwarding_unit(
		       input logic 	   EXMEM_regwrite_ctrl,
		       input logic [4:0]   EXMEM_reg_rd,
		       input logic [4:0]   IDEX_reg_rs,
		       input logic [4:0]   IDEX_reg_rt,
		       input logic 	   MEMWB_regwrite_ctrl,
		       input logic [4:0]   MEMWB_reg_rd,
		       input logic [31:0]  reg_read_data_1_in,
		       input logic [31:0]  reg_read_data_2_in, 
		       input logic [31:0]  EXMEM_alu_output,
		       input logic [31:0]  MEMWB_mux_output,
		       output logic [31:0] read_data_1,
		       output logic [31:0] read_data_2
		       );



   //********** wires *********//
   logic 				 fwd_a_b_10_cmn_lgc;
   logic 				 fwd_a_b_01_cmn_lgc;
   logic 				 set_fwd_a_10;
   logic 				 set_fwd_b_10;
   logic 				 set_fwd_a_01;
   logic 				 set_fwd_b_01;
   logic [1:0] 				 forward_a;
   logic [1:0] 				 forward_b;
   logic 				 mem_stg_exclusions_rs;
   logic 				 mem_stg_exclusions_rt;   
   //********** wires *********//


   //******** Logic **********//
   //***** EX hazard ******//
   assign fwd_a_b_10_cmn_lgc = (EXMEM_regwrite_ctrl) & (EXMEM_reg_rd != 0);
   assign set_fwd_a_10 = fwd_a_b_10_cmn_lgc & (EXMEM_reg_rd == IDEX_reg_rs);
   assign set_fwd_b_10 = fwd_a_b_10_cmn_lgc & (EXMEM_reg_rd == IDEX_reg_rt);
   assign mem_stg_exclusions_rs = !(set_fwd_a_10);
   assign mem_stg_exclusions_rt = !(set_fwd_b_10);   
   //**********************//

   //******** MEM hazard *********//
   assign fwd_a_b_01_cmn_lgc = (MEMWB_regwrite_ctrl) & (MEMWB_reg_rd != 0);
   assign set_fwd_a_01 = (fwd_a_b_01_cmn_lgc)  & mem_stg_exclusions_rs & (MEMWB_reg_rd == IDEX_reg_rs);
   assign set_fwd_b_01 = (fwd_a_b_01_cmn_lgc)  & mem_stg_exclusions_rt & (MEMWB_reg_rd == IDEX_reg_rt);
   //*****************************//

   //********* forwarding control outputs *********//
   always_comb begin
      // Defaults //
      forward_a = 2'b00;
      forward_b = 2'b00;
      // Forward 'b' control generation //
      if(set_fwd_b_10) begin
	 forward_b = 2'b10;
      end
      else if(set_fwd_b_01) begin
	 forward_b = 2'b01;
      end
      else begin
	 forward_b = 2'b00;
      end 
     // Forward 'a' control generation //
      if(set_fwd_a_10) begin
	 forward_a = 2'b10;
      end
      else if(set_fwd_a_01) begin
	 forward_a = 2'b01;
      end
      else begin
	 forward_a = 2'b00;
      end

   end
   //********* forwarding control outputs *********// 
   
   //********* forwarding MUXes *********// 
   always_comb begin
      case(forward_a)
	2'b00: begin
	   read_data_1 = reg_read_data_1_in;
	end
	2'b01: begin
	   read_data_1 = MEMWB_mux_output;
	end
	2'b10: begin
	   read_data_1 = EXMEM_alu_output;
	end
	default: begin
	   read_data_1 = reg_read_data_1_in;
	end
      endcase 

      case(forward_b)
	2'b00: begin
	   read_data_2 = reg_read_data_2_in;
	end
	2'b01: begin
	   read_data_2 = MEMWB_mux_output;
	end
	2'b10: begin
	   read_data_2 = EXMEM_alu_output;
	end
	default: begin
	   read_data_2 = reg_read_data_2_in;
	end
      endcase    
   end
   //********* forwarding MUXes *********//   
   //******** Logic **********//   

endmodule // forwarding_unit
