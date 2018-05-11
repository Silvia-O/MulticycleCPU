`timescale 1ns/1ns

module mem(
  input clk, //clock
  input DMWr, //memory write enable
  input [31:0] addr, //address bus
  input [3:0] be, //byte enables
  input [31:0] din, //32-bit input data
  output [31:0] dout //32-bit memory output
  );
  
  reg[31:0] mem[3200:0];  
  reg[31:0] instr_temp;
  integer fd, cnt, pointer;
      
  /*get instruction hex code*/
  initial
  begin
    fd = $fopen("./test.txt", "r"); 
    for(pointer = 12'hc00; pointer < 3200; pointer = pointer+1)
    begin
      cnt = $fscanf(fd, "%x", instr_temp);
      mem[pointer] = instr_temp;
      $display("IM read instruction %d: 0x%x", pointer, instr_temp);  //display the instructions 
    end
    $fclose(fd);
  end
  
  /*write back data*/
  always@(negedge clk)
  begin
    if(DMWr)
    begin
      case(be)
        4'b1111: mem[addr] = din;
        4'b0011: mem[addr][15:0] = din[15:0];
        4'b1100: mem[addr][31:16] = din[15:0];
        4'b0001: mem[addr][7:0] = din[7:0];
        4'b0010: mem[addr][15:8] = din[7:0];
        4'b0100: mem[addr][23:16] = din[7:0];
        4'b1000: mem[addr][31:24] = din[7:0];
      endcase
    end
  end 
   
  /*read data*/
  assign dout = mem[addr]; 
  
endmodule


