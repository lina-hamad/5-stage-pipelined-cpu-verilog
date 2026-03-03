`timescale 1ns / 1ps

module ALU (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [2:0]  ALUOp,
    output reg  [31:0] Result,
    output wire        ZeroFlag
);
    always @(*) begin
        case (ALUOp)
            3'b000: Result = A + B;
            3'b001: Result = A - B;
            3'b010: Result = A | B;
            3'b011: Result = ~(A | B);
            3'b100: Result = A & B;
            default: Result = 32'b0;
        endcase
    end
    assign ZeroFlag = (Result == 32'b0);
endmodule

module ALU_tb;
    reg [31:0] A, B;
    reg [2:0] ALUOp;
    wire [31:0] Result;
    wire ZeroFlag;
    
    // Instantiate the ALU module
    ALU uut (
        .A(A),
        .B(B),
        .ALUOp(ALUOp),
        .Result(Result),
        .ZeroFlag(ZeroFlag)
    );
    
    initial begin
        $display("\n========== ALU TESTBENCH ==========\n");
        
        // Test ADD (000)
        #5 A = 32'h0000000A; B = 32'h00000005; ALUOp = 3'b000;
        #5 $display("ADD: %h + %h = %h (ZeroF: %b)", A, B, Result, ZeroFlag);
        
        // Test SUB (001)
        #5 A = 32'h00000010; B = 32'h00000008; ALUOp = 3'b001;
        #5 $display("SUB: %h - %h = %h (ZeroF: %b)", A, B, Result, ZeroFlag);
        
        // Test OR (010)
        #5 A = 32'h0000000F; B = 32'h000000F0; ALUOp = 3'b010;
        #5 $display("OR:  %h | %h = %h (ZeroF: %b)", A, B, Result, ZeroFlag);
        
        // Test NOR (011)
        #5 A = 32'h00000000; B = 32'h00000000; ALUOp = 3'b011;
        #5 $display("NOR: ~(%h | %h) = %h (ZeroF: %b)", A, B, Result, ZeroFlag);
        
        // Test AND (100)
        #5 A = 32'hFFFFFFFF; B = 32'h0F0F0F0F; ALUOp = 3'b100;
        #5 $display("AND: %h & %h = %h (ZeroF: %b)", A, B, Result, ZeroFlag);
        
        // Test SUB with zero result (ZeroFlag = 1)
        #10 A = 32'h00000020; B = 32'h00000020; ALUOp = 3'b001;
        #5 $display("SUB: %h - %h = %h (ZeroF: %b) **ZeroFlag Test**", A, B, Result, ZeroFlag);
        
        // Test default case (invalid opcode)
        #10 A = 32'h12345678; B = 32'h87654321; ALUOp = 3'b111;
        #5 $display("DEF: Invalid opcode = %h (ZeroF: %b)", Result, ZeroFlag);
        
        // Test AND with all 1s
        #10 A = 32'hFFFFFFFF; B = 32'hFFFFFFFF; ALUOp = 3'b100;
        #5 $display("AND: %h & %h = %h (ZeroF: %b)", A, B, Result, ZeroFlag);
        
        $display("\n=================================\n");
        $stop;
    end
    
endmodule