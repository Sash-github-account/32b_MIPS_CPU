module cache_set_associative_256sets_4blocks_4words(
						    input logic 	clk,
						    input logic 	rst_n,
						    input logic [31:0] 	address,
						    input logic [31:0] 	wrdata_in,
						    input logic 	wr_cache,
						    input logic 	rd_cache,
						    output logic [31:0] rd_data_o,
						    output logic 	cache_miss,
						    input logic 	l2_bus_arbiter_rd_granted,
						    input logic 	l2_bus_arbiter_wr_granted,
						    output logic [31:0] l2_mem_access_addr,
						    output logic [31:0] l2_mem_wr_data,
						    input logic [31:0] 	l2_mem_rd_data,
						    output logic 	l2_mem_en,
						    output logic 	l2_mem_wr_en
						    );

   //========== Wires =============//
   logic 								valid_out;
   logic [18:0] 							tag_out;   
   logic 								valid_out_blk_0;
   logic 								valid_out_blk_1;
   logic 								valid_out_blk_2;
   logic 								valid_out_blk_3;
   logic [19:0] 							tag_out_0;
   logic [19:0] 							tag_out_1;
   logic [19:0] 							tag_out_2;
   logic [19:0] 							tag_out_3;
   logic [31:0] 							data_word_out[0:3];
   logic [127:0] 							data_out_blk_0;
   logic [127:0] 							data_out_blk_1;
   logic [127:0] 							data_out_blk_2;
   logic [127:0] 							data_out_blk_3;   
   logic [127:0] 							data_in;
   logic [127:0] 							wr_entry_final;
   logic [1:0] 								blk_sel;
   logic [7:0] 								cache_index_in;
   logic [19:0] 							tag_in;
   logic 								tag_in_out_comp;
   logic 								rd_cache_hit;
   logic 								wr_cache_hit;
   logic 								rd_cache_miss;
   logic 								wr_cache_miss;
   logic [127:0] 							entry_upd_val;
   logic 								upd_entry;
   logic 								upd_entry_blk_0;
   logic 								upd_entry_blk_1;
   logic 								upd_entry_blk_2;
   logic 								upd_entry_blk_3;
   logic 								rd_en;
