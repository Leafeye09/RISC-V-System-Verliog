module top_level #(parameter N = 32)(
  input logic clk, rst,
  input logic [4:0] reg_sel,
  output logic [N-1:0] reg_out
);
  //wires for if_stage NOTE: the ID_stage has the branch and such so no need to double
  logic [N-1:0] pc, instr;
  
  //wires for ID
  logic [N-1:0] rs1_data, rs2_data, imm;
  logic [4:0]   rs1_addr, rs2_addr, rd_addr;
  logic [6:0]   opcode, funct7;
  logic [2:0]   funct3;
  
  //wires for ctrl 
  logic [3:0]   alu_ctrl;
  logic         alu_src, reg_write, mem_read, mem_write, branch, jump;
  //wires for Ex
  logic [N-1:0] alu_result, branch_target;
  logic         take_branch;
  
  
// IF stage 
    if_stage #(.N(N)) if_inst (
        .clk          (clk),
        .rst          (rst),
        .take_branch  (take_branch),
        .branch_target(branch_target),
        .pc_out       (pc),
        .instr_out    (instr)
    );

    // ID stage
    id_stage #(.N(N)) id_inst (
        .clk      (clk),
        .rst      (rst),
        .we       (reg_write),
        .instr    (instr),
        .rd_wb    (rd_addr),       // writeback address
        .wd_wb    (alu_result),    // writeback data
        .rs1_addr (rs1_addr),
        .rs2_addr (rs2_addr),
        .rd_addr  (rd_addr),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data),
        .imm      (imm),
        .opcode   (opcode),
        .funct3   (funct3),
        .funct7   (funct7)
    );

    // Control unit
    ctrl_unit ctrl_inst (
        .opcode   (opcode),
        .funct3   (funct3),
        .funct7   (funct7),
        .alu_ctrl (alu_ctrl),
        .alu_src  (alu_src),
        .reg_write(reg_write),
        .mem_read (mem_read),
        .mem_write(mem_write),
        .branch   (branch),
        .jump     (jump)
    );

    // EX stage
    ex_stage #(.N(N)) ex_inst (
        .rs1_data     (rs1_data),
        .rs2_data     (rs2_data),
        .pc           (pc),
        .imm          (imm),
        .alu_ctrl     (alu_ctrl),
        .alu_src      (alu_src),
        .branch       (branch),
        .jump         (jump),
        .alu_result   (alu_result),
        .branch_target(branch_target),
        .rs2_out      (),             // unused for now (needed later for stores)
        .take_branch  (take_branch),
        .funct3		  (funct3)
    );
    assign reg_out = id_inst.rf.regs[reg_sel];
endmodule  
