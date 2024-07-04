module alu(
	   input logic [31:0]  op_1,
	   input logic [31:0]  op_2,
	   input logic [3:0]   alu_ctrl,
	   output logic [31:0] alu_result,
	   output logic        zero_alu
	   );


   //************ Declarations ***********//
   
   //*************************************//


   //*********** ALU logic ************//
   assign zero_alu = !(|alu_result);
   
   
   always@(*) begin
      //***Deafults***//
      alu_result = 32'h0;
      //**************//
      
      case(alu_ctrl)
	4'b0000: alu_result = op_1 & op_2;
	4'b0001: alu_result = op_1 | op_2;
	4'b0010: alu_result = op_1 + op_2;
	4'b0110: alu_result = op_1 - op_2;
	4'b0111: alu_result = (op_1 < op_2) ? 32'h1: 32'h0;
	4'b1100: alu_result = !(op_1 | op_2);
	default: alu_result = 32'h0;
      endcase // case (alu_ctrl)
   end
   //**********************************//


endmodule // alu

