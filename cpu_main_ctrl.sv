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
		     output logic 	regwrite_ctrl
		     );

   //***** Wires ******//
   logic [5:0] 				instruction_opcode_hz_passed;
   //***** Wires ******//
   
   //*************** Main control logic ************//
   assign instruction_opcode_hz_passed = (hazard_detected)? 6'b111111 : instruction_opcode;
   
   always@(*) begin
      //*****Defaults*****//
      aluop_ctrl = 2'b00;
      regdst_ctrl = 0;
      jump_ctrl = 0;
      branch_ctrl = 0;
      memread_ctrl = 0;
      memwrite_ctrl = 0;
      memtoreg_ctrl = 0;
      alusrc_ctrl = 0;
      regwrite_ctrl = 0;
      //******************//
      
      case(instruction_opcode_hz_passed)
	6'b000000: begin // R-type 
	   regdst_ctrl = 1;
	   regwrite_ctrl = 1;
	   aluop_ctrl = 2'b10;
	end
	
        6'b000010: begin // uncond jump
           jump_ctrl = 1;
        end

	6'b100011: begin // load
	   alusrc_ctrl = 1;
	   memtoreg_ctrl = 1;
	   regwrite_ctrl = 1;
	   memread_ctrl =1;
	end

	6'b101011: begin // store
	   alusrc_ctrl = 1;
	   memwrite_ctrl = 1;
	end

	6'b000100: begin // branch
	   branch_ctrl = 1;
	   aluop_ctrl = 2'b01;
	end

	default: begin // no-op
	   aluop_ctrl = 2'b00;
	   regdst_ctrl = 0;
	   jump_ctrl = 0;
	   branch_ctrl = 0;
	   memread_ctrl = 0;
	   memwrite_ctrl = 0;
	   memtoreg_ctrl = 0;
	   alusrc_ctrl = 0;
	   regwrite_ctrl = 0;
	end
      endcase // case (instruction_opcode)
   end // always@ (*)
   //***********************************************//

endmodule // cpu_main_ctrl


