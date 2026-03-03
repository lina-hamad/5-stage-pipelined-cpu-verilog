module EX_Stage (
    // Control signals
    input wire ALUSrc,
    input wire [2:0] ALUOP,
    
    // Data inputs

    input wire [31:0] Rs_val,
    input wire [31:0] Rt_val,
    input wire [31:0] Rp_val,         
    input wire [31:0] Imm_extended,
    
    // Forwarding inputs
    input wire [1:0] ForwardA,
    input wire [1:0] ForwardB,
    input wire [1:0] ForwardP,        
    input wire [31:0] EX_MEM_ALU_Result,
    input wire [31:0] MEM_Data,
    input wire [31:0] WB_Data,
    
    // Outputs
    output wire [31:0] ALU_Result,
    output wire ZeroFlag,

    output wire [31:0] ALU_A,
    output wire [31:0] ALU_B,
	
    output reg [31:0] Forwarded_A,
    output reg [31:0] Forwarded_B,
    output reg [31:0] Forwarded_P,     
);

    // Forwarding Mux for A (Rs)
    always @(*) begin
        case (ForwardA)
            2'b00: Forwarded_A = Rs_val;
            2'b01: Forwarded_A = EX_MEM_ALU_Result;
            2'b10: Forwarded_A = MEM_Data;
            2'b11: Forwarded_A = WB_Data;
            default: Forwarded_A = Rs_val;
        endcase
    end
    
    // Forwarding Mux for B (Rt)
    always @(*) begin
        case (ForwardB)
            2'b00: Forwarded_B = Rt_val;
            2'b01: Forwarded_B = EX_MEM_ALU_Result;
            2'b10: Forwarded_B = MEM_Data;
            2'b11: Forwarded_B = WB_Data;
            default: Forwarded_B = Rt_val;
        endcase
    end
    
    // Forwarding Mux for P (Rp)
    always @(*) begin
        case (ForwardP)
            2'b00: Forwarded_P = Rp_val;
            2'b01: Forwarded_P = EX_MEM_ALU_Result;
            2'b10: Forwarded_P = MEM_Data;
            2'b11: Forwarded_P = WB_Data;
            default: Forwarded_P = Rp_val;
        endcase
    end

    
    
    assign ALU_A = Forwarded_A;
    assign ALU_B = ALUSrc ? Imm_extended : Forwarded_B;


    ALU alu (
        .A(ALU_A),
        .B(ALU_B),
        .ALUOp(ALUOP),
        .Result(ALU_Result),
        .ZeroFlag(ZeroFlag)
    );
    
endmodule