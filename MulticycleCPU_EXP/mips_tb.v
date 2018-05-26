`include "./mips.v"

module mips_tb();
  `timescale 1ns / 1ps
  reg clk;
  reg rst;

  initial
  begin
    clk = 0;
    rst = 0;
    #1 rst = 1;
    #2 rst = 0;
  end
  
  always #5 clk = ~clk;
  
  mips mips(clk, rst);
  
endmodule

