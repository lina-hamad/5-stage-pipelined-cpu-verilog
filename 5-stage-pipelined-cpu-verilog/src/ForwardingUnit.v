module Forwarding_Unit (
    input wire WE_MEM,          // RegWrite from EX/MEM stage
    input wire WE_WB,           // RegWrite from MEM/WB stage
    input wire [4:0] Rs,        // Source register 1 (from ID/EX)
    input wire [4:0] Rt,        // Source register 2 (from ID/EX)
    input wire [4:0] Rp,        // Source register 3 (from ID/EX) - NEW
    input wire [4:0] Rd_MEM,    // Destination register (from EX/MEM)
    input wire [4:0] Rd_WB,     // Destination register (from MEM/WB)
    output reg [1:0] ForwardA,  // Forwarding control for Rs
    output reg [1:0] ForwardB,  // Forwarding control for Rt
    output reg [1:0] ForwardP   // Forwarding control for Rp - NEW
);
    // ========================================================================
    // ForwardA Logic (for Rs)
    // ========================================================================
    always @(*) begin
        // Priority: MEM > WB > No forwarding
        if (WE_MEM && (Rd_MEM != 5'b0) && (Rd_MEM == Rs)) begin
            ForwardA = 2'b01;  // Forward from EX/MEM (ALU result)
        end
        else if (WE_WB && (Rd_WB != 5'b0) && (Rd_WB == Rs)) begin
            ForwardA = 2'b11;  // Forward from WB
        end
        else begin
            ForwardA = 2'b00;  // No forwarding
        end
    end
    
    // ========================================================================
    // ForwardB Logic (for Rt)
    // ========================================================================
    always @(*) begin
        // Priority: MEM > WB > No forwarding
        if (WE_MEM && (Rd_MEM != 5'b0) && (Rd_MEM == Rt)) begin
            ForwardB = 2'b01;  // Forward from EX/MEM (ALU result)
        end
        else if (WE_WB && (Rd_WB != 5'b0) && (Rd_WB == Rt)) begin
            ForwardB = 2'b11;  // Forward from WB
        end
        else begin
            ForwardB = 2'b00;  // No forwarding
        end
    end
    
    // ========================================================================
    // ForwardP Logic (for Rp) 
    // ========================================================================
    always @(*) begin
        // Priority: MEM > WB > No forwarding
        if (WE_MEM && (Rd_MEM != 5'b0) && (Rd_MEM == Rp)) begin
            ForwardP = 2'b01;  // Forward from EX/MEM (ALU result)
        end
        else if (WE_WB && (Rd_WB != 5'b0) && (Rd_WB == Rp)) begin
            ForwardP = 2'b11;  // Forward from WB
        end
        else begin
            ForwardP = 2'b00;  // No forwarding
        end
    end
endmodule		   

module Forwarding_Unit_tb;
    reg WE_MEM;
    reg WE_WB;
    reg [4:0] Rs;
    reg [4:0] Rt;
    reg [4:0] Rp;
    reg [4:0] Rd_MEM;
    reg [4:0] Rd_WB;
    wire [1:0] ForwardA;
    wire [1:0] ForwardB;
    wire [1:0] ForwardP;
    
    Forwarding_Unit uut (
        .WE_MEM(WE_MEM),
        .WE_WB(WE_WB),
        .Rs(Rs),
        .Rt(Rt),
        .Rp(Rp),
        .Rd_MEM(Rd_MEM),
        .Rd_WB(Rd_WB),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB),
        .ForwardP(ForwardP)
    );
    
    initial begin
        $display("\n========== FORWARDING UNIT TESTBENCH ==========\n");
        $display("WE_MEM | WE_WB | Rs | Rt | Rp | Rd_MEM | Rd_WB | ForwardA | ForwardB | ForwardP | Status");
        $display("------------------------------------------------------------------------------------------");
        
        // Test 1: No forwarding 
        $display("\nTest 1: No Forwarding - No Register Dependencies");
        WE_MEM = 1'b0; WE_WB = 1'b0; Rs = 5'd1; Rt = 5'd2; Rp = 5'd3; Rd_MEM = 5'd4; Rd_WB = 5'd5;
        #5 $display("  %b    | %b    | %d  | %d  | %d  | %d     | %d    | %b (00)   | %b (00)   | %b (00)   | %s", 
                    WE_MEM, WE_WB, Rs, Rt, Rp, Rd_MEM, Rd_WB, ForwardA, ForwardB, ForwardP,
                    (ForwardA==2'b00 && ForwardB==2'b00 && ForwardP==2'b00) ? "PASS" : "FAIL");
        #10;
        
        // Test 2: ForwardA from MEM (Rs matches Rd_MEM)
        $display("\nTest 2: ForwardA from MEM - Rs = Rd_MEM");
        WE_MEM = 1'b1; WE_WB = 1'b0; Rs = 5'd5; Rt = 5'd2; Rp = 5'd3; Rd_MEM = 5'd5; Rd_WB = 5'd4;
        #5 $display("  %b    | %b    | %d  | %d  | %d  | %d     | %d    | %b (01)   | %b (00)   | %b (00)   | %s", 
                    WE_MEM, WE_WB, Rs, Rt, Rp, Rd_MEM, Rd_WB, ForwardA, ForwardB, ForwardP,
                    (ForwardA==2'b01 && ForwardB==2'b00 && ForwardP==2'b00) ? "PASS" : "FAIL");
        #10;
        
        // Test 3: ForwardB from MEM (Rt matches Rd_MEM)
        $display("\nTest 3: ForwardB from MEM - Rt = Rd_MEM");
        WE_MEM = 1'b1; WE_WB = 1'b0; Rs = 5'd1; Rt = 5'd6; Rp = 5'd3; Rd_MEM = 5'd6; Rd_WB = 5'd4;
        #5 $display("  %b    | %b    | %d  | %d  | %d  | %d     | %d    | %b (00)   | %b (01)   | %b (00)   | %s", 
                    WE_MEM, WE_WB, Rs, Rt, Rp, Rd_MEM, Rd_WB, ForwardA, ForwardB, ForwardP,
                    (ForwardA==2'b00 && ForwardB==2'b01 && ForwardP==2'b00) ? "PASS" : "FAIL");
        #10;
        
        // Test 4: ForwardP from MEM (Rp matches Rd_MEM)
        $display("\nTest 4: ForwardP from MEM - Rp = Rd_MEM");
        WE_MEM = 1'b1; WE_WB = 1'b0; Rs = 5'd1; Rt = 5'd2; Rp = 5'd7; Rd_MEM = 5'd7; Rd_WB = 5'd4;
        #5 $display("  %b    | %b    | %d  | %d  | %d  | %d     | %d    | %b (00)   | %b (00)   | %b (01)   | %s", 
                    WE_MEM, WE_WB, Rs, Rt, Rp, Rd_MEM, Rd_WB, ForwardA, ForwardB, ForwardP,
                    (ForwardA==2'b00 && ForwardB==2'b00 && ForwardP==2'b01) ? "PASS" : "FAIL");
        #10;
        
        // Test 5: ForwardA from WB (Rs matches Rd_WB)
        $display("\nTest 5: ForwardA from WB - Rs = Rd_WB");
        WE_MEM = 1'b0; WE_WB = 1'b1; Rs = 5'd8; Rt = 5'd2; Rp = 5'd3; Rd_MEM = 5'd4; Rd_WB = 5'd8;
        #5 $display("  %b    | %b    | %d  | %d  | %d  | %d     | %d    | %b (11)   | %b (00)   | %b (00)   | %s", 
                    WE_MEM, WE_WB, Rs, Rt, Rp, Rd_MEM, Rd_WB, ForwardA, ForwardB, ForwardP,
                    (ForwardA==2'b11 && ForwardB==2'b00 && ForwardP==2'b00) ? "PASS" : "FAIL");
        #10;
        
        // Test 6: ForwardB from WB (Rt matches Rd_WB)
        $display("\nTest 6: ForwardB from WB - Rt = Rd_WB");
        WE_MEM = 1'b0; WE_WB = 1'b1; Rs = 5'd1; Rt = 5'd9; Rp = 5'd3; Rd_MEM = 5'd4; Rd_WB = 5'd9;
        #5 $display("  %b    | %b    | %d  | %d  | %d  | %d     | %d    | %b (00)   | %b (11)   | %b (00)   | %s", 
                    WE_MEM, WE_WB, Rs, Rt, Rp, Rd_MEM, Rd_WB, ForwardA, ForwardB, ForwardP,
                    (ForwardA==2'b00 && ForwardB==2'b11 && ForwardP==2'b00) ? "PASS" : "FAIL");
        #10;
        
        // Test 7: ForwardP from WB (Rp matches Rd_WB)
        $display("\nTest 7: ForwardP from WB - Rp = Rd_WB");
        WE_MEM = 1'b0; WE_WB = 1'b1; Rs = 5'd1; Rt = 5'd2; Rp = 5'd10; Rd_MEM = 5'd4; Rd_WB = 5'd10;
        #5 $display("  %b    | %b    | %d  | %d  | %d  | %d     | %d    | %b (00)   | %b (00)   | %b (11)   | %s", 
                    WE_MEM, WE_WB, Rs, Rt, Rp, Rd_MEM, Rd_WB, ForwardA, ForwardB, ForwardP,
                    (ForwardA==2'b00 && ForwardB==2'b00 && ForwardP==2'b11) ? "PASS" : "FAIL");
        #10;
        
        // Test 8: Priority Test - MEM over WB for ForwardA
        $display("\nTest 8: Priority Test - MEM > WB for Rs");
        WE_MEM = 1'b1; WE_WB = 1'b1; Rs = 5'd11; Rt = 5'd2; Rp = 5'd3; Rd_MEM = 5'd11; Rd_WB = 5'd11;
        #5 $display("  %b    | %b    | %d  | %d  | %d  | %d     | %d    | %b (01)   | %b (00)   | %b (00)   | %s", 
                    WE_MEM, WE_WB, Rs, Rt, Rp, Rd_MEM, Rd_WB, ForwardA, ForwardB, ForwardP,
                    (ForwardA==2'b01 && ForwardB==2'b00 && ForwardP==2'b00) ? "PASS" : "FAIL");
        #10;
        
        // Test 9: R0 Protection (Rd_MEM = R0, should not forward)
        $display("\nTest 9: R0 Protection - Rd_MEM = R0, Rs = R0");
        WE_MEM = 1'b1; WE_WB = 1'b0; Rs = 5'd0; Rt = 5'd2; Rp = 5'd3; Rd_MEM = 5'd0; Rd_WB = 5'd4;
        #5 $display("  %b    | %b    | %d  | %d  | %d  | %d     | %d    | %b (00)   | %b (00)   | %b (00)   | %s", 
                    WE_MEM, WE_WB, Rs, Rt, Rp, Rd_MEM, Rd_WB, ForwardA, ForwardB, ForwardP,
                    (ForwardA==2'b00 && ForwardB==2'b00 && ForwardP==2'b00) ? "PASS" : "FAIL");
        #10;
        
        // Test 10: Multiple Dependencies
        $display("\nTest 10: Multiple Dependencies - All three forward from MEM");
        WE_MEM = 1'b1; WE_WB = 1'b0; Rs = 5'd12; Rt = 5'd12; Rp = 5'd12; Rd_MEM = 5'd12; Rd_WB = 5'd4;
        #5 $display("  %b    | %b    | %d  | %d  | %d  | %d     | %d    | %b (01)   | %b (01)   | %b (01)   | %s", 
                    WE_MEM, WE_WB, Rs, Rt, Rp, Rd_MEM, Rd_WB, ForwardA, ForwardB, ForwardP,
                    (ForwardA==2'b01 && ForwardB==2'b01 && ForwardP==2'b01) ? "PASS" : "FAIL");
        #10;
        
        // Test 11: Mixed Dependencies
        $display("\nTest 11: Mixed Dependencies - Forward A from MEM, B from WB, P none");
        WE_MEM = 1'b1; WE_WB = 1'b1; Rs = 5'd13; Rt = 5'd14; Rp = 5'd15; Rd_MEM = 5'd13; Rd_WB = 5'd14;
        #5 $display("  %b    | %b    | %d  | %d  | %d  | %d     | %d    | %b (01)   | %b (11)   | %b (00)   | %s", 
                    WE_MEM, WE_WB, Rs, Rt, Rp, Rd_MEM, Rd_WB, ForwardA, ForwardB, ForwardP,
                    (ForwardA==2'b01 && ForwardB==2'b11 && ForwardP==2'b00) ? "PASS" : "FAIL");
        #10;
        
        // Test 12: WE_MEM disabled but Rd_MEM matches Rs
        $display("\nTest 12: WE_MEM=0 - No forward even if Rd_MEM matches Rs");
        WE_MEM = 1'b0; WE_WB = 1'b0; Rs = 5'd16; Rt = 5'd2; Rp = 5'd3; Rd_MEM = 5'd16; Rd_WB = 5'd4;
        #5 $display("  %b    | %b    | %d  | %d  | %d  | %d     | %d    | %b (00)   | %b (00)   | %b (00)   | %s", 
                    WE_MEM, WE_WB, Rs, Rt, Rp, Rd_MEM, Rd_WB, ForwardA, ForwardB, ForwardP,
                    (ForwardA==2'b00 && ForwardB==2'b00 && ForwardP==2'b00) ? "PASS" : "FAIL");
        #10;
        

        $stop;
    end
    
endmodule