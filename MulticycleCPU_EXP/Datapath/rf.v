module rf(
  input clk,
  input rst,
  input RegWrite,
  input [4:0] RA1, //1st reg address to read
  input [4:0] RA2, //2nd reg address to read
  input [31:0] WA,  //reg address to write
  input [31:0] WD, //reg data to write
  output [31:0] RD1, //1st reg data to read
  output [31:0] RD2  //2nd reg data to read
  );
  
  reg[31:0] rf[31:0];
  integer i;
    
  /*register write*/
  always@(posedge clk or posedge rst)
  begin
    if(rst)
      for(i = 0; i < 32; i = i+1)
        rf[i] = 32'h0;
    else
    begin
      if(RegWrite)
        rf[WA] <= (!WA)? 32'h0 : WD;  //only if the Regfile[WA] is not $zero
      for(i = 0; i < 32; i = i+1)
        $display("rf[%d] = 0x%x", i, rf[i]);  //display the current rf condition
    end
  end
  
   /*register read*/
  assign RD1 = rf[RA1];
  assign RD2 = rf[RA2];
  
endmodule
      
      