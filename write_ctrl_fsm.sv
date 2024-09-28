module write_ctrl_fsm(
		      input logic  clk,
		      input logic  rst_n,
		      input logic  wr_en,
		      output logic wr_stall,
		      output logic wr_cache_hit, 
		      output logic wr_cache_miss
		      );

   //********* Wires *********//
   logic [1:0] 					  wr_ctrl_cur_state;
   logic [1:0] 					  wr_ctrl_nxt_state;
     //********* Wires *********//

   
   //************* PARAMS *****************//
   localparam IDLE = 2'b00;
   localparam READ_CACHE_ENTRY = 2'b001;   
   localparam WRITE_HIT_WORD = 2'b010;
   localparam HANDLE_WRITE_MISS = 2'b011;
   //************* PARAMS *****************//


   
   //****** Write ctrl FSM *********//
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
   //****** Write ctrl FSM *********//
   
endmodule // write_ctrl_fsm
