`include "./instr_def.v"

module beEXT(
  input [1:0] control,  //aluout[1:0]
  input [5:0] OP,       //instr[31:26]
  output [3:0] be   //byte enables
  );
  
  reg[3:0] BE;
  
  always@(*)
  begin
    case(OP)
      `OP_SW: BE <= 4'b1111;
      `OP_SH:
      begin
        if(control[1])
          BE <= 4'b1100;
        else
          BE <= 4'b0011;
      end
      `OP_SB:
      begin
        case(control)
          2'b00: BE <= 4'b0001;
          2'b01: BE <= 4'b0010;
          2'b10: BE <= 4'b0100;
          2'b11: BE <= 4'b1000;
        endcase
      end
    endcase
  end
  
  assign be = BE;
  
endmodule

