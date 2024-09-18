   module cache_rd_miss_handler(
				input logic 	     clk,
				input logic 	     rst_n,
				input logic 	     rd_miss,
				input logic [31:0]   miss_addr,
				output logic [31:0]  l2_mem_access_addr,
				input logic [31:0]   l2_mem_rd_data,
				output logic 	     rd_en,
				output logic [274:0] entry_upd_val,
				output logic 	     upd_entry
			     );

   //******** Wires *******//
   logic [2:0] 					  rd_tr_cntr;
   logic [31:0] 				  rd_data_buf[0:7];
   //******** Wires *******//
   
   //******** Params *******//
   
   //******** Params *******//


   //******* Logic *********//
   assign l2_mem_access_addr = {2'b00, miss_addr[31:5], rd_tr_cntr};
   //assign rd_en = (rd_tr_cntr < 3'b111) & rd_miss;
   assign entry_upd_val = {1'b1, miss_addr[31:14], rd_data_buf[7], rd_data_buf[6], rd_data_buf[5], rd_data_buf[4], rd_data_buf[3], rd_data_buf[2], rd_data_buf[1], rd_data_buf[0]};
   //assign upd_entry =  (rd_tr_cntr == 3'b111) & ; 
   //******* Logic *********// 
   

   always@(posedge clk) begin
      if(!rst_n) begin
	 upd_entry <= 1'b0;
      end
      else begin
	 upd_entry <= (rd_tr_cntr == 3'b111);
      end // else: !if(!rst_n)
   end // always@ (posedge clk)
  

   always@(posedge clk) begin
      if(!rst_n) begin
	 rd_tr_cntr <= 3'b000;
      end
      else begin
	 if(rd_en) begin
	    rd_tr_cntr <= rd_tr_cntr + 1; 
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
	    rd_data_buf[rd_tr_cntr-1] <= l2_mem_rd_data;
	 end
      end // else: !if(!rst_n)
   end // always@ (posedge clk)


   always@(posedge clk) begin
      if(!rst_n) begin
	 rd_en <= 1'b0;
      end
      else begin
	 if(rd_miss & !upd_entry) rd_en <= 1'b1;
	 else rd_en <= 1'b0;
      end
   end
endmodule // cache_rd_miss_handler