//   logic 								cache_mem_wr_en;
   logic 								cache_mem_wr_en_blk_0;
      logic 								cache_mem_wr_en_blk_1;
      logic 								cache_mem_wr_en_blk_2;
      logic 								cache_mem_wr_en_blk_3;
   logic 								tag_com_and_cache_ln_vld;
   logic [20:0] 							tag_n_vld_wr_dt;
   logic [1:0] 								cur_recently_used_blk;
   logic [1:0] 								new_recently_used_blk;
   logic 								upd_lru;
   logic [3:0] 								hit_vector;
   logic [1:0] 								blk_chosen_for_upd;
   //========== Wires =============//



   //********* Logic - cache hit/miss, L2 cache ctrls *********//
   assign valid_out = valid_out_blk_0 | valid_out_blk_1 | valid_out_blk_2 | valid_out_blk_3;
   assign cache_index_in = address[11:4];
   assign tag_in = address[31:12];
   assign blk_sel  = address[3:2];
   assign tag_in_out_comp = (tag_in == tag_out_0) | (tag_in == tag_out_1) | (tag_in == tag_out_2) | (tag_in == tag_out_3);
   assign tag_com_and_cache_ln_vld = tag_in_out_comp & valid_out;
   assign rd_cache_hit = rd_cache & tag_com_and_cache_ln_vld;
   assign wr_cache_hit = wr_cache & tag_com_and_cache_ln_vld;
   assign cache_miss = rd_cache_miss | wr_cache_miss;
   assign wr_cache_miss = !wr_cache_hit & wr_cache;
   assign rd_cache_miss = !rd_cache_hit & rd_cache;
   assign l2_mem_en = rd_en | wr_cache;
   assign wr_entry_final = (upd_entry) ? entry_upd_val : data_in;
 //  assign cache_mem_wr_en = wr_cache_hit | upd_entry;
   assign upd_lru = rd_cache_hit | wr_cache_hit;
   assign hit_vector = {(valid_out_blk_0 & (tag_in == tag_out_0)), (valid_out_blk_1 & (tag_in == tag_out_1)), (valid_out_blk_2 & (tag_in == tag_out_2)), (valid_out_blk_3 & (tag_in == tag_out_3))};
   //********* Logic - cache hit/miss, L2 cache ctrls *********//


   //********* Logic data_out mux *********//
   always@(*) begin
      rd_data_o = 32'h0;
      case(blk_sel)
	2'h0: rd_data_o = data_word_out[0];
	2'h1: rd_data_o = data_word_out[1];
	2'h2: rd_data_o = data_word_out[2];
	2'h3: rd_data_o = data_word_out[3];
	default:  rd_data_o = 32'h0;
      endcase
   end
   //********* Logic data_out mux *********//    



   
   //********* Logic data_in *********//
   always@(posedge clk) begin
      data_in = 127'h0;
      case(blk_sel)
	3'h0: data_in = {data_word_out[3], data_word_out[2], data_word_out[1], wrdata_in};
	3'h1: data_in = {data_word_out[3], data_word_out[2], wrdata_in, data_word_out[0]};
	3'h2: data_in = {data_word_out[3], wrdata_in, data_word_out[1], data_word_out[0]};
	3'h3: data_in = {wrdata_in, data_word_out[2], data_word_out[1], data_word_out[0]};
	default:  data_in = 127'h0;
      endcase
   end
   //********* Logic data_in *********//  


   
   //********* data out mux *********//
   always@(*) begin
      data_word_out[0] = 32'h000000000;
      data_word_out[1] = 32'h000000000;
      data_word_out[2] = 32'h000000000;
      data_word_out[3] = 32'h000000000;
      new_recently_used_blk = 2'b00;
      
      case(hit_vector)
	4'b0000: begin
	   data_word_out[0] = 32'h000000000;
	   data_word_out[1] = 32'h000000000;
	   data_word_out[2] = 32'h000000000;
	   data_word_out[3] = 32'h000000000;
	   new_recently_used_blk = 2'b00;
	end

	4'b1000: begin
	   data_word_out[0] = data_out_blk_0[127:96];
	   data_word_out[1] = data_out_blk_0[95:64] ;
	   data_word_out[2] = data_out_blk_0[63:32] ;
	   data_word_out[3] = data_out_blk_0[31:0]  ;
	   new_recently_used_blk = 2'b00;
	end

	4'b0100: begin
	   data_word_out[0] = data_out_blk_1[127:96];
	   data_word_out[1] = data_out_blk_1[95:64] ;
	   data_word_out[2] = data_out_blk_1[63:32] ;
	   data_word_out[3] = data_out_blk_1[31:0]  ;
	   new_recently_used_blk = 2'b01;
	end

	4'b0010: begin
	   data_word_out[0] = data_out_blk_2[127:96];
	   data_word_out[1] = data_out_blk_2[95:64] ;
	   data_word_out[2] = data_out_blk_2[63:32] ;
	   data_word_out[3] = data_out_blk_2[31:0]  ;
	   new_recently_used_blk = 2'b10;
	end

	4'b0001: begin
	   data_word_out[0] = data_out_blk_3[127:96];
	   data_word_out[1] = data_out_blk_3[95:64] ;
	   data_word_out[2] = data_out_blk_3[63:32] ;
	   data_word_out[3] = data_out_blk_3[31:0]  ;
	   new_recently_used_blk = 2'b11;
	end

	default: begin
	   data_word_out[0] = 32'h000000000;
	   data_word_out[1] = 32'h000000000;
	   data_word_out[2] = 32'h000000000;
	   data_word_out[3] = 32'h000000000;
	   new_recently_used_blk = 2'b00;
	end

      endcase // case ({ valid_out_blk_0, valid_out_blk_1, valid_out_blk_2, valid_out_blk_3})
   end
   //********* data out mux *********//


   //********* update block based on chosen blk *********//
   always@(*) begin
      if(upd_entry) begin
	 upd_entry_blk_0 = 1'b0;
	 upd_entry_blk_1 = 1'b0;
	 upd_entry_blk_2 = 1'b0;
	 upd_entry_blk_3 = 1'b0;
	 
	 case(blk_chosen_for_upd)
	   2'b00: begin
 	      upd_entry_blk_0 = 1'b1;
	      upd_entry_blk_1 = 1'b0;
	      upd_entry_blk_2 = 1'b0;
	      upd_entry_blk_3 = 1'b0;
	   end

	   2'b01: begin
 	      upd_entry_blk_0 = 1'b0;
	      upd_entry_blk_1 = 1'b1;
	      upd_entry_blk_2 = 1'b0;
	      upd_entry_blk_3 = 1'b0;
	   end

	   2'b10: begin
 	      upd_entry_blk_0 = 1'b0;
	      upd_entry_blk_1 = 1'b0;
	      upd_entry_blk_2 = 1'b1;
	      upd_entry_blk_3 = 1'b0;
	   end

	   2'b11: begin
 	      upd_entry_blk_0 = 1'b0;
	      upd_entry_blk_1 = 1'b0;
	      upd_entry_blk_2 = 1'b0;
	      upd_entry_blk_3 = 1'b1;
	   end

	   default: begin
 	      upd_entry_blk_0 = 1'b0;
	      upd_entry_blk_1 = 1'b0;
	      upd_entry_blk_2 = 1'b0;
	      upd_entry_blk_3 = 1'b0;
	   end
	 endcase // case (cur_recently_used_blk)
      end // if (upd_entry)
      else begin
 	 upd_entry_blk_0 = 1'b0;
	 upd_entry_blk_1 = 1'b0;
	 upd_entry_blk_2 = 1'b0;
	 upd_entry_blk_3 = 1'b0;
      end // else: !if(upd_entry)
   end
   //********* update block based on chosen blk *********//


   
   //********* update block based on chosen blk or hit vector *********//
   always@(*) begin
      if(wr_cache_hit) begin
	 cache_mem_wr_en_blk_0 = 1'b0;
	 cache_mem_wr_en_blk_1 = 1'b0;
	 cache_mem_wr_en_blk_2 = 1'b0;
	 cache_mem_wr_en_blk_3 = 1'b0;
	 
	 case(hit_vector)
	   4'b1000: begin
 	      cache_mem_wr_en_blk_0 = 1'b1;
	      cache_mem_wr_en_blk_1 = 1'b0;
	      cache_mem_wr_en_blk_2 = 1'b0;
	      cache_mem_wr_en_blk_3 = 1'b0;
	   end

	   4'b0100: begin
 	      cache_mem_wr_en_blk_0 = 1'b0;
	      cache_mem_wr_en_blk_1 = 1'b1;
	      cache_mem_wr_en_blk_2 = 1'b0;
	      cache_mem_wr_en_blk_3 = 1'b0;
	   end

	   4'b0010: begin
 	      cache_mem_wr_en_blk_0 = 1'b0;
	      cache_mem_wr_en_blk_1 = 1'b0;
	      cache_mem_wr_en_blk_2 = 1'b1;
	      cache_mem_wr_en_blk_3 = 1'b0;
	   end

	   4'b0001: begin
 	      cache_mem_wr_en_blk_0 = 1'b0;
	      cache_mem_wr_en_blk_1 = 1'b0;
	      cache_mem_wr_en_blk_2 = 1'b0;
	      cache_mem_wr_en_blk_3 = 1'b1;
	   end

	   default: begin
 	      cache_mem_wr_en_blk_0 = 1'b0;
	      cache_mem_wr_en_blk_1 = 1'b0;
	      cache_mem_wr_en_blk_2 = 1'b0;
	      cache_mem_wr_en_blk_3 = 1'b0;
	   end
	 endcase // case (cur_recently_used_blk)
      end // if (cache_mem_wr_en)
      else if(upd_entry) begin
	 cache_mem_wr_en_blk_0 = 1'b0;
	 cache_mem_wr_en_blk_1 = 1'b0;
	 cache_mem_wr_en_blk_2 = 1'b0;
	 cache_mem_wr_en_blk_3 = 1'b0;
	 
	 case(blk_chosen_for_upd)
	   2'b00: begin
 	      cache_mem_wr_en_blk_0 = 1'b1;
	      cache_mem_wr_en_blk_1 = 1'b0;
	      cache_mem_wr_en_blk_2 = 1'b0;
	      cache_mem_wr_en_blk_3 = 1'b0;
	   end

	   2'b01: begin
 	      cache_mem_wr_en_blk_0 = 1'b0;
	      cache_mem_wr_en_blk_1 = 1'b1;
	      cache_mem_wr_en_blk_2 = 1'b0;
	      cache_mem_wr_en_blk_3 = 1'b0;
	   end

	   2'b10: begin
 	      cache_mem_wr_en_blk_0 = 1'b0;
	      cache_mem_wr_en_blk_1 = 1'b0;
	      cache_mem_wr_en_blk_2 = 1'b1;
	      cache_mem_wr_en_blk_3 = 1'b0;
	   end

	   2'b11: begin
 	      cache_mem_wr_en_blk_0 = 1'b0;
	      cache_mem_wr_en_blk_1 = 1'b0;
	      cache_mem_wr_en_blk_2 = 1'b0;
	      cache_mem_wr_en_blk_3 = 1'b1;
	   end

	   default: begin
 	      cache_mem_wr_en_blk_0 = 1'b0;
	      cache_mem_wr_en_blk_1 = 1'b0;
	      cache_mem_wr_en_blk_2 = 1'b0;
	      cache_mem_wr_en_blk_3 = 1'b0;
	   end
	 endcase // case (cur_recently_used_blk)
      end // if (upd_entry)
      else begin
 	 cache_mem_wr_en_blk_0 = 1'b0;
	 cache_mem_wr_en_blk_1 = 1'b0;
	 cache_mem_wr_en_blk_2 = 1'b0;
	 cache_mem_wr_en_blk_3 = 1'b0;
      end // else: !if(cache_mem_wr_en)
   end
   //********* update block based on chosen blk or hit vector *********//

   
   //********* cache data memory *********//    
   cache_32x4x256_sram i_data_cache_mem_blk_0(
					.addr(cache_index_in),
					.clk(clk),
					.data_in(wr_entry_final),
					.wr_en(cache_mem_wr_en_blk_0),
					.data_out(data_out_blk_0)
					);

   cache_32x4x256_sram i_data_cache_mem_blk_1(
					.addr(cache_index_in),
					.clk(clk),
					.data_in(wr_entry_final),
					.wr_en(cache_mem_wr_en_blk_1),
					.data_out(data_out_blk_1)
					);

   cache_32x4x256_sram i_data_cache_mem_blk_2(
					.addr(cache_index_in),
					.clk(clk),
					.data_in(wr_entry_final),
					.wr_en(cache_mem_wr_en_blk_2),
					.data_out(data_out_blk_2)
					);

   cache_32x4x256_sram i_data_cache_mem_blk_3(
					.addr(cache_index_in),
					.clk(clk),
					.data_in(wr_entry_final),
					.wr_en(cache_mem_wr_en_blk_3),
					.data_out(data_out_blk_3)
					); 
   //********* cache data memory *********//    

   
   
   //********* cache valid/tag memory *********//    
   sa_cache_vld_tag_sram i_cache_tag_vld_mem_blk_0(
					  .addra_vldtag_mem(cache_index_in),
					  .clk(clk),
					  .din(tag_n_vld_wr_dt),
					  .wr_en(upd_entry_blk_0),
					  .dout({valid_out_blk_0, tag_out_0})
					  );  
   
   sa_cache_vld_tag_sram i_cache_tag_vld_mem_blk_1(
					  .addra_vldtag_mem(cache_index_in),
					  .clk(clk),
					  .din(tag_n_vld_wr_dt),
					  .wr_en(upd_entry_blk_1),
					  .dout({valid_out_blk_1, tag_out_1})
					  );
   
   sa_cache_vld_tag_sram i_cache_tag_vld_mem_blk_2(
					  .addra_vldtag_mem(cache_index_in),
					  .clk(clk),
					  .din(tag_n_vld_wr_dt),
					  .wr_en(upd_entry_blk_2),
					  .dout({valid_out_blk_2, tag_out_2})
					  );
   
   sa_cache_vld_tag_sram i_cache_tag_vld_mem_blk_3(
					  .addra_vldtag_mem(cache_index_in),
					  .clk(clk),
					  .din(tag_n_vld_wr_dt),
					  .wr_en(upd_entry_blk_3),
					  .dout({valid_out_blk_3, tag_out_3})
					  );     
   //********* cache valid/tag memory *********//    



   //********* LRU memory *********//    
   lru_memory_2b_per_set i_lru_mem(
				   .addr(cache_index_in),
				   .clk(clk),
				   .din(new_recently_used_blk),
				   .wr_en(upd_lru),
				   .dout(cur_recently_used_blk)
				   );
   //********* LRU memory *********//    
   
   
   //********* L1 to L2 cache transfer handler *********//      
   cache_miss_handler_sa i_cache_miss_handler(
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
					      .l2_mem_wr_en(l2_mem_wr_en),
					      .cur_recently_used_blk(cur_recently_used_blk),
					      .blk_chosen_for_upd(blk_chosen_for_upd)
					      );
   //********* L1 to L2 cache transfer handler *********//
   
endmodule // cache_set_associative_256sets_4blocks_4words



