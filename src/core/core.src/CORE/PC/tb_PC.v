module tb_PC (
);
    reg         RST, CLK, EN, pc_set;
    reg [31:0]  pc_ex;

    initial fork
        RST = 1;
        CLK = 0;
        EN = 0;
        pc_set = 0;
        pc_ex = 32'h56;
        
        #20 RST = 0;
        #50 EN = 1;
        #80 pc_set = 1;
        #100 pc_set = 0;
    join

    always begin
        CLK <= ~CLK;
        #10;
    end

    PC pc(
        .i_RST(RST),
        .i_CLK(CLK),
        .i_EN(EN),
        .i_pc(pc_ex),
        .i_pc_set(pc_set),
        .o_pc()
    );
    
endmodule