module mux_4 (
  input [1:0] control, //mux signal
  input [31:0] d0,
  input [31:0] d1,
  input [31:0] d2,
  input [31:0] d3,
  output [31:0] dout
  );
  
  reg[31:0] data;
  
  always@(*)
  begin
    case(control)
      2'b00: data <= d0;
      2'b01: data <= d1;
      2'b10: data <= d2;
      2'b11: data <= d3;
    endcase
  end
  
  assign dout = data;
endmodule



