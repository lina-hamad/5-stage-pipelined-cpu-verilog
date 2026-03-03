module IF_ID_Buffer (
    input wire clk,
    input wire reset,
    input wire stall,      // from Hazard Unit
    input wire kill,       // flush signal
    
    // Inputs from IF stage
    input wire [31:0] PC_in,
    input wire [31:0] Instruction_in,
    
    // Outputs to ID stage
    output reg [31:0] PC_out,
    output reg [31:0] Instruction_out
);
    always @(posedge clk or posedge reset) begin
        if (reset || kill) begin
            PC_out <= 32'b0;
            Instruction_out <= 32'b0;  // NOP
        end
        else if (!stall) begin
            PC_out <= PC_in;
            Instruction_out <= Instruction_in;
        end
        // else hold current values (stall)
    end
endmodule