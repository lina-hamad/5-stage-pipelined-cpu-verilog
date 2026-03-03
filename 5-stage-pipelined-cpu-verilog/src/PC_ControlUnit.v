// PC Control Unit - Predicated RISC 
module PC_CU (
    input  [31:0] currentPC,
    input  [31:0] Rs_val,      // value of Rs (for JR)
    input  [31:0] Rp_val,      // value of Rp
    input  [21:0] offset,      // J / CALL offset
    input  [1:0]  PC_sel,      // 00: normal, 01: J, 10: CALL, 11: JR
    output reg [31:0] NextPC
);

always @(*) begin
    // default: next instruction
    NextPC = currentPC + 1;

    // predication check
    if (Rp_val != 0) begin
        case (PC_sel)
            2'b00: NextPC = currentPC + 1;  // normal
            2'b01: NextPC = currentPC - 2 + {{10{offset[21]}}, offset}; // J PC-2 = PC_Decode
            2'b10: NextPC = currentPC -2 + {{10{offset[21]}}, offset}; // CALLPC-2 = PC_Decode
            2'b11: NextPC = Rs_val;                                 // JR  
            default: NextPC = currentPC + 1;
        endcase
    end
end

endmodule