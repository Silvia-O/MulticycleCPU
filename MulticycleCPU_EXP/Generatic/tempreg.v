module tempreg(
  input clk,
  input rst,
  input control,  //register signal
  input [31:0] din,
  output [31:0] dout
  );
  
  reg[31:0] data;
  
  always@(posedge clk or posedge rst)
  begin
    if(rst)
      data <= 32'h0;
    else
      if(control)
        data <= din;
  end
  
  assign dout = data;

endmodule
  
  