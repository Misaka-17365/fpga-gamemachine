module tb_REGS (
);
    reg         RST, CLK;
    reg [4:0]   r1_s, r2_s, w_s;
    reg [31:0]  w_d;
    wire[31:0]  o_1, o_2;

    initial fork
        RST = 0;
        CLK = 0;
        r1_s = 1;
        r2_s = 2;
        w_s = 0;
        w_d = 32'd265;
        #20 RST = 1;
        #50 RST = 0;
        #100  w_s = 1;
        #150  w_s = 2;
    join

    always #10 CLK = ~CLK;

    REGS regs(
        .i_RST(RST),
        .i_CLK(CLK),
        .i_reg_1_sel(r1_s),
        .i_reg_2_sel(r2_s),
        .o_reg_1(o_1),
        .o_reg_2(o_2),
        .i_reg_w_sel(w_s),
        .i_reg_w_data(w_d)
    );
    
endmodule