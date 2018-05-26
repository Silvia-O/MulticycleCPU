# MulticycleCPU

1.MulticycleCPU
  IM and DM are designed as two seperated modules.
  
2.MulticycleCPU_EXP
  IM and DM are designed as a combined module MEM in order to go through the hardware experiment. 
  The lower mems serve for datamemory, and the higher mems(> pc_initial:32'h3000) serve for instrmemory.
  Add a new mux to choose the addr_in between pc_out(for instr) and alu_out(for data) for MEM 
  and a new signal IorD to control it.
