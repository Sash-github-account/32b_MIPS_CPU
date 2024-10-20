module cache_V1b_T18b_8w_512E(
			      input logic 	  clk,
			      input logic 	  rst_n,
			      input logic [31:0]  address,
			      input logic [31:0]  wrdata_in,
			      input logic 	  wr_cache,
			      input logic 	  rd_cache,
			      output logic [31:0] rd_data_o,
			      output logic 	  cache_miss,
			      input logic 	  l2_bus_arbiter_rd_granted,
			      input logic 	  l2_bus_arbiter_wr_granted,
			      output logic [31:0] l2_mem_access_addr,
			      output logic [31:0] l2_mem_wr_data,
			      input logic [31:0]  l2_mem_rd_data,
			      output logic 	  l2_mem_en,
			      output logic 	  l2_mem_wr_en
			      );

   //********* Wires *********//
   logic 					  valid_out;
   logic [17:0] 				  tag_out;
   logic [31:0] 				  data_word_out[0:7];
   logic [274-19:0] 				  data_in;
   logic [274-19:0] 				  wr_entry_final;
   logic [2:0] 					  blk_sel;
   logic [8:0] 					  cache_index_in;
   logic [17:0] 				  tag_in;
   logic 					  tag_in_out_comp;
   logic 					  rd_cache_hit;
   logic 					  wr_cache_hit;
   logic 					  rd_cache_miss;
   logic 					  wr_cache_miss;
   logic [274-19:0] 				  entry_upd_val;
   logic 					  upd_entry;
   logic 					  rd_en;
   logic 					  cache_mem_wr_en;
   logic 					  tag_com_and_cache_ln_vld;
   logic [18:0] 				  tag_n_vld_wr_dt;
   
   //********* Wires *********//


   
   //********* Logic - cache hit/miss, L2 cache ctrls *********//
   assign cache_index_in = address[13:5];
   assign tag_in = address[31:14];
   assign blk_sel  = address[4:2];
   assign tag_in_out_comp = (tag_in == tag_out);
   assign tag_com_and_cache_ln_vld = tag_in_out_comp & valid_out;
   assign rd_cache_hit = rd_cache & tag_com_and_cache_ln_vld;
   assign wr_cache_hit = wr_cache & tag_com_and_cache_ln_vld;
   assign cache_miss = rd_cache_miss | wr_cache_miss;
   assign wr_cache_miss = !wr_cache_hit & wr_cache;
   assign rd_cache_miss = !rd_cache_hit & rd_cache;
   assign l2_mem_en = rd_en | wr_cache;
   assign wr_entry_final = (upd_entry) ? entry_upd_val : data_in;
   assign cache_mem_wr_en = wr_cache_hit | upd_entry;
   //********* Logic - cache hit/miss, L2 cache ctrls *********//

   

   
   //********* Logic data_out mux *********//
   always@(*) begin
      rd_data_o = 32'h0;
      case(blk_sel)
	3'h0: rd_data_o = data_word_out[0];
	3'h1: rd_data_o = data_word_out[1];
	3'h2: rd_data_o = data_word_out[2];
	3'h3: rd_data_o = data_word_out[3];
	3'h4: rd_data_o = data_word_out[4];
	3'h5: rd_data_o = data_word_out[5];
	3'h6: rd_data_o = data_word_out[6];
	3'h7: rd_data_o = data_word_out[7];
	default:  rd_data_o = 32'h0;
      endcase
   end
   //********* Logic data_out mux *********//    



   
   //********* Logic data_in *********//
   always@(posedge clk) begin
      data_in = 256'h0;
      case(blk_sel)
	3'h0: data_in = {data_word_out[7], data_word_out[6], data_word_out[5], data_word_out[4], data_word_out[3], data_word_out[2], data_word_out[1], wrdata_in};
	3'h1: data_in = {data_word_out[7], data_word_out[6], data_word_out[5], data_word_out[4], data_word_out[3], data_word_out[2], wrdata_in, data_word_out[0]};
	3'h2: data_in = {data_word_out[7], data_word_out[6], data_word_out[5], data_word_out[4], data_word_out[3], wrdata_in, data_word_out[1], data_word_out[0]};
	3'h3: data_in = {data_word_out[7], data_word_out[6], data_word_out[5], data_word_out[4], wrdata_in, data_word_out[2], data_word_out[1], data_word_out[0]};
	3'h4: data_in = {data_word_out[7], data_word_out[6], data_word_out[5], wrdata_in, data_word_out[3], data_word_out[2], data_word_out[1], data_word_out[0]};
	3'h5: data_in = {data_word_out[7], data_word_out[6], wrdata_in, data_word_out[4], data_word_out[3], data_word_out[2], data_word_out[1], data_word_out[0]};
	3'h6: data_in = {data_word_out[7], wrdata_in, data_word_out[5], data_word_out[4], data_word_out[3], data_word_out[2], data_word_out[1], data_word_out[0]};
	3'h7: data_in = {wrdata_in, data_word_out[6], data_word_out[5], data_word_out[4], data_word_out[3], data_word_out[2], data_word_out[1], data_word_out[0]};
	default:  data_in = 256'h0;
      endcase
   end
   //********* Logic data_in *********//  

   
   

   //********* cache data memory *********//    
   cache_32x8x512_sram i_data_cache_mem(
					.addr_dcache(cache_index_in),
					.clk(clk),
					.din(wr_entry_final),
				//	.mem_en(1'b1),//memwrite_ctrl),
					.wr_en_dcache(cache_mem_wr_en),
					.dout({data_word_out[7], data_word_out[6], data_word_out[5], data_word_out[4], data_word_out[3], data_word_out[2], data_word_out[1], data_word_out[0]})
					);  
   //********* cache data memory *********//    

   
   
   //********* cache valid/tag memory *********//    
     cache_vld_tag_sram i_cache_tag_vld_mem(
					 .addra_vldtag_mem(cache_index_in),
					 .clk(clk),
					 .din(tag_n_vld_wr_dt),
				//	 .mem_en(1'b1),//memwrite_ctrl),
					 .wr_en(upd_entry),
					 .dout({valid_out, tag_out})
					 );  
   //********* cache valid/tag memory *********//    


   
   //********* L1 to L2 cache transfer handler *********//      
       cache_miss_handler i_cache_miss_handler(
					       .clk(clk),
					       .rst_n(rst_n),
					       .rd_miss(rd_cache_miss),
					       .wr_miss(wr_cache_miss),
					       .wr_miss_data(wrdata_in),
					       .miss_addr(address),
					       .l2_mem_access_addr(l2_mem_access_addr),
					       .l2_mem_rd_data(l2_mem_rd_data),
					       .rd_en(rd_en),
					       .l2_bus_arbiter_rd_granted(l2_bus_arbiter_rd_granted),
					       .l2_bus_arbiter_wr_granted(l2_bus_arbiter_wr_granted),
					       .upd_data_entry(entry_upd_val),
					       .upd_entry(upd_entry),
					       .upd_entry_tag_vld(tag_n_vld_wr_dt),
					       .l2_mem_wr_data(l2_mem_wr_data),
					       .l2_mem_wr_en(l2_mem_wr_en)
					       );
   //********* L1 to L2 cache transfer handler *********//
     
endmodule // cache_V1b_T18b_8w_512E
