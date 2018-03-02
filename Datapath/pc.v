module pc(
  input clk,
  input control,
  input [31:0] din,
  output [31:0] dout
  );
  
  reg[31:0] currentPC;
  
  initial
    currentPC = 32'h3000; 
  
  always@(negedge clk)
  begin
    if(control) 
    begin
      currentPC = din;   //renew pc
      $display(" PC_current :0x%x ", currentPC); //display the current pc
    end
  end

  assign dout = currentPC;
endmodule