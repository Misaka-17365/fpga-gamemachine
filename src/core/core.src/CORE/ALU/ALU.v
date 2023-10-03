module ALU (
    input   wire[31:0]  i_data_1,
    input   wire[31:0]  i_data_2,
    input   wire[3:0]   i_mode,
    output  wire[31:0]  o_data
);
    wire[31:0]  arith_result, logic_result;
    ALU__ARITH alu_arith(
        .in_1(i_data_1),
        .in_2(i_data_2),
        .arith_mode(i_mode[2:0]),
        .result(arith_result)
    );
    ALU__LOGIC alu_logic(
        .in_1(i_data_1),
        .in_2(i_data_2),
        .logic_mode(i_mode[2:0]),
        .result(logic_result)
    );
    assign  o_data = i_mode[3] ? logic_result : arith_result;
    
endmodule


module ALU__ARITH (
    input   wire[31:0]  in_1,
    input   wire[31:0]  in_2,
    input   wire[2:0]   arith_mode,
    output  reg [31:0]  result
);
    wire to_sub = arith_mode[0] | arith_mode[2];
    wire[31:0]  in_2_neg = ~in_2;
    wire[31:0]  op_2 = (to_sub)?(in_2_neg):(in_2);

    wire        carry, subcarry;
    wire[31:0]  sub_result;
    assign      {subcarry,  sub_result[30:0]} = in_1[30:0] + op_2[30:0] + to_sub;
    assign      {carry,     sub_result[31]}   = in_1[31] + op_2[31] + subcarry;
    wire        signed_ov = carry ^ subcarry;

    reg [31:0]  sll_result;
    always @(*) begin
        sll_result = in_1;
        sll_result = in_2[0] ? {sll_result[30:0], 1'b0} : sll_result;
        sll_result = in_2[1] ? {sll_result[29:0], 2'b0} : sll_result;
        sll_result = in_2[2] ? {sll_result[27:0], 4'b0} : sll_result;
        sll_result = in_2[3] ? {sll_result[23:0], 8'b0} : sll_result;
        sll_result = in_2[4] ? {sll_result[15:0], 16'b0} : sll_result;
    end

    always @(*) begin
        case (arith_mode[2:1])
            2'b00: result <= sub_result;
            2'b01: result <= sll_result;
            2'b10: result <= {31'd0, ~signed_ov};
            2'b11: result <= {31'd0, ~carry};
        endcase
    end
    
endmodule

module ALU__LOGIC (
    input   wire[31:0]  in_1,
    input   wire[31:0]  in_2,
    input   wire[2:0]   logic_mode,
    output  reg [31:0]  result
);
    wire    msb = logic_mode[0] ? in_1[31] : 1'b0;

    reg [31:0]  sr_result;
    always @(*) begin
        sr_result = in_1;
        sr_result = in_2[0] ? {{1{msb}}, sr_result[31:1]} : sr_result;
        sr_result = in_2[1] ? {{2{msb}}, sr_result[31:2]} : sr_result;
        sr_result = in_2[2] ? {{4{msb}}, sr_result[31:4]} : sr_result;
        sr_result = in_2[3] ? {{8{msb}}, sr_result[31:8]} : sr_result;
        sr_result = in_2[4] ? {{16{msb}}, sr_result[31:16]} : sr_result;
    end
    always @(*) begin
        case (logic_mode[2:1])
            2'b00: result <= in_1 ^ in_2;
            2'b01: result <= sr_result;
            2'b10: result <= in_1 | in_2;
            2'b11: result <= in_1 & in_2;
        endcase
    end
endmodule