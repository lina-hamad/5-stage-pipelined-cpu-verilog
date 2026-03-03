module IF_Stage (
    input wire clk,
    input wire reset,
    input wire stall,           // from Hazard Unit
    input wire [31:0] NextPC,   // from PC_CU
    
    output reg [31:0] PC,
    output wire [31:0] Instruction
);
    InstMem IMem (
        .Address(PC),
        .instruction(Instruction)
    );
    always @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 32'b0;
        else if (!stall)
            PC <= NextPC;
    end
endmodule