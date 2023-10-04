module BYPASS (
    input   wire[4:0]   i_regs_1_sel,
    input   wire[4:0]   i_regs_2_sel,
    input   wire[31:0]  i_regs_1_data,
    input   wire[31:0]  i_regs_2_data,

    input   wire[37:0]  i_ex_bypass,
    input   wire[36:0]  i_mem_bypass,

    output  wire[31:0]  o_reg_A_data,
    output  wire[31:0]  o_reg_B_data,
    output  wire        o_pause
);

    assign  o_reg_A_data =  i_regs_1_sel == i_ex_bypass[36:32]  ? i_ex_bypass[31:0]  :
                            i_regs_1_sel == i_mem_bypass[36:32] ? i_mem_bypass[31:0] :
                            i_regs_1_data;
    assign  o_reg_B_data =  i_regs_2_sel == i_ex_bypass[36:32]  ? i_ex_bypass[31:0]  :
                            i_regs_2_sel == i_mem_bypass[36:32] ? i_mem_bypass[31:0] :
                            i_regs_2_data;
    assign  o_pause      =  (i_regs_1_sel == i_ex_bypass[36:32] && i_regs_1_sel != 5'd0 && i_ex_bypass[37])
                            ||
                            (i_regs_2_sel == i_ex_bypass[36:32] && i_regs_2_sel != 5'd0 && i_ex_bypass[37]);
    
endmodule