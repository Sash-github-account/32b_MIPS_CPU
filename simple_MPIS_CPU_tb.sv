module tb;
   logic 	   clk;
   logic 	   reset_n;
   logic [31:0]    instruction[0:100];
   logic [31:0]    data_mem_rd_data;
   logic [31:0]    inst_mem_rd_addr;
   logic [31:0]    data_mem_addr;
   logic [31:0]    data_mem_wrdata;
   logic 	   memwrite_ctrl;
   logic 	   memread_ctrl;
   logic [31:0]    data_mem[0:4];
   logic [31:0]    instr_mem_addr;
   logic [31:0]    data_in;
   
   assign instr_mem_addr  = (inst_mem_rd_addr>>2);
   assign data_in = data_mem[data_mem_addr];


   initial begin
      $dumpfile("dump1.vcd"); $dumpvars;
      clk <= 0;
      reset_n = 0;
      for (int i=0; i<100; i=i+1) begin
        instruction[i] <= 32'h0;
      end
      instruction[0] <= {6'd35,5'd0,5'd1,16'd0}; // load mem0 to reg1
      instruction[1] <= {6'd35,5'd0,5'd2,16'd1}; // load mem1 to reg2
      //instruction[0] <= {6'd35,5'd0,5'd3,16'd2}; // load mem2 to reg4
      instruction[3] <= {6'd0,5'd1,5'd2,5'd3,5'd0,6'b100000}; //add reg1, reg2 in reg3
      instruction[4] <= {6'd0,5'd1,5'd3,5'd3,5'd0,6'b100000}; //add reg1, reg2 in reg3
      //instruction[5] <= {6'd43,5'd0,5'd3,16'd3};
      //instruction[1] <= {6'd4,5'd6,5'd7,-16'd2}; // br if reg4 == reg3
      instruction[6] <= {6'b000010,26'h0};// jmp back to start
      //instruction[6] <= {6'd0,5'd2,5'd3,5'd3,5'd0,6'b100000};
      instruction[2] <= {6'd43,5'd0,5'd3,16'd9}; // Store reg3 to mem0 (reg0+offset=0+9)
      //instruction[5] <= 32'h00000000;
      instruction[7] <= 32'h0;
      //instruction[6] <= 32'h0;
 
      instruction[8] <= 32'h0;
            instruction[9] <= 32'h0;
      instruction[10] <= 32'h0;
      instruction[11] <= 32'h0;
      instruction[12] <= 32'h0;
      instruction[13] <= 32'h0;
      instruction[14] <= 32'h0;
      instruction[15] <= 32'h0;
      instruction[16] <= 32'h0;

    //generated
