module mux32(
	     input logic[31:0] data_0,
	     input logic[31:0] data_1,
	     input logic sel,
	     output logic[31:0] data_o
	     );


   assign data_o = (sel) ? data_0 : data_1;

endmodule // mux32
