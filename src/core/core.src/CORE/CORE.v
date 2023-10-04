`include "../header/hd_CORE.v"


module CORE (
    input   wire        i_RST,
    input   wire        i_CLK,

    output  wire[31:0]  o_PC,
    input   wire[31:0]  i_inst,

    output  wire[31:0]  o_RAM_addr,
    output  wire[31:0]  o_RAM_data,
    input   wire[31:0]  i_RAM_data,
    output  wire[1:0]   o_RAM_mode,
    output  wire        o_RAM_w_en
    );

    wire[4:0]   regs_1_sel,  regs_2_sel,  regs_w_sel;
    wire[31:0]  regs_1_data, regs_2_data, regs_w_data;
    REGS regs(
        .i_RST(i_RST),
        .i_CLK(i_CLK),
        .i_reg_1_sel(regs_1_sel),
        .i_reg_2_sel(regs_2_sel),
        .o_reg_1(regs_1_data),
        .o_reg_2(regs_2_data),
        .i_reg_w_sel(regs_w_sel),
        .i_reg_w_data(regs_w_data)
    );

    wire        pause_n;
    wire[31:0]  pc_now,  pc_ex;
    wire        pc_set;
    PC pc(
        .i_RST(i_RST),
        .i_CLK(i_CLK),
        .i_EN(pause_n),
        .i_pc(pc_ex),
        .i_pc_set(pc_set),
        .o_pc(pc_now)
    );
    assign  o_PC = pc_now;

    wire        flush = i_RST | pc_set;
    wire[31:0]  inst;
    CORE__IF core__if(
        .i_RST(i_RST),
        .i_CLK(i_CLK),
        .i_EN(pause_n),
        .i_inst(i_inst),
        .o_inst(inst)
    );

    wire[31:0]  reg_A_data, reg_B_data, imm;
    wire[`UI_EX_LEN-1:0]    id_ui_ex;
    wire[`UI_MEM_LEN-1:0]   id_ui_mem;
    wire[`UI_WB_LEN-1:0]    id_ui_wb;
    wire[`UI_PC_LEN-1:0]    id_ui_pc;
    wire[37:0]              ex_bypass;
    wire[36:0]              mem_bypass;
    wire                    pause;
    CORE__ID core__id(
        .i_RST(flush),
        .i_CLK(i_CLK),
        .i_EN(pause_n),
        .i_inst(inst),
        .o_regs_1_sel(regs_1_sel),
        .o_regs_2_sel(regs_2_sel),
        .i_regs_1_data(regs_1_data),
        .i_regs_2_data(regs_2_data),
        .o_reg_A_data(reg_A_data),
        .o_reg_B_data(reg_B_data),
        .o_imm(imm),
        .o_ui_ex(id_ui_ex),
        .o_ui_mem(id_ui_mem),
        .o_ui_wb(id_ui_wb),
        .o_ui_pc(id_ui_pc),
        .i_ex_bypass(ex_bypass),
        .i_mem_bypass(mem_bypass),
        .o_pause(pause)
    );
    assign  pause_n = ~pause;
    
    wire[`UI_MEM_LEN-1:0]   ex_ui_mem;
    wire[`UI_WB_LEN-1:0]    ex_ui_wb;
    wire[31:0]              ex_RAM_addr;
    wire[31:0]              ex_data;
    wire                    ex_rst = flush | (~pause_n);
    CORE__EX core__ex(
        .i_RST(ex_rst),
        .i_CLK(i_CLK),
        .i_EN(pause_n),
        .i_reg_A_data(reg_A_data),
        .i_reg_B_data(reg_B_data),
        .i_imm(imm),

        .i_pc(pc_now),
        .o_pc_set(pc_set),
        .o_pc(pc_ex),

        .i_ui_ex(id_ui_ex),
        .i_ui_pc(id_ui_pc),
        .i_ui_mem(id_ui_mem),
        .i_ui_wb(id_ui_wb),
        .o_ui_mem(ex_ui_mem),
        .o_ui_wb(ex_ui_wb),

        .o_RAM_addr(ex_RAM_addr),
        .o_ex_data(ex_data),
        .o_ex_bypass(ex_bypass)
    );

    wire[`UI_WB_LEN-1:0]    mem_ui_wb;
    wire[31:0]              mem_data;
    CORE__MEM core__mem(
        .i_RST(i_RST),
        .i_CLK(i_CLK),
        .i_EN(1'b1),

        .i_ui_mem(ex_ui_mem),
        .i_RAM_addr(ex_RAM_addr),
        .i_ex_data(ex_data),
        .o_RAM_addr(o_RAM_addr),
        .o_RAM_data(o_RAM_data),
        .i_RAM_data(i_RAM_data),
        .o_RAM_w_en(o_RAM_w_en),
        .o_RAM_mode(o_RAM_mode),

        .i_ui_wb(ex_ui_wb),
        .o_ui_wb(mem_ui_wb),
        .o_mem_data(mem_data),
        .o_mem_bypass(mem_bypass)
    );

    CORE__WB core__wb(
        .i_RST(i_RST),
        .i_CLK(i_CLK),
        .i_EN(1'b1),
        .i_mem_data(mem_data),
        .i_ui_wb(mem_ui_wb),
        .o_wb_sel(regs_w_sel),
        .o_wb_data(regs_w_data)
    );
    
endmodule


module CORE__IF (
    input   wire        i_RST,
    input   wire        i_CLK,
    input   wire        i_EN,

    input   wire[31:0]  i_inst,
    output  reg [31:0]  o_inst
);
    always @(negedge i_CLK) begin
        if (i_EN) begin
            o_inst <= i_inst;
        end

        if (i_RST) begin
            o_inst <= 32'd0;
        end
    end
    
endmodule

module CORE__ID (
    input   wire        i_RST,
    input   wire        i_CLK,
    input   wire        i_EN,

    input   wire[31:0]  i_inst,

    output  wire[4:0]   o_regs_1_sel,
    output  wire[4:0]   o_regs_2_sel,
    input   wire[31:0]  i_regs_1_data,
    input   wire[31:0]  i_regs_2_data,

    input   wire[37:0]  i_ex_bypass,
    input   wire[36:0]  i_mem_bypass,

    output  reg [31:0]  o_reg_A_data,
    output  reg [31:0]  o_reg_B_data,
    output  reg [31:0]  o_imm,

    output  reg [`UI_EX_LEN-1:0]    o_ui_ex,
    output  reg [`UI_MEM_LEN-1:0]   o_ui_mem,
    output  reg [`UI_WB_LEN-1:0]    o_ui_wb,
    output  reg [`UI_PC_LEN-1:0]    o_ui_pc,

    output  wire        o_pause
);

    wire[`UI_EX_LEN-1:0]    ui_ex;
    wire[`UI_MEM_LEN-1:0]   ui_mem;
    wire[`UI_WB_LEN-1:0]    ui_wb;
    wire[`UI_PC_LEN-1:0]    ui_pc;
    wire[31:0]              imm;
        
    DEC dec(
        .i_inst(i_inst),
        .o_ui_ex(ui_ex),
        .o_ui_mem(ui_mem),
        .o_ui_wb(ui_wb),
        .o_ui_pc(ui_pc),
        .o_imm(imm),
        .o_regs_1_sel(o_regs_1_sel),
        .o_regs_2_sel(o_regs_2_sel)
    );
    wire[31:0]  reg_A_data, reg_B_data;
    BYPASS bypass(
        .i_regs_1_sel(o_regs_1_sel),
        .i_regs_2_sel(o_regs_2_sel),
        .i_regs_1_data(i_regs_1_data),
        .i_regs_2_data(i_regs_2_data),
        .i_ex_bypass(i_ex_bypass),
        .i_mem_bypass(i_mem_bypass),
        .o_reg_A_data(reg_A_data),
        .o_reg_B_data(reg_B_data),
        .o_pause(o_pause)
    );
    always @(negedge i_CLK) begin
        if (i_EN) begin
            o_ui_ex     <= ui_ex;
            o_ui_mem    <= ui_mem;
            o_ui_wb     <= ui_wb;
            o_ui_pc     <= ui_pc;
            o_imm       <= imm;
            o_reg_A_data<= reg_A_data;
            o_reg_B_data<= reg_B_data;
        end
        if (i_RST) begin
            o_ui_ex     <= {`UI_EX_LEN{1'b0}};
            o_ui_mem    <= {`UI_MEM_LEN{1'b0}};
            o_ui_wb     <= {`UI_WB_LEN{1'b0}};
            o_ui_pc     <= {`UI_PC_LEN{1'b0}};
            o_imm       <= 32'b0;
            o_reg_A_data<= 32'd0;
            o_reg_B_data<= 32'd0;
        end
    end
    
endmodule

module CORE__EX (
    input   wire        i_RST,
    input   wire        i_CLK,
    input   wire        i_EN,

    input   wire[31:0]  i_reg_A_data,
    input   wire[31:0]  i_reg_B_data,
    input   wire[31:0]  i_imm,
    input   wire[31:0]  i_pc,

    input   wire[`UI_EX_LEN-1:0]    i_ui_ex,

    input   wire[`UI_PC_LEN-1:0]    i_ui_pc,
    output  wire                    o_pc_set,
    output  wire[31:0]              o_pc,

    input   wire[`UI_MEM_LEN-1:0]   i_ui_mem,
    input   wire[`UI_WB_LEN-1:0]    i_ui_wb,
    output  reg [`UI_MEM_LEN-1:0]   o_ui_mem,
    output  reg [`UI_WB_LEN-1:0]    o_ui_wb,

    output  reg [31:0]              o_RAM_addr,
    output  reg [31:0]              o_ex_data,
    output  wire[37:0]              o_ex_bypass

);
    wire[3:0]   ALU_mode      = i_ui_ex[3:0];
    wire        ALU_in_2_sel  = i_ui_ex[4];
    wire[1:0]   final_out_sel = i_ui_ex[6:5];

    wire    pc_jalr  = i_ui_pc[3];
    wire    pc_b_neg = i_ui_pc[2];
    wire    pc_b_en  = i_ui_pc[1];
    wire    pc_jmp   = i_ui_pc[0];

    wire[31:0]  ALU_in_2 = ALU_in_2_sel ? i_imm : i_reg_B_data;
    wire[31:0]  ALU_result;
    ALU alu(
        .i_data_1(i_reg_A_data),
        .i_data_2(ALU_in_2),
        .i_mode(ALU_mode),
        .o_data(ALU_result)
    );


    reg [31:0]  final_out;
    wire[31:0]  pc_add_imm = i_pc + i_imm;
    wire[31:0]  pc_next = i_pc - 32'd4;
    always @(*) begin
        case (final_out_sel)
            2'b00: final_out <= ALU_result;
            2'b01: final_out <= i_reg_B_data;
            2'b10: final_out <= pc_add_imm;
            2'b11: final_out <= pc_next;
        endcase
    end
    always @(negedge i_CLK) begin
        if (i_EN) begin
            o_ex_data  <= final_out;
            o_RAM_addr <= ALU_result;
            o_ui_mem   <= i_ui_mem;
            o_ui_wb    <= i_ui_wb;
        end
        if (i_RST) begin
            o_ex_data  <= 32'd0;
            o_RAM_addr <= 32'd0;
            o_ui_mem   <= {`UI_MEM_LEN{1'b0}};
            o_ui_wb    <= {`UI_WB_LEN{1'b0}};
        end
    end

    assign  o_pc_set = (pc_jmp) | (pc_b_en & (pc_b_neg ^ (|ALU_result)));
    assign  o_pc   = pc_jalr ? ALU_result : pc_add_imm;
    assign  o_ex_bypass = {i_ui_mem[4], i_ui_wb, final_out};
endmodule

module CORE__MEM (
    input   wire        i_RST,
    input   wire        i_CLK,
    input   wire        i_EN,

    input   wire[31:0]  i_RAM_addr,
    input   wire[31:0]  i_ex_data,
    output  wire[31:0]  o_RAM_addr,
    output  wire[31:0]  o_RAM_data,
    input   wire[31:0]  i_RAM_data,

    input   wire[`UI_MEM_LEN-1:0]   i_ui_mem,
    output  wire                    o_RAM_w_en,
    output  wire                    o_RAM_unsign,
    output  wire[1:0]               o_RAM_mode,

    input   wire[`UI_WB_LEN-1:0]    i_ui_wb,
    output  reg [`UI_WB_LEN-1:0]    o_ui_wb,

    output  reg [31:0]              o_mem_data,
    output  wire[36:0]              o_mem_bypass
);
    assign      o_RAM_addr      = i_RAM_addr;
    assign      o_RAM_data      = i_ex_data;
    assign      o_RAM_mode      = i_ui_mem[1:0];
    assign      o_RAM_unsign    = i_ui_mem[2];
    assign      o_RAM_w_en      = i_ui_mem[3];
    wire        load_inst       = i_ui_mem[4];
    
    wire[31:0]  selected_data = load_inst ? i_RAM_data : i_ex_data;
    
    always @(negedge i_CLK) begin
        if (i_EN) begin
            o_mem_data  <= selected_data;
            o_ui_wb     <= i_ui_wb;
        end
        if (i_RST) begin
            o_mem_data  <= 32'd0;
            o_ui_wb     <= {`UI_WB_LEN{1'd0}};
        end
    end

    assign  o_mem_bypass = {i_ui_wb, selected_data};
    
endmodule

module CORE__WB (
    input   wire        i_RST,
    input   wire        i_CLK,
    input   wire        i_EN,

    input   wire[31:0]              i_mem_data,
    input   wire[`UI_WB_LEN-1:0]    i_ui_wb,

    output  reg [4:0]               o_wb_sel,
    output  reg [31:0]              o_wb_data
);
    always @(negedge i_CLK) begin
        if (i_EN) begin
            o_wb_data   <= i_mem_data;
            o_wb_sel    <= i_ui_wb;
        end
        if (i_RST) begin
            o_wb_data   <= 32'd0;
            o_wb_sel    <= 5'd0;
        end
    end
    
endmodule
