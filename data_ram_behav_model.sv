module data_ram(
  input logic clock,
  input logic[31:0] data,
  input logic[3:0] address,
  input logic wren,
  output logic[31:0] q
);
  
  logic[31:0] mem[0:15];
  
  always_ff@(posedge clock) begin
    mem[0] <= 32'd1;
     mem[1] <= 32'd5;
    mem[2] <= 32'd6;
    if(wren) begin
      mem[address] <= data;
    end
    
  end
  
  assign q = mem[address];
  
endmodule
