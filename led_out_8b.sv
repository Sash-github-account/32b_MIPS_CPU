module led_out_8b(
	input logic clk,
	input logic rst_n,
	input logic [7:0] led_load_data,
	input logic led_load,
	output logic[7:0] LED_o
	);
	
	//----- Declarations-------//
	//-------------------------//
	
	//-----LED OUT logic--------//
	always@(posedge clk) begin
		if(!rst_n) begin
			LED_o <= 8'h00;
		end
		else begin
			if(led_load) LED_o <= led_load_data;
		end
	end
	
endmodule
	