instruction[ 1  ] <= 32'b10001100001000000000000000001111 ;
instruction[ 2  ] <= 32'b10101100010000010000000000000100 ;
instruction[ 3  ] <= 32'b10101100010000010000000000001000 ;
instruction[ 4  ] <= 32'b10101100010000010000000000001100 ;
instruction[ 5  ] <= 32'b10101100010000010000000000010000 ;
instruction[ 6  ] <= 32'b10101100010000010000000000010100 ;
instruction[ 7  ] <= 32'b10001100010000010000000000000100 ;
instruction[ 8  ] <= 32'b10001100011000010000000000001000 ;
instruction[ 9  ] <= 32'b00000000100000100001100000100000 ;
instruction[10  ] <= 32'b10101100011000010000000000011000 ;
instruction[11  ] <= 32'b10101100010000010000000000010000 ;
instruction[12  ] <= 32'b10001100010000010000000000001100 ;
instruction[13  ] <= 32'b10001100011000010000000000001000 ;
instruction[14  ] <= 32'b00000000100000100001100000100010 ;
instruction[15  ] <= 32'b10101100011000010000000000011100 ;
instruction[16  ] <= 32'b10101100010000010000000000010100 ;
instruction[17  ] <= 32'b10001100010000010000000000100110 ;
instruction[18  ] <= 32'b10001100011000010000000000010000 ;
instruction[19  ] <= 32'b10001100100000010000000000010100 ;
instruction[20  ] <= 32'b10001100101000010000000000100110 ;
instruction[21  ] <= 32'b10001100110000010000000000100110 ;
instruction[22  ] <= 32'b00000000010000100001100000100000 ;
instruction[23  ] <= 32'b00000000100001000010100000100010 ;
instruction[24  ] <= 32'b00000000111001100010000000101010 ;
instruction[25  ] <= 32'b00010000111001011111111111110100 ;
instruction[26  ] <= 32'b10101100010000010000000000100000 ;
instruction[27  ] <= 32'b10101100010000010000000000010000 ;
instruction[28  ] <= 32'b10001100010000010000000000100110 ;
instruction[29  ] <= 32'b10001100011000010000000000010000 ;
instruction[30  ] <= 32'b10001100100000010000000000000100 ;
instruction[31  ] <= 32'b10001100101000010000000000100110 ;
instruction[32  ] <= 32'b10001100110000010000000000100110 ;
instruction[33  ] <= 32'b00000000111000110010000000101010 ;
instruction[34  ] <= 32'b00010000111001010000000000010000 ;
instruction[35  ] <= 32'b00000000011000110010000000100010 ;
instruction[36  ] <= 32'b00000000010000100010100000100000 ;
instruction[37  ] <= 32'b00001011111111111111111111110000 ;
instruction[38  ] <= 32'b10101100010000010000000000100100 ;
instruction[39  ] <= 32'b10101100010000010000000000010100 ;
instruction[40  ] <= 32'b10001100010000010000000000100110 ;
instruction[41  ] <= 32'b10001100011000010000000000010000 ;
instruction[42  ] <= 32'b10001100100000010000000000001100 ;
instruction[43  ] <= 32'b10001100101000010000000000100110 ;
instruction[44  ] <= 32'b10001100110000010000000000100110 ;
instruction[45  ] <= 32'b00000000111000110010000000101010 ;
instruction[46  ] <= 32'b00010000111001010000000000010000 ;
instruction[47  ] <= 32'b00000000011000110010000000100010 ;
instruction[48  ] <= 32'b00000000010000100010100000100000 ;
instruction[49  ] <= 32'b00001011111111111111111111110000 ;
instruction[50  ] <= 32'b10101100011000010000000000101000 ;
instruction[51  ] <= 32'b10101100010000010000000000010000 ;
instruction[52  ] <= 32'b10001100010000010000000000010100 ;
instruction[53  ] <= 32'b10001100011000010000000000000100 ;
instruction[54  ] <= 32'b00000000100000100001100000100100 ;
instruction[55  ] <= 32'b10101100011000010000000000101100 ;
instruction[56  ] <= 32'b10101100010000010000000000010000 ;
instruction[57  ] <= 32'b10001100010000010000000000010000 ;
instruction[58  ] <= 32'b10001100011000010000000000001000 ;
instruction[59  ] <= 32'b00000000100000100001100000100101 ;
instruction[60  ] <= 32'b10101100011000010000000000110000 ;
instruction[61  ] <= 32'b10101100010000010000000000010100 ;
instruction[62  ] <= 32'b10101100010000010000000000001000 ;
instruction[63  ] <= 32'b10101100010000010000000000111000 ;
instruction[64  ] <= 32'b10101100010000010000000000010100 ;
instruction[65  ] <= 32'b10101100010000010000000000111100 ;



      data_mem[0] <= 32'd1;
      data_mem[1] <= 32'd5;
      data_mem[2] <= 32'd5;
      
      
      #250 reset_n <= 1;
      
      #2048 $finish;
   end

   always #1 clk <= !clk;

  // simple_MIPS_CPU i_simple_MIPS_CPU(
  CPU_MIPS_32b_5stage i_simple_MIPS_CPU(
				     .clk(clk),
				     .rst_n(reset_n)
				     //.instruction_i(instruction[inst_mem_rd_addr]),
				     //.inst_mem_rd_addr_to_instmem(inst_mem_rd_addr)
				     ); 
endmodule
