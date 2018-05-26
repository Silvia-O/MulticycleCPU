module mem(
  input clk, //clock
  input rst, //reset
  input DMWr, //memory write enable
  input [31:0] addr, //address bus
  input [3:0] be, //byte enables
  input [31:0] din, //32-bit input data
  output [31:0] dout //32-bit memory output
  );
  
  reg[31:0] mem[5096:0];  
  reg[31:0] instr_temp;
  integer i;
  
  
  always@(posedge clk or posedge rst)
  begin
    /*initialize mem*/
    if(rst)
    begin
      for(i = 0; i <= 5096; i = i+1)
        mem[i] = 32'h0;
      $readmemh("test.txt", mem, 12'hc00);
    end
    else
      /*write back data*/
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


