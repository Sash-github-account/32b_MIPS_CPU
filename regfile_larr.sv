module regfile_larr(
		  input logic 	      clk,
		  input logic 	      rst_n,
		  input logic [4:0]   read_register_1,
		  input logic [4:0]   read_register_2,
		  input logic [4:0]   write_register,
		  input logic [31:0]  write_data,
		  input logic 	      regwrite_ctrl,
		  output logic [31:0] read_data_1,
		  output logic [31:0] read_data_2,
		  output logic [7:0]  reg_led_o
		  );


   //**********Declarations***********//
   logic [31:0] 		      register_0;
   logic [31:0] 		      register_1;
   logic [31:0] 		      register_2;
   logic [31:0] 		      register_3;
   logic [31:0] 		      register_4;
   logic [31:0] 		      register_5;
   logic [31:0] 		      register_6;
   logic [31:0] 		      register_7;
   logic [31:0] 		      register_8;
   logic [31:0] 		      register_9;
   logic [31:0] 		      register_10;
   logic [31:0] 		      register_11;
   logic [31:0] 		      register_12;
   logic [31:0] 		      register_13;
   logic [31:0] 		      register_14;
   logic [31:0] 		      register_15;
   logic [31:0] 		      register_16;
   logic [31:0] 		      register_17;
   logic [31:0] 		      register_18;
   logic [31:0] 		      register_19;
   logic [31:0] 		      register_20;
   logic [31:0] 		      register_21;
   logic [31:0] 		      register_22;
   logic [31:0] 		      register_23;
   logic [31:0] 		      register_24;
   logic [31:0] 		      register_25;
   logic [31:0] 		      register_26;
   logic [31:0] 		      register_27;
   logic [31:0] 		      register_28;
   logic [31:0] 		      register_29;
   logic [31:0] 		      register_30;
   logic [31:0] 		      register_31;
   //*********************************//


   //************combinations logic**************//
   always_comb begin
      read_data_1 = 32'h0;
      
      case(read_register_1)
	0: begin read_data_1 = register_0  ; end
	1: begin read_data_1 = register_1   ; end
	2: begin read_data_1 = register_2   ; end
	3: begin read_data_1 = register_3   ; end
	4: begin read_data_1 = register_4   ; end
	5: begin read_data_1 = register_5   ; end
	6: begin read_data_1 = register_6   ; end
	7: begin read_data_1 = register_7   ; end
	8: begin read_data_1 = register_8   ; end
	9: begin read_data_1 = register_9   ; end
	10: begin read_data_1 = register_10   ; end
	11: begin read_data_1 = register_11   ; end
	12: begin read_data_1 = register_12   ; end
	13: begin read_data_1 = register_13   ; end
	14: begin read_data_1 = register_14   ; end
	15: begin read_data_1 = register_15   ; end
	16: begin read_data_1 = register_16   ; end
	17: begin read_data_1 = register_17   ; end
	18: begin read_data_1 = register_18   ; end
	19: begin read_data_1 = register_19   ; end
	20: begin read_data_1 = register_20   ; end
	21: begin read_data_1 = register_21   ; end
	22: begin read_data_1 = register_22   ; end
	23: begin read_data_1 = register_23   ; end
	24: begin read_data_1 = register_24   ; end
	25: begin read_data_1 = register_25   ; end
	26: begin read_data_1 = register_26   ; end
	27: begin read_data_1 = register_27   ; end
	28: begin read_data_1 = register_28   ; end
	29: begin read_data_1 = register_29   ; end
	30: begin read_data_1 = register_30   ; end
	31: begin read_data_1 = register_31   ; end	
      endcase
      
   end // always_comb

   always_comb begin
      read_data_2 = 32'h0;
      
      case(read_register_2)
	0: begin read_data_2 = register_0  ; end
	1: begin read_data_2 = register_1   ; end
	2: begin read_data_2 = register_2   ; end
	3: begin read_data_2 = register_3   ; end
	4: begin read_data_2 = register_4   ; end
	5: begin read_data_2 = register_5   ; end
	6: begin read_data_2 = register_6   ; end
	7: begin read_data_2 = register_7   ; end
	8: begin read_data_2 = register_8   ; end
	9: begin read_data_2 = register_9   ; end
	10: begin read_data_2 = register_10   ; end
	11: begin read_data_2 = register_11   ; end
	12: begin read_data_2 = register_12   ; end
	13: begin read_data_2 = register_13   ; end
	14: begin read_data_2 = register_14   ; end
	15: begin read_data_2 = register_15   ; end
	16: begin read_data_2 = register_16   ; end
	17: begin read_data_2 = register_17   ; end
	18: begin read_data_2 = register_18   ; end
	19: begin read_data_2 = register_19   ; end
	20: begin read_data_2 = register_20   ; end
	21: begin read_data_2 = register_21   ; end
	22: begin read_data_2 = register_22   ; end
	23: begin read_data_2 = register_23   ; end
	24: begin read_data_2 = register_24   ; end
	25: begin read_data_2 = register_25   ; end
	26: begin read_data_2 = register_26   ; end
	27: begin read_data_2 = register_27   ; end
	28: begin read_data_2 = register_28   ; end
	29: begin read_data_2 = register_29   ; end
	30: begin read_data_2 = register_30   ; end
	31: begin read_data_2 = register_31   ; end
      endcase // case (read_register_1)
   end

   
   assign reg_led_o = register_0[31:24];
   //********************************************//

   
   //********* Register file seq logic*************//
   always@(clk or rst_n or write_data) begin
      if(!rst_n) begin 
	 register_0 <= 32'd0; 
	 register_1 <= 32'h00; 
	 register_2 <= 32'h00; 
	 register_3 <= 32'h00; 
	 register_4 <= 32'h00; 
	 register_5 <= 32'h00; 
	 register_6 <= 32'h00; 
	 register_7 <= 32'h0; 
	 register_8 <= 32'h0; 
	 register_9 <= 32'h0; 
	 register_10 <= 32'h0;
	 register_11 <= 32'h0;
	 register_12 <= 32'h0;
	 register_13 <= 32'h0;
	 register_14 <= 32'h0;
	 register_15 <= 32'h0;
	 register_16 <= 32'h0;
	 register_17 <= 32'h0;
	 register_18 <= 32'h0;
	 register_19 <= 32'h0;
	 register_20 <= 32'h0;
	 register_21 <= 32'h0;
	 register_22 <= 32'h0;
	 register_23 <= 32'h0;
	 register_24 <= 32'h0;
	 register_25 <= 32'h0;
	 register_26 <= 32'h0;
	 register_27 <= 32'h0;
	 register_28 <= 32'h0;
	 register_29 <= 32'h0;
	 register_30 <= 32'h0;
	 register_31 <= 32'h0;	 
      end
      else begin
	 if(regwrite_ctrl & clk) begin
	    case(write_register)
	      0: begin register_0  <= write_data ; end
	      1: begin register_1  <= write_data  ; end
	      2: begin register_2  <= write_data  ; end
	      3: begin register_3  <= write_data  ; end
	      4: begin register_4  <= write_data  ; end
	      5: begin register_5  <= write_data  ; end
	      6: begin register_6  <= write_data  ; end
	      7: begin register_7  <= write_data  ; end
	      8: begin register_8  <= write_data  ; end
	      9: begin register_9  <= write_data  ; end
	      10: begin register_10  <= write_data   ; end
	      11: begin register_11  <= write_data   ; end
	      12: begin register_12  <= write_data   ; end
	      13: begin register_13  <= write_data   ; end
	      14: begin register_14  <= write_data   ; end
	      15: begin register_15  <= write_data   ; end
	      16: begin register_16  <= write_data   ; end
	      17: begin register_17  <= write_data   ; end
	      18: begin register_18  <= write_data   ; end
	      19: begin register_19  <= write_data   ; end
	      20: begin register_20  <= write_data   ; end
	      21: begin register_21  <= write_data   ; end
	      22: begin register_22  <= write_data   ; end
	      23: begin register_23  <= write_data   ; end
	      24: begin register_24  <= write_data   ; end
	      25: begin register_25  <= write_data   ; end
	      26: begin register_26  <= write_data   ; end
	      27: begin register_27  <= write_data   ; end
	      28: begin register_28  <= write_data   ; end
	      29: begin register_29  <= write_data   ; end
	      30: begin register_30  <= write_data   ; end
	      31: begin register_31  <= write_data   ; end
	    endcase // case (write_register)
	 end
      end
   end

   //**********************************************//

endmodule // registers
