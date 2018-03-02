module tempreg(
  input clk,
  input control,  //register signal
  input [31:0] din,
  output reg[31:0] dout
  );
  
  always@(negedge clk)
  begin
    if(control)
      dout <= din;
  end

endmodule
  
  