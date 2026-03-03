module MEM_Stage (
    input wire clk,
    
    // Control signals
    input wire MEMR,
    input wire MEMW,
    
    // Data inputs
    input wire [31:0] ALU_Result,
    input wire [31:0] Rt_val,
    
    // Output
    output wire [31:0] Mem_Data
);
    DataMem DM (
        .Clk(clk),
        .MemW(MEMW),
        .MemR(MEMR),
        .Address(ALU_Result),
        .DataIn(Rt_val),
        .DataOut(Mem_Data)
    );
endmodule