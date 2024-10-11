module cache_miss_handler(
			  input logic 		  clk,
			  input logic 		  rst_n,
			  input logic 		  rd_miss,
			  input logic 		  wr_miss,
			  input logic [31:0] 	  wr_miss_data,
			  input logic [31:0] 	  miss_addr,
			  output logic [31:0] 	  l2_mem_access_addr,
			  input logic [31:0] 	  l2_mem_rd_data,
			  output logic 		  rd_en,
			  input logic 		  l2_bus_arbiter_rd_granted,
			  input logic 		  l2_bus_arbiter_wr_granted,
			  output logic [274-19:0] upd_data_entry,
			  output logic 		  upd_entry,
			  output logic [18:0] 	  upd_entry_tag_vld,
			  output logic [31:0] 	  l2_mem_wr_data,
			  output logic 		  l2_mem_wr_en
			  );

   //******** Wires *******//
   logic [2:0] 					  rd_tr_cntr;
   logic [31:0] 				  rd_data_buf[0:7];
   logic 					  upd_entry_prev;
   //******** Wires *******//
   


   //******* Logic *********//
   assign l2_mem_access_addr = {2'b00, miss_addr[31:5], rd_tr_cntr};
   assign upd_data_entry = {rd_data_buf[7], rd_data_buf[6], rd_data_buf[5], rd_data_buf[4], rd_data_buf[3], rd_data_buf[2], rd_data_buf[1], rd_data_buf[0]};
   assign upd_entry_tag_vld = {1'b1, miss_addr[31:14]};   
   //******* Logic *********// 
   

   always@(posedge clk) begin
      if(!rst_n) begin
	 upd_entry <= 1'b0;
	 upd_entry_prev <= 1'b0;
      end
      else begin
	 upd_entry <= (rd_tr_cntr == 3'b111);
	 upd_entry_prev <= upd_entry; 
      end // else: !if(!rst_n)
   end // always@ (posedge clk)
   

   always@(posedge clk) begin
      if(!rst_n) begin
	 rd_tr_cntr <= 3'b000;
      end
      else begin
	 if(rd_en & l2_bus_arbiter_rd_granted) begin
	    rd_tr_cntr <= rd_tr_cntr + 3'h1; 
	 end
	 else rd_tr_cntr <= 3'h0;
      end // else: !if(!rst_n)
   end // always@ (posedge clk)
   
   
   always@(posedge clk) begin
      if(!rst_n) begin
	 for(int i=0; i < 8; i=i+1) begin
	    rd_data_buf[i] <= 32'h000000000;
	 end
      end
      else begin
	 if(rd_en) begin
	    if(wr_miss & (rd_tr_cntr-1 == miss_addr[4:2]))begin
	       rd_data_buf[rd_tr_cntr-1] <= wr_miss_data;
	    end
	    else begin
	       rd_data_buf[rd_tr_cntr-1] <= l2_mem_rd_data;
	    end
	 end
      end // else: !if(!rst_n)
   end // always@ (posedge clk)


   always@(posedge clk) begin
      if(!rst_n) begin
	 rd_en <= 1'b0;
	 l2_mem_wr_en <= 1'b0;
	 //l2_mem_access_addr <= 32'h00000000;
	 l2_mem_wr_data <= 32'h000000000;
      end
      else begin
	 if((rd_miss|wr_miss) & !upd_entry) rd_en <= 1'b1;
	 else begin 
	    rd_en <= 1'b0;
	    if(wr_miss & l2_bus_arbiter_wr_granted) begin
	       l2_mem_wr_en <= 1'b1;
	       l2_mem_wr_data <= wr_miss_data;
	       //l2_mem_access_addr <= {2'b00, miss_addr[31:2]};
	    end
	    else begin
	       l2_mem_wr_en <= 1'b0;
	       l2_mem_wr_data <= 32'h00000000;
	       //l2_mem_access_addr <= 32'h00000000;    
	    end
	 end
      end // else: !if(!rst_n)
   end // always@ (posedge clk)
   
endmodule // cache_rd_miss_handler

