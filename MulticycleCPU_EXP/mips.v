`include "./ctrl_def.v"
`include "./instr_def.v"
`include "./alu.v"
`include "./ext.v"
`include "./pc.v"
`include "./rf.v"
`include "./mux.v"
`include "./tempreg.v"
`include "./beEXT.v"
`include "./dmrEXT.v"
`include "./ctrl.v"

module mips(
  input clk,
  input rst
  );
  
  wire[31:0] instr; 
  wire[31:0] Data_in;
  wire[31:0] addr_in; 
  wire[31:0] pc_new;
  wire[31:0] PC_out;
  wire[31:0] im_rd;
  wire[31:0] dm_rd;
  wire[31:0] dmr_rd;
  wire[31:0] data;
  wire[31:0] rf_wa;
  wire[31:0] rf_wd; 
  wire[31:0] rf_rd1;
  wire[31:0] rf_rdA;
  wire[31:0] rf_rd2;
  wire[31:0] rf_rdB;
  wire[31:0] alu_srcA;
  wire[31:0] alu_srcB;
  wire[31:0] alu_result;
  wire[31:0] aluout;
  wire[31:0] ext_result;
  wire Zero;
  wire[3:0] be;
  //SIGNAL
  wire[1:0] ALUSrcA;
  wire[1:0] ALUSrcB;
  wire[1:0] IorD;
  wire MemWrite;
  wire[1:0] MemtoReg;
  wire IRWrite;
  wire[1:0] RegDst;
  wire RegWrite;
  wire[4:0] ALUOp;
  wire[1:0] EXTOp;  
  wire PCWrite;
  wire[1:0] PCSrc;
  wire PCWriteCond;
  wire PCControl;
  wire[3:0] state;
  
  assign PCControl = PCWrite | (PCWriteCond & Zero);
  
  
  //------------------Link Modules---------------------//
  
  /*
module mux_4 (
  input [1:0] control,  //mux signal
  input [31:0] d0,
  input [31:0] d1,
  input [31:0] d2,
  input [31:0] d3,
  output reg[31:0] dout
  );
 */
 mux_4 MemtoReg_mux(MemtoReg, aluout, data, PC_out, 0, rf_wd);
 mux_4 RegDst_mux(RegDst, {27'b0,instr[20:16]}, {27'b0,instr[15:11]}, 31, 0, rf_wa);
 mux_4 ALUSrcA_mux(ALUSrcA, PC_out, rf_rdA, {27'b0,instr[10:6]}, 0, alu_srcA);
 mux_4 ALUSrcB_mux(ALUSrcB, rf_rdB, 4, ext_result, {ext_result[29:0], 2'b00}, alu_srcB);   
 mux_4 PCSource_mux(PCSrc, alu_result, aluout, {PC_out[31:28], instr[25:0], 2'b00}, 0, pc_new);
 mux_4 IMorDM_mux(IorD, {2'b0, PC_out[31:2]}, {22'b0, aluout[11:2]}, 0, 0, addr_in); 

 
 /*
module alu(
  input [31:0] A,    //1st operand
  input [31:0] B,    //2nd operand
  input [4:0] ALUOp,
  output reg zero,
  output reg[31:0] result 
  );
  */
  alu ALU(alu_srcA, alu_srcB, ALUOp, Zero, alu_result);
  
  /*
module pc(
  input clk,
  input control,
  input [31:0] din,
  output reg[31:0] dout
  );
  */
  pc PC(clk, PCControl, pc_new, PC_out);
  
 /*
module ext(
  input [15:0] Imm16,  //data to extend
  input [1:0] EXTOp,  
  output reg[31:0] Imm32  //extended result
  );
  */
  ext EXT(instr[15:0], EXTOp, ext_result);
  
  /*
module beEXT(
  input [1:0] control,  //aluout[1:0]
  input [5:0] OP,       //instr[31:26]
  output reg[3:0] be   //byte enables
  );
  */
  beEXT beext(aluout[1:0], instr[31:26], be);
  
  /*
module dmrEXT(
  input [1:0] control,   //aluout[1:0]
  input [5:0] OP,        //instr[31:26]
  input [31:0] din,
  input reg[31:0] dout
  );
  */
  dmrEXT dmrext(aluout[1:0], instr[31:26], dmr_rd, data);
  
  /*
module rf(
  input clk,
  input RegWrite,
  input [4:0] RA1, //1st reg address to read
  input [4:0] RA2, //2nd reg address to read
  input [31:0] WA,  //reg address to write
  input [31:0] WD, //reg data to write
  output [31:0] RD1, //1st reg data to read
  output [31:0] RD2  //2nd reg data to read
  );
  */
  rf RF(clk, RegWrite, instr[25:21], instr[20:16], rf_wa, rf_wd, rf_rd1, rf_rd2);
    
  /* 
module mem(
  input clk, //clock
  input DMWr, //memory write enable
  input [31:0] addr, //address bus
  input [3:0] be, //byte enables
  input [31:0] din, //32-bit input data
  output [31:0] dout //32-bit memory output
  );
  */
  mem MEM(clk, MemWrite, addr_in, be, rf_rdB, Data_in);
  
  /*
module tempreg(
  input clk,
  input control,  //register signal
  input [31:0] din,
  output reg[31:0] dout
  );
  */
  tempreg dmr(clk, 1'b1, Data_in, dmr_rd);
  tempreg imr(clk, IRWrite, Data_in, instr);
  tempreg rf_A(clk, 1'b1, rf_rd1, rf_rdA);
  tempreg rf_B(clk, 1'b1, rf_rd2, rf_rdB);
  tempreg ALUOut(clk, 1'b1, alu_result, aluout);
  
  /*
module ctrl(
  input clk,
  input [31:0] currentPC,
  input [31:0] instr,
  output reg IorD,
  output reg PCWrite,
  output reg PCWriteCond,
  output reg MemWrite,
  output reg[1:0] MemtoReg,
  output reg IRWrite,
  output reg DRWrite,
  output reg[1:0] PCSrc,
  output reg[4:0] ALUOp,
  output reg[1:0] ALUSrcA,
  output reg[1:0] ALUSrcB,
  output reg RegWrite,
  output reg[1:0] RegDst,
  output reg[1:0] EXTOp,
  output reg[3:0] state
  );
  
  */
  ctrl CTRL(clk, PC_out, instr, IorD, PCWrite, PCWriteCond, MemWrite, MemtoReg, 
  IRWrite, PCSrc, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst, EXTOp, state);
  
endmodule
