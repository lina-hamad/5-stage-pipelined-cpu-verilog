module WB_Stage (
   
    input wire WB,                    // select between ALU and Memory
    input wire [31:0] ALU_Result,
    input wire [31:0] Mem_Data,
	input wire [4:0] MEM_WB_Rd,
	input wire  MEM_WB_RegWE,
    
    output wire [31:0] WriteBack_Data,
    output wire [4:0] WB_WriteReg,
	output wire  WB_RegWrite,
);
	assign WriteBack_Data = WB ? Mem_Data : ALU_Result;
    assign WB_WriteReg = MEM_WB_Rd;
    assign WB_RegWrite = MEM_WB_RegWE;
	
	
endmodule				   																																																																																																																													