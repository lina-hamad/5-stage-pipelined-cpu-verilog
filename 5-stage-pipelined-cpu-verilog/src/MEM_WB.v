module MEM_WB_Buffer (
    input wire clk,
    input wire reset,
    
    // Control signals from MEM
    input wire WB_in,
    input wire RegWE_in,
    
    // Data from MEM
    input wire [31:0] ALU_Result_in,
    input wire [31:0] Mem_Data_in,
    input wire [4:0] Rd_in,
    
    // Control outputs to WB
    output reg WB_out,
    output reg RegWE_out,
    
    // Data outputs to WB
    output reg [31:0] ALU_Result_out,
    output reg [31:0] Mem_Data_out,
    output reg [4:0] Rd_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            WB_out <= 1'b0;
            RegWE_out <= 1'b0;
            ALU_Result_out <= 32'b0;
            Mem_Data_out <= 32'b0;
            Rd_out <= 5'b0;
        end
        else begin
            WB_out <= WB_in;
            RegWE_out <= RegWE_in;
            ALU_Result_out <= ALU_Result_in;
            Mem_Data_out <= Mem_Data_in;
            Rd_out <= Rd_in;
        end
    end
endmodule