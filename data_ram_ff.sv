module data_ram_ff(
	input logic[31:0] address,
	input logic clock,
	input logic[31:0] data,
	input logic wren,
	output logic[31:0] q
);


logic [31:0] data_int [31:0];

assign q = data_int[address];

always@(posedge clock) begin
	if(wren) data_int[address] <= data;
end

endmodule