module PC (
    input   wire        i_RST,
    input   wire        i_CLK,
    input   wire        i_EN,
    input   wire[31:0]  i_pc,
    input   wire        i_pc_set,
    output  reg [31:0]  o_pc
);
    wire[31:0]  pc_next = (i_pc_set)?(i_pc):(o_pc + 4'd4);
    always @(negedge i_CLK) begin
        if (i_EN) begin
            o_pc <= pc_next;
        end
        if (i_RST) begin
            o_pc <= 32'd0;
        end
    end
    
endmodule