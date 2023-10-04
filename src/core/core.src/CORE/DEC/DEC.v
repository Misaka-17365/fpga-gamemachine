`include "../../header/hd_CORE.v"

module DEC (
    input   wire[31:0]  i_inst,
    output  wire[`UI_EX_LEN-1:0]    o_ui_ex,
    output  wire[`UI_MEM_LEN-1:0]   o_ui_mem,
    output  wire[`UI_WB_LEN-1:0]    o_ui_wb,
    output  wire[`UI_PC_LEN-1:0]    o_ui_pc,

    output  wire[4:0]               o_regs_1_sel,
    output  wire[4:0]               o_regs_2_sel,
    output  wire[31:0]              o_imm
);
    DEC__PC dec__pc(
        .i_inst(i_inst),
        .o_ui_pc(o_ui_pc)
    );
    DEC__EX dec__ex(
        .i_inst(i_inst),
        .o_ui_ex(o_ui_ex)
    );
    DEC__MEM dec_mem(
        .i_inst(i_inst),
        .o_ui_mem(o_ui_mem)
    );
    DEC__WB dec_wb(
        .i_inst(i_inst),
        .o_ui_wb(o_ui_wb)
    );
    DEC__IMM dec_imm(
        .i_inst(i_inst),
        .o_imm(o_imm)
    );
    DEC_REGS dec_regs(
        .i_inst(i_inst),
        .o_regs_1_sel(o_regs_1_sel),
        .o_regs_2_sel(o_regs_2_sel)
    );
    
endmodule

module DEC__PC (
    input   wire[31:0]              i_inst,
    output  wire[`UI_PC_LEN-1:0]    o_ui_pc
);
    assign o_ui_pc[0] = (i_inst[6:4] == 3'b110) & (i_inst[2:0] == 3'b111); 
    assign o_ui_pc[1] = i_inst[6:0] == 7'b1100011;
    assign o_ui_pc[2] = (i_inst[14:13] == 2'b00) ? ~i_inst[12] : i_inst[12];
    assign o_ui_pc[3] = o_ui_pc[0] & (~i_inst[3]); 
    
endmodule

module DEC__EX (
    input   wire[31:0]              i_inst,
    output  wire[`UI_EX_LEN-1:0]    o_ui_ex
);
    localparam  ADD  = 4'b0000;
    localparam  SUB  = 4'b0001;
    localparam  SLT  = 4'b0100;
    localparam  SLTU = 4'b0110;
    localparam  SLL  = 4'b0010;
    localparam  XOR  = 4'b1000;
    localparam  OR   = 4'b1100;
    localparam  AND  = 4'b1110;
    localparam  SRL  = 4'b1010;
    localparam  SRA  = 4'b1011;
    
    reg [3:0]   ALU_mode;
    always @(*) begin
        case (i_inst[6:2])
            5'b01101, 5'b00101, 5'b11011, 5'b11001: ALU_mode <= ADD;
            // B-type
            5'b11000: case (i_inst[14:13])
                2'b00: ALU_mode <= SUB;
                2'b10: ALU_mode <= SLT;
                2'b11: ALU_mode <= SLTU;
                default: ALU_mode <= ADD;
            endcase
            // Load
            5'b00000: ALU_mode <= ADD;
            // Store
            5'b01000: ALU_mode <= ADD;
            // R-I
            5'b00100: ALU_mode <= {i_inst[14:12], i_inst[30]&(i_inst[14:12] == 3'b101)};
            // R
            5'b01100: ALU_mode <= {i_inst[14:12], i_inst[31]&(i_inst[14:12] == 3'b000 || i_inst[14:12] == 3'b101)};
            default: ALU_mode  <= ADD;
        endcase        
    end
    
    wire    ALU_in_2 = (
                (i_inst[6:2] == 5'b01101 || // lui
                i_inst[6:2] == 5'b11001 ||  // jalr
                i_inst[6:2] == 5'b11000)    // b
                ||  
                (i_inst[6:2] == 5'b00000 || // ld
                i_inst[6:2] == 5'b01000 ||  // str
                i_inst[6:2] == 5'b00100)    // R-I
            );

    reg [1:0]   out_sel;
    localparam res_ALU     = 2'b00;
    localparam res_REG_2   = 2'b01;
    localparam res_PC_imm  = 2'b10;
    localparam res_PC_4    = 2'b11;
    always @(*) begin
        case (i_inst[6:2])
            5'b00101: out_sel <= res_PC_imm;    // auipc
            5'b11011: out_sel <= res_PC_4;      // jal
            5'b11001: out_sel <= res_PC_4;      // jalr
            5'b01000: out_sel <= res_REG_2;     // store

            default:  out_sel <= res_ALU;
        endcase
    end
    assign  o_ui_ex = {out_sel, ALU_in_2, ALU_mode};
endmodule

module DEC__MEM (
    input   wire[31:0]  i_inst,
    output  wire[`UI_MEM_LEN-1:0]   o_ui_mem
);
    assign  o_ui_mem[4] = i_inst[6:0] == 7'b0000011;
    assign  o_ui_mem[3] = i_inst[6:0] == 7'b0100011;
    assign  o_ui_mem[2] = i_inst[14];
    assign  o_ui_mem[1:0] = i_inst[13:12];
    
endmodule

module DEC__WB (
    input   wire[31:0]  i_inst,
    output  wire[`UI_WB_LEN-1:0]    o_ui_wb
);
    wire wb_en = ((
        i_inst[6:0] == 7'b0110111 ||
        i_inst[6:0] == 7'b0001011 ||
        i_inst[6:0] == 7'b1101111 ||
        i_inst[6:0] == 7'b1100111 
        )||(
        i_inst[6:0] == 7'b0000011 ||
        i_inst[6:0] == 7'b0010011 ||
        i_inst[6:0] == 7'b0110011
        )
    );
    assign  o_ui_wb = wb_en ? i_inst[11:7] : 5'b0;
    
endmodule

module DEC__IMM (
    input   wire[31:0]  i_inst,
    output  wire[31:0]  o_imm
);
    wire[31:0]  upper_imm   = { i_inst[31:12], 12'b0 };
    wire        sig_bit     = i_inst[31];

    reg [31:0]  lower_imm;
    wire        is_jalr         = i_inst[6:0] == 7'b1101111;
    wire        is_upper_imm    = i_inst[6:0] == 7'b0110111 || i_inst[6:0] == 7'b0010111;
    wire        is_brench       = i_inst[6:0] == 7'b1100011;
    wire        is_normal       = i_inst[6:0] == 7'b1100111 || i_inst[6:0] == 7'b0000011 || i_inst[6:0] == 7'b0010011;
    wire        is_store        = i_inst[6:0] == 7'b0100011;
    always @(*) begin
        lower_imm = 32'd0;
        lower_imm[10:5] = i_inst[30:25];
        if (is_jalr) begin        
            lower_imm[31:20] = {12{sig_bit}};
            lower_imm[19:12] = i_inst[19:12];
            lower_imm[11]    = i_inst[20];
            lower_imm[4:1]   = i_inst[24:21];
        end
        else if (is_brench) begin  
            lower_imm[31:12] = {20{sig_bit}};
            lower_imm[11]    = i_inst[7];
            lower_imm[4:1]   = i_inst[11:8];
        end

        if (is_normal) begin
            lower_imm[31:11]  = {21{sig_bit}};
            lower_imm[4:0]    = i_inst[24:20];
        end
        else if (is_store) begin
            lower_imm[31:11]  = {21{sig_bit}};
            lower_imm[4:0]    = i_inst[11:7];
        end
    end

    assign      o_imm = is_upper_imm ? upper_imm : lower_imm;
    
endmodule


module DEC_REGS (
    input   wire[31:0]  i_inst,
    output  wire[4:0]   o_regs_1_sel,
    output  wire[4:0]   o_regs_2_sel,
    output  wire[4:0]   o_regs_w_sel
);
    wire[6:0]   opcode = i_inst[6:0];
    wire        regs_1_en = ( 
                            opcode == 7'b1100111 ||
                            opcode == 7'b1100011 ||
                            opcode == 7'b0000011 
                            )||(
                            opcode == 7'b0100011 ||
                            opcode == 7'b0010011 ||
                            opcode == 7'b0110011
                            );
    wire        regs_2_en = (
                            opcode == 7'b1100011 ||
                            opcode == 7'b0100011 ||
                            opcode == 7'b0110011  
                            );

    assign      o_regs_1_sel  = regs_1_en ? i_inst[19:15] : 5'b0;
    assign      o_regs_2_sel  = regs_2_en ? i_inst[24:20] : 5'b0;

    
endmodule