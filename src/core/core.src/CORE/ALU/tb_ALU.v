module tb_ALU ();

    reg [31:0]  d1, d2;
    reg [3:0]   mode;
    wire[31:0]  res;

    ALU alu(
        .i_data_1(d1),
        .i_data_2(d2),
        .i_mode(mode),
        .o_data(res)
    );

    initial begin
        d1 = -32'hff;
        d2 = 32'd2;
        mode = 0;
    end

    always #20 mode <= mode + 1;

    reg [5*8:0] str;
    always @(*) begin
        casez (mode)
            4'b0000: str = "add";
            4'b0001: str = "sub";
            4'b010?: str = "slt";
            4'b011?: str = "sltu";
            4'b001?: str = "sll";
            4'b100?: str = "xor";
            4'b110?: str = "or";
            4'b111?: str = "and";
            4'b1010: str = "srl";
            4'b1011: str = "sra";
        endcase
    end
    
endmodule