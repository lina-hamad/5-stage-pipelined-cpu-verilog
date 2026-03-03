module EX_MEM_Buffer (
    input wire clk,
    input wire reset,
    
    // Control signals from EX
    input wire WB_in,
    input wire MEMR_in,
    input wire MEMW_in,
    input wire RegWE_in,
    
    // Data from EX
    input wire [31:0] ALU_Result_in,
    input wire [31:0] Rt_val_in,      // for SW
    input wire [4:0] Rd_in,
    input wire [31:0] PC_in,
    
    // Control outputs to MEM
    output reg WB_out,
    output reg MEMR_out,
    output reg MEMW_out,
    output reg RegWE_out,
    
    // Data outputs to MEM
    output reg [31:0] ALU_Result_out,
    output reg [31:0] Rt_val_out,
    output reg [4:0] Rd_out,
);	   

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            WB_out <= 1'b0;
            MEMR_out <= 1'b0;
            MEMW_out <= 1'b0;
            RegWE_out <= 1'b0;
            ALU_Result_out <= 32'b0;
            Rt_val_out <= 32'b0;
            Rd_out <= 5'b0;

        end
        else begin
            WB_out <= WB_in;
            MEMR_out <= MEMR_in;
            MEMW_out <= MEMW_in;
            RegWE_out <= RegWE_in;
            ALU_Result_out <= ALU_Result_in;
            Rt_val_out <= Rt_val_in;
            Rd_out <= Rd_in;
        end
    end
endmodule
