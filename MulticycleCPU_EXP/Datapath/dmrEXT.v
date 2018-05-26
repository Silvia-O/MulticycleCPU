`include "./instr_def.v"

module dmrEXT(
  input [1:0] control,  //aluout[1:0]
  input [5:0] OP,       //instr[31:26]
  input [31:0] din,
  output [31:0] dout
  );
  
  reg[31:0] data;
  
  always@(*)
  begin
    case(OP)
      `OP_LB: 
      begin
        case(control)
          2'b00: data <= {{24{din[7]}},din[7:0]};
          2'b01: data <= {{24{din[15]}},din[15:8]};
          2'b10: data <= {{24{din[23]}},din[23:16]};
          2'b11: data <= {{24{din[31]}},din[31:24]};
        endcase
      end
      `OP_LBU:
      begin
        case(control)
          2'b00: data <= {24'b0,din[7:0]};
          2'b01: data <= {24'b0,din[15:8]};
          2'b10: data <= {24'b0,din[23:16]};
          2'b11: data <= {24'b0,din[31:24]};
        endcase
      end
      `OP_LH:
      begin
        if(control[1])
          data <= {{16{din[31]}},din[31:16]};
        else
          data <= {{16{din[15]}},din[15:0]};
      end
      `OP_LHU: 
      begin
        if(control[1])
          data <= {16'b0,din[31:16]};
        else
          data <= {16'b0,din[15:0]};
      end
      `OP_LW: data <= din;
    endcase
  end
  
  assign dout = data;
endmodule