module REGS (
    input   wire        i_RST,
    input   wire        i_CLK,

    input   wire[4:0]   i_reg_1_sel,
    input   wire[4:0]   i_reg_2_sel,
    output  reg [31:0]  o_reg_1,
    output  reg [31:0]  o_reg_2,

    input   wire[4:0]   i_reg_w_sel,
    input   wire[31:0]  i_reg_w_data
);
    
    reg [31:0] regs [31:1];

    always @(*) begin
        case (i_reg_1_sel)
            5'd0: o_reg_1 <= 32'd0;  
            5'd1: o_reg_1 <= regs[1];
            5'd2: o_reg_1 <= regs[2];
            5'd3: o_reg_1 <= regs[3];
            5'd4: o_reg_1 <= regs[4];
            5'd5: o_reg_1 <= regs[5];
            5'd6: o_reg_1 <= regs[6];
            5'd7: o_reg_1 <= regs[7];
            5'd8: o_reg_1 <= regs[8];
            5'd9: o_reg_1 <= regs[9];
            5'd10: o_reg_1 <= regs[10];
            5'd11: o_reg_1 <= regs[11];
            5'd12: o_reg_1 <= regs[12];
            5'd13: o_reg_1 <= regs[13];
            5'd14: o_reg_1 <= regs[14];
            5'd15: o_reg_1 <= regs[15];
            5'd16: o_reg_1 <= regs[16];
            5'd17: o_reg_1 <= regs[17];
            5'd18: o_reg_1 <= regs[18];
            5'd19: o_reg_1 <= regs[19];
            5'd20: o_reg_1 <= regs[20];
            5'd21: o_reg_1 <= regs[21];
            5'd22: o_reg_1 <= regs[22];
            5'd23: o_reg_1 <= regs[23];
            5'd24: o_reg_1 <= regs[24];
            5'd25: o_reg_1 <= regs[25];
            5'd26: o_reg_1 <= regs[26];
            5'd27: o_reg_1 <= regs[27];
            5'd28: o_reg_1 <= regs[28];
            5'd29: o_reg_1 <= regs[29];
            5'd30: o_reg_1 <= regs[30];
            5'd31: o_reg_1 <= regs[31];
        endcase
    end

    always @(*) begin
        case (i_reg_2_sel)
            5'd0: o_reg_2 <= 32'd0;  
            5'd1: o_reg_2 <= regs[1];
            5'd2: o_reg_2 <= regs[2];
            5'd3: o_reg_2 <= regs[3];
            5'd4: o_reg_2 <= regs[4];
            5'd5: o_reg_2 <= regs[5];
            5'd6: o_reg_2 <= regs[6];
            5'd7: o_reg_2 <= regs[7];
            5'd8: o_reg_2 <= regs[8];
            5'd9: o_reg_2 <= regs[9];
            5'd10: o_reg_2 <= regs[10];
            5'd11: o_reg_2 <= regs[11];
            5'd12: o_reg_2 <= regs[12];
            5'd13: o_reg_2 <= regs[13];
            5'd14: o_reg_2 <= regs[14];
            5'd15: o_reg_2 <= regs[15];
            5'd16: o_reg_2 <= regs[16];
            5'd17: o_reg_2 <= regs[17];
            5'd18: o_reg_2 <= regs[18];
            5'd19: o_reg_2 <= regs[19];
            5'd20: o_reg_2 <= regs[20];
            5'd21: o_reg_2 <= regs[21];
            5'd22: o_reg_2 <= regs[22];
            5'd23: o_reg_2 <= regs[23];
            5'd24: o_reg_2 <= regs[24];
            5'd25: o_reg_2 <= regs[25];
            5'd26: o_reg_2 <= regs[26];
            5'd27: o_reg_2 <= regs[27];
            5'd28: o_reg_2 <= regs[28];
            5'd29: o_reg_2 <= regs[29];
            5'd30: o_reg_2 <= regs[30];
            5'd31: o_reg_2 <= regs[31];
        endcase
    end

    always @(posedge i_CLK) begin
        case (i_reg_w_sel)
            5'd0: ;
            5'd1: regs[1] <= i_reg_w_data;
            5'd2: regs[2] <= i_reg_w_data;
            5'd3: regs[3] <= i_reg_w_data;
            5'd4: regs[4] <= i_reg_w_data;
            5'd5: regs[5] <= i_reg_w_data;
            5'd6: regs[6] <= i_reg_w_data;
            5'd7: regs[7] <= i_reg_w_data;
            5'd8: regs[8] <= i_reg_w_data;
            5'd9: regs[9] <= i_reg_w_data;
            5'd10: regs[10] <= i_reg_w_data;
            5'd11: regs[11] <= i_reg_w_data;
            5'd12: regs[12] <= i_reg_w_data;
            5'd13: regs[13] <= i_reg_w_data;
            5'd14: regs[14] <= i_reg_w_data;
            5'd15: regs[15] <= i_reg_w_data;
            5'd16: regs[16] <= i_reg_w_data;
            5'd17: regs[17] <= i_reg_w_data;
            5'd18: regs[18] <= i_reg_w_data;
            5'd19: regs[19] <= i_reg_w_data;
            5'd20: regs[20] <= i_reg_w_data;
            5'd21: regs[21] <= i_reg_w_data;
            5'd22: regs[22] <= i_reg_w_data;
            5'd23: regs[23] <= i_reg_w_data;
            5'd24: regs[24] <= i_reg_w_data;
            5'd25: regs[25] <= i_reg_w_data;
            5'd26: regs[26] <= i_reg_w_data;
            5'd27: regs[27] <= i_reg_w_data;
            5'd28: regs[28] <= i_reg_w_data;
            5'd29: regs[29] <= i_reg_w_data;
            5'd30: regs[30] <= i_reg_w_data;
            5'd31: regs[31] <= i_reg_w_data;
        endcase

        if (i_RST) begin
            regs[1] <= 32'd0;
            regs[2] <= 32'd0;
            regs[3] <= 32'd0;
            regs[4] <= 32'd0;
            regs[5] <= 32'd0;
            regs[6] <= 32'd0;
            regs[7] <= 32'd0;
            regs[8] <= 32'd0;
            regs[9] <= 32'd0;
            regs[10] <= 32'd0;
            regs[11] <= 32'd0;
            regs[12] <= 32'd0;
            regs[13] <= 32'd0;
            regs[14] <= 32'd0;
            regs[15] <= 32'd0;
            regs[16] <= 32'd0;
            regs[17] <= 32'd0;
            regs[18] <= 32'd0;
            regs[19] <= 32'd0;
            regs[20] <= 32'd0;
            regs[21] <= 32'd0;
            regs[22] <= 32'd0;
            regs[23] <= 32'd0;
            regs[24] <= 32'd0;
            regs[25] <= 32'd0;
            regs[26] <= 32'd0;
            regs[27] <= 32'd0;
            regs[28] <= 32'd0;
            regs[29] <= 32'd0;
            regs[30] <= 32'd0;
            regs[31] <= 32'd0;
        end
    end
    
endmodule