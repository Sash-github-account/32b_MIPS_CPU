	module blink (
	input logic clk, // 50MHz input clock
	input logic cnt_en,
	output logic LED // LED ouput
	);

// create a binary counter
logic[31:0] cnt; // 32-bit counter

initial begin
cnt<= 32'h00000000; // start at zero

end

always @(posedge clk) begin
if(cnt_en)cnt[0]<= 1; // count up

end

//assign LED to 25th bit of the counter to blink the LED at a few Hz
assign LED = cnt[0];

endmodule