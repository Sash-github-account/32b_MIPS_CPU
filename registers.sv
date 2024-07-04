module registers(
		 input logic clk,
		 input logic rst_n,
		 input logic[4:0] read_register_1,
		 input logic[4:0] read_register_2,
		 input logic[4:0] write_register,
		 input logic[31:0] write_data,
		 input  logic regwrite_ctrl,
		 output logic[31:0] read_data_1,
		 output logic[31:0] read_data_2,
		 output logic[7:0] reg_led_o
		 );


   //**********Declarations***********//
   logic [31:0] 		    register_file[31:0];
   //*********************************//


   //************combinations logic**************//
   assign read_data_1 = register_file[read_register_1];
   assign read_data_2 = register_file[read_register_2];
	assign reg_led_o = write_data[7:0];
   //********************************************//

   
   //********* Register file seq logic*************//
   always@(posedge clk) begin
      if(!rst_n) begin 
	 for(int i = 0; i < 32; i = i+1) begin
	    register_file[i] <= 32'd0;   
	 end
      end
      else begin
	 if(regwrite_ctrl) register_file[write_register] <= write_data;
      end
   end

   //**********************************************//

endmodule // registers
