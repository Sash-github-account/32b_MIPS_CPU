// reference : Computer Organization and design; David A. Patterson, John L. Hennessy
/*`include "alu.sv"
 `include "alu_control.sv"
 `include "cpu_main_ctrl.sv"
 `include "pc.sv"
 `include "registers.sv"*/

module CPU_MIPS_32b_5stage(
			   input logic 	      clk,
			   input logic 	      rst_n_async,
			   //input logic [31:0]  instruction_i, 
			   output logic [0:7] LED_o
			   );


   //**********Declarations*************//
  localparam [31:0] INSTR_FOR_LED_OUT = 3;
   logic 				      memread_ctrl;
   logic [4:0] 				      write_register_in_mux;
   logic [31:0] 			      reg_write_data_mux;
   logic [31:0] 			      alu_result;
   logic [1:0] 				      aluop_ctrl;
   logic [3:0] 				      alu_ctrl;
   logic 				      alusrc_ctrl;
   logic 				      memtoreg_ctrl;
   logic 				      regdst_ctrl; 
   logic [31:0] 			      read_data_1;
   logic [31:0] 			      read_data_2;
   logic [31:0] 			      read_data_1_in_to_alu;
   logic [31:0] 			      read_data_2_in_to_alu;
   logic [31:0] 			      alu_op_2_mux;
   logic [31:0] 			      br_instr_offset_sign_extd;
   logic [31:0] 			      instruction;
   logic [31:0] 			      data_mem_addr;
   logic [31:0] 			      data_mem_wrdata;
   logic [31:0] 			      inst_mem_rd_addr;
   logic [31:0] 			      data_mem_rd_data;
   logic 				      led_load;
   logic [7:0] 				      reg_led_o;
   logic 				      pc_halted;
   logic 				      jump_ctrl;  
   logic 				      jump_detected;
   logic 				      branch_ctrl;   
   logic 				      memwrite_ctrl;   
   logic 				      regwrite_ctrl;   
   logic [31:0] 			      branch_address;
   logic [1:0] 				      forward_a;
   logic [1:0] 				      forward_b;
   logic 				      hazard_detected;
   logic 				      branch_hazard_stall;
   logic 				      branch_taken_IF_flush;
   logic [4:0] 				      write_register_in_mux_to_EXMEM_pipe;
   logic [31:0] 			      br_instr_offset_sign_extd_to_IDEX_pipe;
   logic [31:0] 			      data_mem_wrdata_to_EXMEM_pipe;
   logic [31:0] 			      pc_plus_4_to_IFID_pipe;
   logic [31:0] 			      pc_plus_4_to_IDEX_pipe;
   logic [31:0] 			      read_data_1_to_IDEX_pipe;
   logic [31:0] 			      read_data_2_to_IDEX_pipe; 
   logic [1:0] 				      aluop_ctrl_to_IDEX_pipe;
   logic 				      regdst_ctrl_to_IDEX_pipe;
   logic 				      jump_ctrl_to_IDEX_pipe;
   logic 				      branch_ctrl_to_IDEX_pipe;
   logic 				      memread_ctrl_to_IDEX_pipe;
   logic 				      memwrite_ctrl_to_IDEX_pipe;
   logic 				      memtoreg_ctrl_to_IDEX_pipe;
   logic 				      alusrc_ctrl_to_IDEX_pipe;
   logic 				      regwrite_ctrl_to_IDEX_pipe;
   logic [4:0] 				      instruction_25_21;
   logic [4:0] 				      instruction_15_11;
   logic [4:0] 				      instruction_20_16;
   logic [4:0] 				      reg_rs_from_IDEX;
   logic [4:0] 				      reg_rd_from_IDEX;
   logic [4:0] 				      reg_rt_from_IDEX;
   logic [5:0] 				      instruction_5_0; 
   logic [31:0] 			      pc_plus_4;
   logic 				      jump_ctrl_to_EXMEM_pipe    ;
   logic 				      branch_ctrl_to_EXMEM_pipe  ;
   logic 				      memread_ctrl_to_EXMEM_pipe ;
   logic 				      memwrite_ctrl_to_EXMEM_pipe;
   logic 				      memtoreg_ctrl_to_EXMEM_pipe;
   logic 				      regwrite_ctrl_to_EXMEM_pipe;
   logic [31:0] 			      alu_result_to_EXMEM_pipe;
   logic [4:0] 				      write_register_in_mux_to_MEMWB_pipe;
   logic [31:0] 			      alu_result_to_MEMWB_pipe;
   logic [31:0] 			      data_mem_rd_data_to_MEMWB_pipe;   
   logic 				      memtoreg_ctrl_to_MEMWB_pipe;
   logic 				      regwrite_ctrl_to_MEMWB_pipe;
   logic [31:0] 			      br_instr_offset_sign_extdt_shft_l_2;
   logic [31:0] 			      branch_address_to_EXMEM_pipe;
   logic 				      cpu_ctrl_stall;
   logic 				      br_prediction;
   logic [31:0] 			      br_instr_offset_sign_extd_to_IDEX_pipe_choose;
   logic [31:0] 			      br_instr_offset_sign_extd_to_IFID_pipe;   
   logic 				      arith_ovrflw_exceptn_detected;
   logic 				      decode_exception_detected;
   logic 				      exceptn_flush_ID_stg;
   logic 				      excceptn_flush_EX_stg;
   logic 				      load_exceptn_vec_addr;
   logic [31:0] 			      exception_vec_addr;
   logic 				      IF_flush;
   logic 				      cache_miss_icache;
   logic 				      cache_miss_stall;
   logic [31:0] 			      l2_mem_access_addr_dcache;
   logic [31:0] 			      l2_mem_wr_data_dcache;
   logic [31:0] 			      l2_mem_rd_data_dcache;
   logic 				      l2_mem_wr_en_dcache;  
   logic 				      l2_mem_en_dcache;   
   logic [31:0] 			      l2_mem_access_addr_icache;
   logic [31:0] 			      l2_mem_wr_data_icache;
   logic [31:0] 			      l2_mem_rd_data_icache;
   logic 				      l2_mem_wr_en_icache;  
   logic 				      l2_mem_en_icache;
   logic [31:0] 			      l2_mem_access_addr;
   logic [31:0] 			      l2_mem_wr_data;
   logic [31:0] 			      l2_mem_rd_data;
   logic 				      l2_mem_wr_en;  
   logic 				      l2_mem_en;
   logic [31:0] 			      instruction_i;
   logic 				      l2_bus_arbiter_rd_granted_icache;
   logic 				      l2_bus_arbiter_rd_granted_dcache;
   
   //***********************************//




   //************** Comb logic ***************//
  assign write_register_in_mux_to_EXMEM_pipe = (regdst_ctrl) ? instruction_15_11 : instruction_20_16;
   assign reg_write_data_mux = (memtoreg_ctrl) ? data_mem_rd_data : alu_result;
   //assign reg_write_data_mux = (memtoreg_ctrl_to_MEMWB_pipe) ? data_mem_rd_data_to_MEMWB_pipe : alu_result_to_MEMWB_pipe;
   assign br_instr_offset_sign_extd_to_IFID_pipe = (instruction_i[15]) ? {16'hffff,instruction_i[15:0]} : {16'h0000,instruction_i[15:0]};
   assign br_instr_offset_sign_extd_to_IDEX_pipe_choose = (instruction[15]) ? {16'hffff,instruction[15:0]} : {16'h0000,instruction[15:0]};
   assign br_instr_offset_sign_extd_to_IDEX_pipe = (br_prediction & !cpu_ctrl_stall) ? br_instr_offset_sign_extd_to_IFID_pipe : br_instr_offset_sign_extd_to_IDEX_pipe_choose;
   assign alu_op_2_mux = (alusrc_ctrl) ? br_instr_offset_sign_extd : read_data_2_in_to_alu;
   assign data_mem_addr = alu_result_to_MEMWB_pipe;// << 2;
   assign data_mem_wrdata_to_EXMEM_pipe = read_data_2_in_to_alu;
   assign led_load = (inst_mem_rd_addr == INSTR_FOR_LED_OUT) ? 1'b1:1'b0;
   assign IF_flush = branch_taken_IF_flush;
   assign cache_miss_stall = cache_miss_icache | cache_miss_dcache;
   //***********************************//
   
   
   //************Instantiations*********//


   // IF/ID stage 
   always_ff@(posedge clk)begin
      if(!rst_n)begin
	 instruction <= 32'b0;
	 pc_plus_4_to_IDEX_pipe <= 32'h0;
      end
      else begin      
	 if(cpu_ctrl_stall) begin
            instruction <= (IF_flush) ? 32'h00000000 : instruction;
	    pc_plus_4_to_IDEX_pipe <= pc_plus_4_to_IDEX_pipe;
	 end
	 else begin
            instruction <= (IF_flush) ? 32'h00000000 : instruction_i;
	    pc_plus_4_to_IDEX_pipe <= pc_plus_4_to_IFID_pipe;
	 end
      end
   end
   
   
   //ID/EX stage   
   assign reg_rs_from_IDEX = instruction_25_21;
   assign reg_rd_from_IDEX = instruction_15_11;
   assign reg_rt_from_IDEX = instruction_20_16;
   
   
   always_ff@(posedge clk)begin
      if(!rst_n)begin
	 read_data_1 <= 32'b0;
	 read_data_2 <= 32'b0;
	 aluop_ctrl <= 32'b0;
	 regdst_ctrl<= 32'b0;  
	 jump_ctrl_to_EXMEM_pipe     <= 0;
	 branch_ctrl_to_EXMEM_pipe   <= 0;
	 memread_ctrl_to_EXMEM_pipe  <= 0;
	 memwrite_ctrl_to_EXMEM_pipe <= 0;
	 memtoreg_ctrl_to_EXMEM_pipe <= 0;
	 alusrc_ctrl<= 32'b0;  
	 regwrite_ctrl_to_EXMEM_pipe <= 1'b0; 
	 instruction_25_21 <= 5'h0; 
	 instruction_15_11 <= 5'h0;
	 instruction_20_16 <= 5'h0;
	 br_instr_offset_sign_extd <= 32'h0;
	 instruction_5_0 <= 6'h0;
	 pc_plus_4 <= 32'h0;
      end
      else begin
	 if(cache_miss_stall) begin
	    br_instr_offset_sign_extd <= br_instr_offset_sign_extd_to_IDEX_pipe_choose;
	    pc_plus_4 <= pc_plus_4_to_IDEX_pipe;
	    if(exceptn_flush_ID_stg) begin
	       read_data_1 <= 32'b0;
	       read_data_2 <= 32'b0;
	       aluop_ctrl <= 32'b0;
	       regdst_ctrl<= 32'b0;  
	       jump_ctrl_to_EXMEM_pipe     <= 0;
	       branch_ctrl_to_EXMEM_pipe   <= 0;
	       memread_ctrl_to_EXMEM_pipe  <= 0;
	       memwrite_ctrl_to_EXMEM_pipe <= 0;
	       memtoreg_ctrl_to_EXMEM_pipe <= 0;
	       alusrc_ctrl<= 32'b0;  
	       regwrite_ctrl_to_EXMEM_pipe <= 1'b0; 
	       instruction_25_21 <= 5'h0; 
	       instruction_15_11 <= 5'h0;
	       instruction_20_16 <= 5'h0;
	       instruction_5_0 <= 6'h0;
	    end // if (exceptn_flush_ID_stg)
	    else begin
	       read_data_1 <=                    read_data_1 ;                    
	       read_data_2 <= 		   read_data_2 ;                    
	       aluop_ctrl <= 			   aluop_ctrl ;                     
	       regdst_ctrl<=   		   regdst_ctrl;                     
	       jump_ctrl_to_EXMEM_pipe     <=    jump_ctrl_to_EXMEM_pipe     ;    
	       branch_ctrl_to_EXMEM_pipe   <=    branch_ctrl_to_EXMEM_pipe   ;    
	       memread_ctrl_to_EXMEM_pipe  <=    memread_ctrl_to_EXMEM_pipe  ;    
	       memwrite_ctrl_to_EXMEM_pipe <=    memwrite_ctrl_to_EXMEM_pipe ;    
	       memtoreg_ctrl_to_EXMEM_pipe <=    memtoreg_ctrl_to_EXMEM_pipe ;    
	       alusrc_ctrl<=   		   alusrc_ctrl;                     
	       regwrite_ctrl_to_EXMEM_pipe <=    regwrite_ctrl_to_EXMEM_pipe ;    
	       instruction_25_21 <=  		   instruction_25_21 ;              
	       instruction_15_11 <= 		   instruction_15_11 ;              
	       instruction_20_16 <= 		   instruction_20_16 ;              
	       br_instr_offset_sign_extd <= 	   br_instr_offset_sign_extd ;      
	       instruction_5_0 <= 		   instruction_5_0 ;                
	       pc_plus_4 <=                      pc_plus_4 ;
	    end
	 end // if (cache_miss_stall)
	 else begin
	    read_data_1    <= read_data_1_to_IDEX_pipe ;
	    read_data_2    <= read_data_2_to_IDEX_pipe ;
	    aluop_ctrl    <=  aluop_ctrl_to_IDEX_pipe ;
	    regdst_ctrl   <= regdst_ctrl_to_IDEX_pipe;  
	    jump_ctrl_to_EXMEM_pipe     <= jump_ctrl_to_IDEX_pipe;    
	    branch_ctrl_to_EXMEM_pipe   <= branch_ctrl_to_IDEX_pipe;  
	    memread_ctrl_to_EXMEM_pipe  <= memread_ctrl_to_IDEX_pipe; 
	    memwrite_ctrl_to_EXMEM_pipe <= memwrite_ctrl_to_IDEX_pipe;
	    memtoreg_ctrl_to_EXMEM_pipe <= memtoreg_ctrl_to_IDEX_pipe;
	    alusrc_ctrl   <= alusrc_ctrl_to_IDEX_pipe;  
	    regwrite_ctrl_to_EXMEM_pipe <= regwrite_ctrl_to_IDEX_pipe;
	    instruction_25_21 <= instruction[25:21];
            instruction_15_11 <= instruction[15:11];
	    instruction_20_16 <= instruction[20:16];
	    instruction_5_0 <= instruction[5:0];
	    br_instr_offset_sign_extd <= br_instr_offset_sign_extd_to_IDEX_pipe_choose;
	    pc_plus_4 <= pc_plus_4_to_IDEX_pipe;
	 end // else: !if(cache_miss_stall)
      end
   end


   //EX/MEM stage
   always_ff@(posedge clk) begin
      if(!rst_n) begin
	 jump_ctrl    <= 0;         
	 branch_ctrl  <= 0;         
	 memread_ctrl <= 0;         
	 memwrite_ctrl<= 0;         
	 memtoreg_ctrl_to_MEMWB_pipe <= 0;         
	 regwrite_ctrl_to_MEMWB_pipe <= 0;         
	 alu_result_to_MEMWB_pipe <= 0;     
	 data_mem_wrdata <= 0;
	 write_register_in_mux_to_MEMWB_pipe <= 0;
      end
      else begin
	 if(cache_miss_stall) begin
	    if(excceptn_flush_EX_stg) begin
	       jump_ctrl    <= 0;         
	       branch_ctrl  <= 0;         
	       memread_ctrl <= 0;         
	       memwrite_ctrl<= 0;         
	       memtoreg_ctrl_to_MEMWB_pipe <= 0;         
	       regwrite_ctrl_to_MEMWB_pipe <= 0;         
	       alu_result_to_MEMWB_pipe <= 0;     
	       data_mem_wrdata <= 0;
	       write_register_in_mux_to_MEMWB_pipe <= 0;
	    end // if (excceptn_flush_EX_stg)
	    else begin
	       jump_ctrl    <=                          jump_ctrl    ;                        
	       branch_ctrl  <=          		  branch_ctrl  ;                        
	       memread_ctrl <=          		  memread_ctrl ;                        
	       memwrite_ctrl<=          		  memwrite_ctrl;                        
	       memtoreg_ctrl_to_MEMWB_pipe <=           memtoreg_ctrl_to_MEMWB_pipe ;         
	       regwrite_ctrl_to_MEMWB_pipe <=           regwrite_ctrl_to_MEMWB_pipe ;         
	       alu_result_to_MEMWB_pipe <=      	  alu_result_to_MEMWB_pipe ;            
	       data_mem_wrdata <= 			  data_mem_wrdata ;                      
	       write_register_in_mux_to_MEMWB_pipe <=   write_register_in_mux_to_MEMWB_pipe ; 
	    end // if (cache_miss_stall)
	 end
	 else begin
	    jump_ctrl <= jump_ctrl_to_EXMEM_pipe    ;         
	    branch_ctrl <= branch_ctrl_to_EXMEM_pipe  ;         
	    memread_ctrl <= memread_ctrl_to_EXMEM_pipe ;         
	    memwrite_ctrl <= memwrite_ctrl_to_EXMEM_pipe;         
	    memtoreg_ctrl_to_MEMWB_pipe <= memtoreg_ctrl_to_EXMEM_pipe;         
	    regwrite_ctrl_to_MEMWB_pipe <= regwrite_ctrl_to_EXMEM_pipe;         
	    alu_result_to_MEMWB_pipe <= alu_result_to_EXMEM_pipe;     
	    data_mem_wrdata <= data_mem_wrdata_to_EXMEM_pipe;
	    write_register_in_mux_to_MEMWB_pipe <= write_register_in_mux_to_EXMEM_pipe;
	    
	 end
      end
   end



   //MEM/WB stage

   always_ff@(posedge clk) begin
      if(!rst_n) begin
	 alu_result <= 32'h0;
	 data_mem_rd_data <= 32'h0;
	 write_register_in_mux <= 5'h0;
	 memtoreg_ctrl <= 0;
	 regwrite_ctrl <= 0;
      end
      else begin
	 if(cache_miss_stall) begin
	    alu_result <=            alu_result ;               
	    data_mem_rd_data <=	  data_mem_rd_data ;         
	    write_register_in_mux <= write_register_in_mux ;    
	    memtoreg_ctrl <= 	  memtoreg_ctrl ;            
	    regwrite_ctrl <=         regwrite_ctrl ;
	 end
	 else begin
	    alu_result <= alu_result_to_MEMWB_pipe;
	    data_mem_rd_data <= data_mem_rd_data_to_MEMWB_pipe;
	    write_register_in_mux <= write_register_in_mux_to_MEMWB_pipe;
	    memtoreg_ctrl <= memtoreg_ctrl_to_MEMWB_pipe;
	    regwrite_ctrl <= regwrite_ctrl_to_MEMWB_pipe;
	 end
      end
   end   

   // branch address calculation
   assign br_instr_offset_sign_extdt_shft_l_2 = br_instr_offset_sign_extd_to_IDEX_pipe << 2;
   assign branch_address = (br_prediction & !cpu_ctrl_stall) ? (pc_plus_4_to_IFID_pipe + br_instr_offset_sign_extdt_shft_l_2) : (pc_plus_4_to_IDEX_pipe + br_instr_offset_sign_extdt_shft_l_2);
   assign cpu_ctrl_stall = (hazard_detected | branch_hazard_stall | cache_miss_stall);


   sync_cell i_rst_sync(
			.clk(clk),
			.rst_n(rst_n_async),
			.data_in(1'b1),
			.syncd_data_out(rst_n)
			);


   
   forwarding_unit i_forwarding_unit(
				     .EXMEM_regwrite_ctrl(regwrite_ctrl_to_MEMWB_pipe	),
				     .EXMEM_reg_rd(write_register_in_mux_to_MEMWB_pipe	),
				     .IDEX_reg_rs(reg_rs_from_IDEX	),
				     .IDEX_reg_rt(reg_rt_from_IDEX	),
				     .MEMWB_regwrite_ctrl(regwrite_ctrl	),
				     .MEMWB_reg_rd(write_register_in_mux	),
				     .reg_read_data_1_in(read_data_1),
				     .reg_read_data_2_in(read_data_2),
				     .EXMEM_alu_output(alu_result_to_MEMWB_pipe),
				     .MEMWB_mux_output(reg_write_data_mux),
				     .read_data_1(read_data_1_in_to_alu),
				     .read_data_2(read_data_2_in_to_alu)
				     );

   hazard_detection_unit i_hazard_detection_unit(
						 .IDEX_memread_ctrl(memread_ctrl_to_EXMEM_pipe),
						 .IDEX_reg_rt(reg_rt_from_IDEX),
						 .IFID_reg_rs(instruction[25:21]),
						 .IFID_reg_rt(instruction[20:16]),
						 .hazard_detected(hazard_detected)
						 );
   
   brnch_pred_hndlr_2b_correl_dyn i_brnch_pred_hndlr(
						     .clk(clk),
						     .rst_n(rst_n),
						     .opcode_for_brnch_instr_detect_IF(instruction_i[31:26]),
						     .opcode_for_brnch_instr_detect_ID(instruction[31:26]),
						     .branch_addr_lw_5b(instruction_i[4:0]),
						     .EXMEM_regwrite_ctrl(regwrite_ctrl_to_MEMWB_pipe),
						     .EXMEM_reg_rd(write_register_in_mux_to_MEMWB_pipe),
						     .IFID_reg_rs(instruction[25:21]),
						     .IFID_reg_rt(instruction[20:16]),
						     .MEMWB_regwrite_ctrl(regwrite_ctrl),
						     .MEMWB_reg_rd(write_register_in_mux),
						     .read_data_1_from_regfile(read_data_1_to_IDEX_pipe),
						     .read_data_2_from_regfile(read_data_2_to_IDEX_pipe),
						     .EXMEM_alu_output(alu_result_to_MEMWB_pipe),
						     .MEMWB_mux_output(reg_write_data_mux),
						     .IDEX_regwrite_ctrl(regwrite_ctrl_to_MEMWB_pipe),
						     .IDEX_reg_rd(reg_rd_from_IDEX),
						     .IDEX_memread_ctrl(memread_ctrl_to_IDEX_pipe),
						     .IDEX_memtoreg_ctrl(memtoreg_ctrl_to_IDEX_pipe),
						     .IDEX_alusrc_ctrl(alusrc_ctrl_to_IDEX_pipe),
						     .branch_hazard_stall(branch_hazard_stall),
						     .br_prediction(br_prediction),
						     .flush(branch_taken_IF_flush),
						     .jump_detected(jump_detected)
						     );



   exception_hndlr i_exception_hndlr(
				     .clk(clk),
				     .rst_n(rst_n),
				     .alu_ovrflw_exception_detected(arith_ovrflw_exceptn_detected),
				     .decode_exception_detected(decode_exception_detected),
				     .cur_pc_plus_4_EX(pc_plus_4),
				     .cur_pc_plus_4_ID(pc_plus_4_to_IDEX_pipe),
				     .exceptn_flush_ID_stg(exceptn_flush_ID_stg),
				     .excceptn_flush_EX_stg(excceptn_flush_EX_stg),
				     .exception_vec_addr(exception_vec_addr),
				     .load_exceptn_vec_addr(load_exceptn_vec_addr)
				     );


   
   pc i_pc(
	   .clk(clk),
	   .rst_n(rst_n),
	   .instruction_jmp_imm(instruction_i[25:0]),
	   .hazard_detected(cpu_ctrl_stall),
	   .load_exceptn_vec_addr(load_exceptn_vec_addr),
	   .exception_vec_addr(exception_vec_addr),
	   .branch_address(branch_address),
	   .br_ctrl_mux_sel(br_prediction | branch_taken_IF_flush),
	   .jump_ctrl(jump_detected),
	   .final_nxt_pc_mux(),
	   .pc_plus_4(pc_plus_4_to_IFID_pipe),
	   .cur_pc(inst_mem_rd_addr)
	   );

   regfile_fwd_wr i_registers1(
			       .clk(clk),
			       .rst_n(rst_n),
			       .read_register_1(instruction[25:21]),
			       .read_register_2(instruction[20:16]),
			       .write_register(write_register_in_mux),
			       .write_data(reg_write_data_mux),
			       .regwrite_ctrl(regwrite_ctrl),
			       .read_data_1_o(read_data_1_to_IDEX_pipe),
			       .read_data_2_o(read_data_2_to_IDEX_pipe),
			       .reg_led_o(reg_led_o)
			       );

   alu i_alu(
	     .op_1(read_data_1_in_to_alu),
	     .op_2(alu_op_2_mux),
	     .alu_ctrl(alu_ctrl),
	     .alu_result(alu_result_to_EXMEM_pipe),
	     .arith_ovrflw_exceptn_detected(arith_ovrflw_exceptn_detected)
	     );

   alu_control i_alu_control(
			     .instruction_funct(instruction_5_0),
			     .alu_op_ctrl(aluop_ctrl),
			     .alu_ctrl(alu_ctrl)
			     );
   
   cpu_main_ctrl i_cpu_main_ctrl(
				 .instruction_opcode(instruction[31:26]),
				 .hazard_detected(cpu_ctrl_stall),
				 .aluop_ctrl(aluop_ctrl_to_IDEX_pipe),
				 .regdst_ctrl(regdst_ctrl_to_IDEX_pipe),
				 .jump_ctrl(jump_ctrl_to_IDEX_pipe),
				 .branch_ctrl(branch_ctrl_to_IDEX_pipe),
				 .memread_ctrl(memread_ctrl_to_IDEX_pipe),
				 .memwrite_ctrl(memwrite_ctrl_to_IDEX_pipe),
				 .memtoreg_ctrl(memtoreg_ctrl_to_IDEX_pipe),
				 .alusrc_ctrl(alusrc_ctrl_to_IDEX_pipe),
				 .regwrite_ctrl(regwrite_ctrl_to_IDEX_pipe),
				 .decode_exception_detected(decode_exception_detected)
				 ); 
   
   //	instr_rom		i_instr_rom (
   //	.address(inst_mem_rd_addr_to_instmem),
   //	.clock(clk),
   //	.q(instruction));	
   
   //data_ram i_data_ram(
   //		       .address(data_mem_addr[5:0]),
   //		       .clock(clk),
   //		       .data(data_mem_wrdata),
   //		       .wren(memwrite_ctrl),
   //		       .q(data_mem_rd_data_to_MEMWB_pipe));
   
   design_1 i_data_ram(
		       .addra(l2_mem_access_addr),
		       .clka(clk),
		       .dina(l2_mem_wr_data),
		       .ena(l2_mem_en),//memwrite_ctrl),
		       .wea(l2_mem_wr_en),
		       .douta(l2_mem_rd_data));  


   l2_mem_bus_arbiter i_l2_bus_arb(
				   .clk(clk),
				   .rst_n(rst_n),
				   .l2_mem_access_addr_dcache(l2_mem_access_addr_dcache),
				   .l2_mem_wr_data_dcache(l2_mem_wr_data_dcache),
				   .l2_mem_rd_data_dcache(l2_mem_rd_data_dcache),
				   .l2_mem_wr_en_dcache(l2_mem_wr_en_dcache), 
				   .l2_mem_en_dcache(l2_mem_en_dcache), 
				   .l2_mem_access_addr_icache(l2_mem_access_addr_icache),
				   .l2_mem_wr_data_icache(l2_mem_wr_data_icache),
				   .l2_mem_rd_data_icache(l2_mem_rd_data_icache),
				   .l2_mem_wr_en_icache(l2_mem_wr_en_icache), 
				   .l2_mem_en_icache(l2_mem_en_icache),
				   .l2_mem_access_addr(l2_mem_access_addr),
				   .l2_mem_wr_data(l2_mem_wr_data),
				   .l2_mem_rd_data(l2_mem_rd_data),
				   .l2_mem_wr_en(l2_mem_wr_en),
				   .l2_mem_en(l2_mem_en),
				   .rd_grant_icache_active(l2_bus_arbiter_rd_granted_icache),
				   .rd_grant_dcache_active(l2_bus_arbiter_rd_granted_dcache),
				   .wr_grant_icache_active(l2_bus_arbiter_wr_granted_icache),
				   .wr_grant_dcache_active(l2_bus_arbiter_wr_granted_dcache)
				   );
   

   cache_set_associative_256sets_4blocks_4words i_icache(
							 .clk(clk),
							 .rst_n(rst_n),
							 .address(inst_mem_rd_addr),
							 .wrdata_in(32'h00000000),
							 .wr_cache(1'b0),
							 .rd_cache(1'b1),
							 .rd_data_o(instruction_i),
							 .cache_miss(cache_miss_icache),
							 .l2_bus_arbiter_rd_granted(l2_bus_arbiter_rd_granted_icache),
							 .l2_bus_arbiter_wr_granted(l2_bus_arbiter_wr_granted_icache),
							 .l2_mem_access_addr(l2_mem_access_addr_icache),
							 .l2_mem_wr_data    (l2_mem_wr_data_icache),
							 .l2_mem_rd_data     (l2_mem_rd_data_icache),
							 .l2_mem_en              (l2_mem_en_icache),
 							 .l2_mem_wr_en (l2_mem_wr_en_icache)
							 );

   

   
   cache_set_associative_256sets_4blocks_4words i_dcache(
							 .clk(clk),
							 .rst_n(rst_n),
							 .address(data_mem_addr),
							 .wrdata_in(data_mem_wrdata),
							 .wr_cache(memwrite_ctrl),
							 .rd_cache(memtoreg_ctrl_to_MEMWB_pipe),
							 .rd_data_o(data_mem_rd_data_to_MEMWB_pipe),
							 .cache_miss(cache_miss_dcache),
							 .l2_bus_arbiter_rd_granted(l2_bus_arbiter_rd_granted_dcache),
							 .l2_bus_arbiter_wr_granted(l2_bus_arbiter_wr_granted_dcache),
							 .l2_mem_access_addr(l2_mem_access_addr_dcache),
							 .l2_mem_wr_data    (l2_mem_wr_data_dcache),
							 .l2_mem_rd_data     (l2_mem_rd_data_dcache),
							 .l2_mem_en              (l2_mem_en_dcache),
 							 .l2_mem_wr_en (l2_mem_wr_en_dcache)
							 );

   
   blink i_blnk(
		.clk(clk), // 50MHz input clock
		.cnt_en(led_load),
		.LED() // LED ouput
		);
   
   led_out_8b i_led_o(
		      .clk(clk),
		      .rst_n(rst_n),
		      .led_load_data(reg_led_o),
		      .led_load(regwrite_ctrl), //(instruction == 32'hAC030003)
		      .LED_o(LED_o)
		      );
   //**********************************//

endmodule // simple_MIPS_CPU
