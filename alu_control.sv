module alu_control(
		   input logic[5:0] instruction_funct,
		   input logic[1:0] alu_op_ctrl,
		   output logic[3:0] alu_ctrl
		   );

   //******* ALU control logic ***********//
   always@(*) begin
      case(alu_op_ctrl)
	
	2'b00: alu_ctrl = 4'b0010;
	
	2'b01: alu_ctrl = 4'b0110;
	
	2'b10: begin
	   case(instruction_funct)
	     6'b100000: alu_ctrl = 4'b0010;
	     6'b100010: alu_ctrl = 4'b0110;
	     6'b100100: alu_ctrl = 4'b0000;
	     6'b100101: alu_ctrl = 4'b0001;
	     6'b101010: alu_ctrl = 4'b0111;
	     default: alu_ctrl = 4'b0010;
	     
	   endcase // case (instruction_funct)
	end // case: 2'b10

	default: alu_ctrl = 4'b0010;
      endcase // case (alu_op_ctrl)
   end
   //************************************//




endmodule // alu_control
