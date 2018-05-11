`include "./mips.v"

module mips_tb();
  `timescale 1ns / 1ns
  reg clk;
  reg rst;

  initial
  begin
    clk = 1;
    rst = 1;
    #12 rst = 0;
  end
  
  always #20 clk = ~clk;
  
  mips mips(clk, rst);
endmodule

