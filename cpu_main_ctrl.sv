module cpu_main_ctrl(
		     input logic [5:0] 	instruction_opcode,
		     input 		hazard_detected,
		     output logic [1:0] aluop_ctrl,
		     output logic 	regdst_ctrl,
		     output logic 	jump_ctrl,
		     output logic 	branch_ctrl,
		     output logic 	memread_ctrl,
		     output logic 	memwrite_ctrl,
		     output logic 	memtoreg_ctrl,
		     output logic 	alusrc_ctrl,
		     output logic 	regwrite_ctrl,
		     output logic 	decode_exception_detected
		     );

   //***** Wires ******//
   logic [5:0] 				instruction_opcode_hz_passed;
   //***** Wires ******//
   
   //*************** Main control logic ************//
   assign instruction_opcode_hz_passed = (hazard_detected)? 6'b111111 : instruction_opcode;
   
   always@(*) begin
      //*****Defaults*****//
      aluop_ctrl = 2'b00;
      regdst_ctrl = 1'b0;
      jump_ctrl = 1'b0;
      branch_ctrl = 1'b0;
      memread_ctrl = 1'b0;
      memwrite_ctrl = 1'b0;
      memtoreg_ctrl = 1'b0;
      alusrc_ctrl = 1'b0;
      regwrite_ctrl = 1'b0;
      decode_exception_detected = 1'b0;
      //******************//
      
      case(instruction_opcode_hz_passed)
	6'b000000: begin // R-type 
	   regdst_ctrl = 1'b1;
	   regwrite_ctrl = 1'b1;
	   aluop_ctrl = 2'b10;
	end
	
        6'b000010: begin // uncond jump
           jump_ctrl = 1'b1;
        end

	6'b100011: begin // load
	   alusrc_ctrl = 1'b1;
	   memtoreg_ctrl = 1'b1;
	   regwrite_ctrl = 1'b1;
	   memread_ctrl = 1'b1;
	end

	6'b101011: begin // store
	   alusrc_ctrl = 1'b1;
	   memwrite_ctrl = 1'b1;
	end

	6'b000100: begin // branch
	   branch_ctrl = 1'b1;
	   aluop_ctrl = 2'b01;
	end

	default: begin // no-op
	   aluop_ctrl = 2'b00;
	   regdst_ctrl = 1'b0;
	   jump_ctrl = 1'b0;
	   branch_ctrl = 1'b0;
	   memread_ctrl = 1'b0;
	   memwrite_ctrl = 1'b0;
	   memtoreg_ctrl = 1'b0;
	   alusrc_ctrl = 1'b0;
	   regwrite_ctrl = 1'b0;
	   if(hazard_detected & (instruction_opcode_hz_passed == 6'b111111)) decode_exception_detected = 1'b0;
	   else decode_exception_detected = 1'b1;
	end
      endcase // case (instruction_opcode)
   end // always@ (*)
   //***********************************************//

endmodule // cpu_main_ctrl


