module cache_V1b_T18b_8w_512E(
			      input logic 	  clk,
			      input logic 	  rst_n,
			      input logic [31:0]  address,
			      input logic [31:0]  wrdata_in,
			      input logic 	  wr_en,
			      input logic 	  rd_cache,
			      output logic [31:0] rd_data_o,
			      output logic 	  cache_miss,
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
   logic [274:0] 				  data_in;
   logic [274:0] 				  wr_entry_final;
   logic [2:0] 					  blk_sel;
   logic [8:0] 					  cache_index_in;
   logic [17:0] 				  tag_in;
   logic 					  tag_in_out_comp;
   logic 					  rd_cache_hit;
   logic 					  wr_cache_hit;
   logic 					  rd_cache_miss;
   logic 					  wr_cache_miss;
   logic [274:0] 				  entry_upd_val;
   logic 					  upd_entry;
   logic 					  rd_en;
   logic 					  cache_mem_wr_en;
   logic [1:0] 					  wr_ctrl_cur_state;
   logic [1:0] 					  wr_ctrl_nxt_state;
   logic 					  wr_stall;
   
   //********* Wires *********//


   
   //********* Logic - read *********//
   assign cache_index_in = address[13:5];
   assign tag_in = address[31:14];
   assign blk_sel  = address[4:2];
   assign tag_in_out_comp = (tag_in == tag_out);
   assign rd_cache_hit = rd_cache & tag_in_out_comp & valid_out;
   //assign wr_cache_hit = wr_en & tag_in_out_comp & valid_out;
   //assign data_word_in = wrdata_in;
   assign cache_miss = rd_cache_miss | wr_cache_miss | wr_stall;
   assign rd_cache_miss = !rd_cache_hit & rd_cache;
   //assign wr_cache_miss = !wr_cache_hit & wr_en;
   assign l2_mem_en = rd_en | wr_en;
   assign wr_entry_final = (upd_entry) ? entry_upd_val : data_in;
   assign cache_mem_wr_en = wr_cache_hit | upd_entry;
//   assign l2_mem_wr_en = 0;
   
   //********* Logic - read *********//

   //************* PARAMS *****************//
   localparam IDLE = 2'b00;
   localparam READ_CACHE_ENTRY = 2'b001;   
   localparam WRITE_HIT_WORD = 2'b010;
   localparam HANDLE_WRITE_MISS = 2'b011;
   //************* PARAMS *****************//


   
   //****** Write ctrl *********//
   always@(posedge clk) begin
      if(!rst_n) begin
	 wr_ctrl_cur_state <= IDLE;
      end
      else begin
	 wr_ctrl_cur_state <= wr_ctrl_nxt_state;
      end
   end

   always@(*) begin
      wr_ctrl_nxt_state = IDLE;
      wr_stall = 1'b0;
      wr_cache_hit = 1'b0;
      wr_cache_miss = 1'b0;
      

      case(wr_ctrl_cur_state)
	IDLE: begin
	   if(wr_en) begin
	      wr_ctrl_nxt_state = READ_CACHE_ENTRY;
	      wr_stall = 1'b1;
	   end
	   else begin
	      wr_ctrl_nxt_state = wr_ctrl_nxt_state;
	      wr_stall = 1'b0;
	   end
	end

	READ_CACHE_ENTRY: begin
	   if(tag_in_out_comp & valid_out) begin
	      wr_cache_hit = 1'b1;
	      wr_ctrl_nxt_state = WRITE_HIT_WORD;
	   end
	   else begin
	      wr_cache_miss = 1'b1;
	      wr_ctrl_nxt_state = HANDLE_WRITE_MISS;
	   end
	end

	WRITE_HIT_WORD: begin
	   wr_ctrl_nxt_state = IDLE;
	end
	
	HANDLE_WRITE_MISS: begin
	   wr_cache_miss = 1'b1;
	   if(upd_entry) wr_ctrl_nxt_state = IDLE;
	   else  wr_ctrl_nxt_state = HANDLE_WRITE_MISS;
	end

	default: begin
	   wr_ctrl_nxt_state = IDLE;
	   wr_stall = 1'b0;
	   wr_cache_hit = 1'b0;
	   wr_cache_miss = 1'b0;
	end
      endcase // case (wr_ctrl_cur_state)
   end
   //****** Write ctrl *********//


   
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
       data_in = 275'h0;
     	 case(blk_sel)
	   3'h0: data_in = {valid_out, tag_out, data_word_out[7], data_word_out[6], data_word_out[5], data_word_out[4], data_word_out[3], data_word_out[2], data_word_out[1], wrdata_in};
	   3'h1: data_in = {valid_out, tag_out, data_word_out[7], data_word_out[6], data_word_out[5], data_word_out[4], data_word_out[3], data_word_out[2], wrdata_in, data_word_out[0]};
	   3'h2: data_in = {valid_out, tag_out, data_word_out[7], data_word_out[6], data_word_out[5], data_word_out[4], data_word_out[3], wrdata_in, data_word_out[1], data_word_out[0]};
	   3'h3: data_in = {valid_out, tag_out, data_word_out[7], data_word_out[6], data_word_out[5], data_word_out[4], wrdata_in, data_word_out[2], data_word_out[1], data_word_out[0]};
	   3'h4: data_in = {valid_out, tag_out, data_word_out[7], data_word_out[6], data_word_out[5], wrdata_in, data_word_out[3], data_word_out[2], data_word_out[1], data_word_out[0]};
	   3'h5: data_in = {valid_out, tag_out, data_word_out[7], data_word_out[6], wrdata_in, data_word_out[4], data_word_out[3], data_word_out[2], data_word_out[1], data_word_out[0]};
	   3'h6: data_in = {valid_out, tag_out, data_word_out[7], wrdata_in, data_word_out[5], data_word_out[4], data_word_out[3], data_word_out[2], data_word_out[1], data_word_out[0]};
	   3'h7: data_in = {valid_out, tag_out, wrdata_in, data_word_out[6], data_word_out[5], data_word_out[4], data_word_out[3], data_word_out[2], data_word_out[1], data_word_out[0]};
	   default:  data_in = 274'h0;
	 endcase
   end
   //********* Logic data_in *********//  

   
   

   //********* cache memory *********//    
   V1b_T18b_8w_512E_cache i_data_cache_mem(
					   .addra(cache_index_in),
					   .clka(clk),
					   .dina(wr_entry_final),
					   .ena(1'b1),//memwrite_ctrl),
					   .wea(cache_mem_wr_en),
					   .douta({valid_out, tag_out, data_word_out[7], data_word_out[6], data_word_out[5], data_word_out[4], data_word_out[3], data_word_out[2], data_word_out[1], data_word_out[0]}));  
   //********* cache memory *********//    


   cache_miss_handler i_cache_rd_miss_handler(
						 .clk(clk),
						 .rst_n(rst_n),
						 .rd_miss(rd_cache_miss),
						 .wr_miss(wr_cache_miss),
					      .wr_miss_data(wrdata_in),
						 .miss_addr(address),
						 .l2_mem_access_addr(l2_mem_access_addr),
						 .l2_mem_rd_data(l2_mem_rd_data),
						 .rd_en(rd_en),
						 .entry_upd_val(entry_upd_val),
						 .upd_entry(upd_entry),
					      .l2_mem_wr_data(l2_mem_wr_data),
					      .l2_mem_wr_en(l2_mem_wr_en)
						 );

endmodule // cache_V1b_T18b_8w_512E
