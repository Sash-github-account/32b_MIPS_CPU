module l2_mem_bus_arbiter(
			  input logic 	      clk,
			  input logic 	      rst_n,
			  input logic [31:0]  l2_mem_access_addr_dcache,
			  input logic [31:0]  l2_mem_wr_data_dcache,
			  output logic [31:0] l2_mem_rd_data_dcache,
			  input logic 	      l2_mem_wr_en_dcache, 
			  input logic 	      l2_mem_en_dcache, 
			  input logic [31:0]  l2_mem_access_addr_icache,
			  input logic [31:0]  l2_mem_wr_data_icache,
			  output logic [31:0] l2_mem_rd_data_icache,
			  input logic 	      l2_mem_wr_en_icache, 
			  input logic 	      l2_mem_en_icache,
			  output logic [31:0] l2_mem_access_addr,
			  output logic [31:0] l2_mem_wr_data,
			  input logic [31:0]  l2_mem_rd_data,
			  output logic 	      l2_mem_wr_en, 
			  output logic 	      l2_mem_en,
			  output logic 	      rd_grant_icache_active,
			  output logic 	      rd_grant_dcache_active,
			  output logic 	      wr_grant_icache_active,
			  output logic 	      wr_grant_dcache_active,
			  input logic 	      upd_entry_icache,
 			  input logic 	      upd_entry_dcache,
			  input logic 	      dcache_wr_hit,
			  input logic 	      icache_wr_hit
			  );
   
   //********* Wires *********//
   logic 				      rd_req_icache_active;
   logic 				      rd_req_dcache_active;
   logic 				      wr_req_icache_active;
   logic 				      wr_req_dcache_active;
   logic 				      grant_sel_reg;
   logic 				      update_arbiter_grant;
   logic [3:0] 				      arb_state_sel;
   //********* Wires *********//  


   //********* Combo-Logic *********//   
   assign rd_req_icache_active = l2_mem_en_icache & !l2_mem_wr_en_icache;
   assign rd_req_dcache_active = (l2_mem_en_dcache & !l2_mem_wr_en_dcache) & !dcache_wr_hit;
   assign wr_req_icache_active = l2_mem_en_icache & l2_mem_wr_en_icache;
   assign wr_req_dcache_active = l2_mem_en_dcache & l2_mem_wr_en_dcache;   
   assign l2_mem_access_addr = (rd_grant_icache_active) ? l2_mem_access_addr_icache : (rd_grant_dcache_active) ? l2_mem_access_addr_dcache : 32'h00000000;
   //assign l2_mem_wr_data = (rd_grant_icache_active) ? l2_mem_wr_data_icache : l2_mem_wr_data_dcache;   
   assign l2_mem_en = (rd_grant_icache_active) ? l2_mem_en_icache : (rd_grant_dcache_active) ? l2_mem_en_dcache : 1'b1;
   assign l2_mem_wr_en = (wr_grant_icache_active) ? l2_mem_wr_en_icache : (wr_grant_dcache_active) ? l2_mem_wr_en_dcache : 1'b0;
   assign l2_mem_wr_data = (rd_req_icache_active) ? l2_mem_wr_data_icache : (rd_req_dcache_active) ? l2_mem_wr_data_dcache : 32'h00000000;
   assign l2_mem_rd_data_icache = (rd_req_icache_active) ? l2_mem_rd_data : 32'h00000000;
   assign l2_mem_rd_data_dcache = (rd_req_dcache_active) ? l2_mem_rd_data : 32'h00000000;
   assign arb_state_sel = {rd_req_icache_active, rd_req_dcache_active, wr_req_icache_active, wr_req_dcache_active};
   //********* Combo-Logic *********//   
   
   //********* Grant-Logic *********//       
   always@(posedge clk)begin
      if(!rst_n) begin
	 grant_sel_reg <= 1'b0;
      end
      else begin
	 if((upd_entry_icache | upd_entry_dcache)) grant_sel_reg <= !grant_sel_reg;	 
      end
   end
   //********* Grant-Logic *********//       



   
   //********* Arbiter-Logic *********//       
   always@(*) begin
      rd_grant_icache_active = 1'b0;
      rd_grant_dcache_active = 1'b0;
      wr_grant_icache_active = 1'b0;
      wr_grant_dcache_active = 1'b0;
      update_arbiter_grant = 1'b0;
      
      case(arb_state_sel)
	4'b0000:begin
	   rd_grant_icache_active = 1'b0;
	   rd_grant_dcache_active = 1'b0;
	   wr_grant_icache_active = 1'b0;
	   wr_grant_dcache_active = 1'b0;
	end

	4'b0100: begin
	   rd_grant_icache_active = 1'b0;
	   rd_grant_dcache_active = 1'b1;
	   wr_grant_icache_active = 1'b0;
	   wr_grant_dcache_active = 1'b0;
	end

	4'b1000: begin
	   rd_grant_icache_active = 1'b1;
	   rd_grant_dcache_active = 1'b0;
	   wr_grant_icache_active = 1'b0;
	   wr_grant_dcache_active = 1'b0;
	end

	
	4'b1100: begin
	   rd_grant_icache_active = grant_sel_reg;
	   rd_grant_dcache_active = !grant_sel_reg;
	   wr_grant_icache_active = 1'b0;
	   wr_grant_dcache_active = 1'b0;
	   update_arbiter_grant = 1'b1;
	end

	4'b0001: begin
	   rd_grant_icache_active = 1'b0;
	   rd_grant_dcache_active = 1'b0;
	   wr_grant_icache_active = 1'b0;
	   wr_grant_dcache_active = 1'b1;
	end
	
	4'b0010: begin
	   rd_grant_icache_active = 1'b0;
	   rd_grant_dcache_active = 1'b0;
	   wr_grant_icache_active = 1'b1;
	   wr_grant_dcache_active = 1'b0;
	end


	4'b0011: begin
	   rd_grant_icache_active = 1'b0;
	   rd_grant_dcache_active = 1'b0;
	   wr_grant_icache_active = grant_sel_reg;
	   wr_grant_dcache_active = !grant_sel_reg;
	   update_arbiter_grant = 1'b1;
	end

	4'b0110: begin
	   rd_grant_icache_active = 1'b0;
	   rd_grant_dcache_active = grant_sel_reg;
	   wr_grant_icache_active = !grant_sel_reg;
	   wr_grant_dcache_active = 1'b0;
	   update_arbiter_grant = 1'b1;
	end

	4'b1001: begin
	   rd_grant_icache_active = grant_sel_reg;
	   rd_grant_dcache_active = 1'b0;
	   wr_grant_icache_active = 1'b0;
	   wr_grant_dcache_active = !grant_sel_reg;
	   update_arbiter_grant = 1'b1;
	end
	
	default: begin
	   rd_grant_icache_active = 1'b0;
	   rd_grant_dcache_active = 1'b0;
	   wr_grant_icache_active = 1'b0;
	   wr_grant_dcache_active = 1'b0;
	   update_arbiter_grant = 1'b0;
	end
      endcase // case ({rd_req_icache_active, rd_req_dcache_active})
   end
//********* Arbiter-Logic *********//       

endmodule // l2_mem_bus_arbiter

  
