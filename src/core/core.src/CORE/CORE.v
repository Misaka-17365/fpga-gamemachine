module CORE (
    input   wire        i_RST,
    input   wire        i_CLK,

    output  wire[31:0]  o_PC,
    input   wire[31:0]  i_inst,

    output  wire[31:0]  o_RAM_addr,
    output  wire[31:0]  o_RAM_data,
    input   wire[31:0]  i_RAM_data,
    output  wire[1:0]   o_RAM_mode,
    output  wire        o_RAM_wen
    );

    
    
endmodule