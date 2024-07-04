module instr_rom_ff(
	input logic [31:0] address,
	input logic clock,
	output logic [31:0] q
);

logic [31:0] instruction[31:0];

initial begin
      instruction[0] <= {6'd35,5'd0,5'd1,16'd0}; // load mem0 to reg1
      instruction[1] <= {6'd35,5'd0,5'd2,16'd1}; // load mem1 to reg2
     instruction[2] <= {6'd35,5'd0,5'd4,16'd2}; // load mem2 to reg4
     instruction[3] <= {6'd0,5'd1,5'd2,5'd3,5'd0,6'b100000}; //add reg1, reg2 in reg3
     instruction[4] <= {6'd43,5'd0,5'd3,16'd3};
end

assign q = instruction[address];


endmodule