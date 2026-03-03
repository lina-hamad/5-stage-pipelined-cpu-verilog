module ID_Stage (
    input wire clk,
    input wire [31:0] PC_in,
    input wire [31:0] Instruction,
    
    // Write-back signals
    input wire WB_RegWE,
    input wire [4:0] WB_Rd,
    input wire [31:0] WB_Data,
    input wire [31:0] Return_Addr,
    input wire Update_R31,
    input wire Extender_sel,
    
    // Outputs - Data
    output wire [31:0] Rs_val,
    output wire [31:0] Rt_val,
    output wire [31:0] Rp_val,
    output wire [31:0] Imm_extended,
    output wire [4:0] Opcode,
    output wire [4:0] Rs,
    output wire [4:0] Rt,
    output wire [4:0] Rd,
    output wire [4:0] Rp,
    output wire [21:0] Offset
);
    wire [11:0] Imm12;
	wire [4:0] Rt_actual;
	assign Rt_actual = (Opcode == 5'd10) ? Rd : Rt;

    Split32 splitter (
        .Inst(Instruction),
        .Opcode(Opcode),
        .Rp(Rp),
        .Rd(Rd),
        .Rs(Rs),
        .Rt(Rt),
        .Imm12(Imm12),
        .Off22(Offset)
    );
    
    regFile RF (
        .clk(clk),
        .we(WB_RegWE),
        .Rs(Rs),
        .Rt(Rt_actual),
        .Rp(Rp),
        .wa(WB_Rd),
        .data_in(WB_Data),
        .pc_value(PC_in),
        .return_addr(Return_Addr),
        .update_r31(Update_R31),
        .Rs_v(Rs_val),
        .Rt_v(Rt_val),
        .Rp_v(Rp_val)
    );
    

    Extender ext (
        .sel(Extender_sel),
        .Imm(Imm12),
        .out(Imm_extended)
    );
endmodule