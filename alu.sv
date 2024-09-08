module alu(
	   input logic [31:0]  op_1,
	   input logic [31:0]  op_2,
	   input logic [3:0]   alu_ctrl,
	   output logic [31:0] alu_result,
	   output logic        arith_ovrflw_exceptn_detected,
	   output logic        zero_alu
	   );


   //************ Declarations ***********//
   logic [32:0] 	       alu_int;
   logic [31:0] 	       op_1_int;
   logic [31:0] 	       op_2_int;
   //*************************************//


   //*********** ALU logic ************//
   assign zero_alu = !(|alu_result);
   assign op_1_int = {1'b0, op_1};
   assign op_2_int = {1'b0, op_2};
   assign arith_ovrflw_exceptn_detected = alu_int[32];
   assign alu_result = alu_int[31:0];
   //*********** ALU logic ************//   
   

   //************ ALU Operations ***************//
   always@(*) begin
      //***Deafults***//
      alu_result = 33'h0;
      //**************//
      
      case(alu_ctrl)
	4'b0000: alu_int = op_1_int & op_2_int;
	4'b0001: alu_int = op_1_int | op_2_int;
	4'b0010: alu_int = op_1_int + op_2_int;
	4'b0110: alu_int = op_1_int - op_2_int;
	4'b0111: alu_int = (op_1_int < op_2_int) ? 32'h1: 32'h0;
	4'b1100: alu_int = !(op_1_int | op_2_int);
	default: alu_int = 33'h0;
      endcase // case (alu_ctrl)
   end
   //************* ALU Operations **********//


endmodule // alu

