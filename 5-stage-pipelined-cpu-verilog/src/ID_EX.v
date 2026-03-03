module ID_EX_Buffer (
    input wire clk,
    input wire reset,
    input wire kill,
    
    // Control signals from ID
    input wire WB_in,
    input wire MEMR_in,
    input wire MEMW_in,
    input wire ALUSrc_in,
    input wire RegWE_in,
    input wire RCall_in,
    input wire [2:0] ALUOP_in,
    input wire [1:0] PC_sel_in,
    
    // Data from ID
    input wire [31:0] PC_in,
    input wire [31:0] Rs_val_in,
    input wire [31:0] Rt_val_in,
    input wire [31:0] Rp_val_in,
    input wire [31:0] Imm_extended_in,
    input wire [21:0] Offset_in,
    input wire [4:0] Rs_in,
    input wire [4:0] Rt_in,
    input wire [4:0] Rd_in,
    input wire [4:0] Rp_in,
    
    // Control outputs to EX
    output reg WB_out,
    output reg MEMR_out,
    output reg MEMW_out,
    output reg ALUSrc_out,
    output reg RegWE_out,
    output reg RCall_out,
    output reg [2:0] ALUOP_out,
    output reg [1:0] PC_sel_out,
    
    // Data outputs to EX
    output reg [31:0] PC_out,
    output reg [31:0] Rs_val_out,
    output reg [31:0] Rt_val_out,
    output reg [31:0] Rp_val_out,
    output reg [31:0] Imm_extended_out,
    output reg [21:0] Offset_out,
    output reg [4:0] Rs_out,
    output reg [4:0] Rt_out,
    output reg [4:0] Rd_out,
    output reg [4:0] Rp_out
);	
   always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset
            WB_out <= 1'b0;
            MEMR_out <= 1'b0;
            MEMW_out <= 1'b0;
            ALUSrc_out <= 1'b0;
            RegWE_out <= 1'b0;
            RCall_out <= 1'b0;
            ALUOP_out <= 3'b0;
            PC_sel_out <= 2'b0;
            PC_out <= 32'b0;
            Rs_val_out <= 32'b0;
            Rt_val_out <= 32'b0;
            Rp_val_out <= 32'b0;
            Imm_extended_out <= 32'b0;
            Offset_out <= 22'b0;
            Rs_out <= 5'b0;
            Rt_out <= 5'b0;
            Rd_out <= 5'b0;
            Rp_out <= 5'b0;
        end
        else if (kill) begin
            // Stall

            WB_out <= 1'b0;
            MEMR_out <= 1'b0;
            MEMW_out <= 1'b0;
            ALUSrc_out <= 1'b0;
            RegWE_out <= 1'b0;  
            RCall_out <= 1'b0;
            ALUOP_out <= 3'b0;
            PC_sel_out <= 2'b0;

            Rs_val_out <= 32'b0;
            Rt_val_out <= 32'b0;
            Rp_val_out <= 32'b0;
            Imm_extended_out <= 32'b0;
            Offset_out <= 22'b0;
            Rs_out <= 5'b0;
            Rt_out <= 5'b0;
            Rd_out <= 5'b0;
            Rp_out <= 5'b0;
        end
        else begin
            
            WB_out <= WB_in;
            MEMR_out <= MEMR_in;
            MEMW_out <= MEMW_in;
            ALUSrc_out <= ALUSrc_in;
            RegWE_out <= RegWE_in;
            RCall_out <= RCall_in;
            ALUOP_out <= ALUOP_in;
            PC_sel_out <= PC_sel_in;
            PC_out <= PC_in;
            Rs_val_out <= Rs_val_in;
            Rt_val_out <= Rt_val_in;
            Rp_val_out <= Rp_val_in;
            Imm_extended_out <= Imm_extended_in;
            Offset_out <= Offset_in;
            Rs_out <= Rs_in;
            Rt_out <= Rt_in;
            Rd_out <= Rd_in;
            Rp_out <= Rp_in;
        end
    end
endmodule