module Split32 (Inst,Opcode,Rp,Rd,Rs,Rt,Imm12,Off22);
   input  [31:0] Inst;
    output [4:0]  Opcode;
    output [4:0]  Rp;
    output [4:0]  Rd;
    output [4:0]  Rs;
    output [4:0]  Rt;

    output [11:0] Imm12;
    output [21:0] Off22;

    assign Opcode = Inst[31:27];
    assign Rp     = Inst[26:22];

    // R-type 
    assign Rd     = Inst[21:17];
    assign Rs     = Inst[16:12];
    assign Rt     = Inst[11:7];

    // I-type immediate
    assign Imm12  = Inst[11:0];

    // J-type offset
    assign Off22  = Inst[21:0];

endmodule


module Split32_tb;
    reg [31:0] Inst;
    wire [4:0] Opcode;
    wire [4:0] Rp;
    wire [4:0] Rd;
    wire [4:0] Rs;
    wire [4:0] Rt;
    wire [11:0] Imm12;
    wire [21:0] Off22;
    
    // Instantiate the Split32 module
    Split32 uut (
        .Inst(Inst),
        .Opcode(Opcode),
        .Rp(Rp),
        .Rd(Rd),
        .Rs(Rs),
        .Rt(Rt),
        .Imm12(Imm12),
        .Off22(Off22)
    );
    
    initial begin
        $display("\n========== SPLIT32 INSTRUCTION DECODER TESTBENCH ==========\n");
        
        // Test 1: ADDI R1 R0 R0 2
        $display("Test 1: ADDI R1 R0 R0 2");
        Inst = 32'b00101_00001_00000_00000_000000000010;
        //        Opcode Rp    Rd    Rs    Imm12
        #5 $display("  Instruction: 0x%h", Inst);
        #5 $display("  Opcode: %d (ADDI=5) | Rp: %d (R1) | Rd: %d (R0) | Rs: %d (R0) | Imm12: 0x%h (2)", 
                    Opcode, Rp, Rd, Rs, Imm12);
        #5 $display("  Expected: Opcode=5, Rp=1, Rd=0, Rs=0, Imm12=0x002 | Status: %s\n", 
                    (Opcode==5 && Rp==1 && Rd==0 && Rs==0 && Imm12==12'h002) ? "PASS" : "FAIL");
        
        // Test 2: ADDI R1 R2 R0 5
        $display("Test 2: ADDI R1 R2 R0 5");
        Inst = 32'b00101_00001_00010_00000_000000000101;
        //        Opcode Rp    Rd    Rs    Imm12
        #5 $display("  Instruction: 0x%h", Inst);
        #5 $display("  Opcode: %d (ADDI=5) | Rp: %d (R1) | Rd: %d (R2) | Rs: %d (R0) | Imm12: 0x%h (5)", 
                    Opcode, Rp, Rd, Rs, Imm12);
        #5 $display("  Expected: Opcode=5, Rp=1, Rd=2, Rs=0, Imm12=0x005 | Status: %s\n", 
                    (Opcode==5 && Rp==1 && Rd==2 && Rs==0 && Imm12==12'h005) ? "PASS" : "FAIL");
        
        // Test 3: ADD R1 R7 R3 R4 (R-type)
        $display("Test 3: ADD R1 R7 R3 R4 (R-type)");
        Inst = 32'b00000_00001_00111_00011_00100_0000000;
        //        Opcode Rp    Rd    Rs    Rt
        #5 $display("  Instruction: 0x%h", Inst);
        #5 $display("  Opcode: %d (ADD=0) | Rp: %d (R1) | Rd: %d (R7) | Rs: %d (R3) | Rt: %d (R4)", 
                    Opcode, Rp, Rd, Rs, Rt);
        #5 $display("  Expected: Opcode=0, Rp=1, Rd=7, Rs=3, Rt=4 | Status: %s\n", 
                    (Opcode==0 && Rp==1 && Rd==7 && Rs==3 && Rt==4) ? "PASS" : "FAIL");
        
        // Test 4: SUB R1 R7 R7 R4 (R-type)
        $display("Test 4: SUB R1 R7 R7 R4 (R-type)");
        Inst = 32'b01000_00001_00111_00111_00100_0000000;
        //        Opcode Rp    Rd    Rs    Rt
        #5 $display("  Instruction: 0x%h", Inst);
        #5 $display("  Opcode: %d (SUB=8) | Rp: %d (R1) | Rd: %d (R7) | Rs: %d (R7) | Rt: %d (R4)", 
                    Opcode, Rp, Rd, Rs, Rt);
        #5 $display("  Expected: Opcode=8, Rp=1, Rd=7, Rs=7, Rt=4 | Status: %s\n", 
                    (Opcode==8 && Rp==1 && Rd==7 && Rs==7 && Rt==4) ? "PASS" : "FAIL");
        
        // Test 5: All zeros
        $display("Test 5: All Zeros Instruction");
        Inst = 32'h00000000;
        #5 $display("  Instruction: 0x%h", Inst);
        #5 $display("  Opcode: %d | Rp: %d | Rd: %d | Rs: %d | Rt: %d", 
                    Opcode, Rp, Rd, Rs, Rt);
        #5 $display("  Imm12: 0x%h | Off22: 0x%h | Status: %s\n", 
                    Imm12, Off22, (Opcode==0 && Rp==0 && Rd==0 && Rs==0 && Rt==0) ? "PASS" : "FAIL");
        
        // Test 6: All ones
        $display("Test 6: All Ones Instruction");
        Inst = 32'hFFFFFFFF;
        #5 $display("  Instruction: 0x%h", Inst);
        #5 $display("  Opcode: %d (Max) | Rp: %d (Max) | Rd: %d (Max) | Rs: %d (Max) | Rt: %d (Max)", 
                    Opcode, Rp, Rd, Rs, Rt);
        #5 $display("  Imm12: 0x%h (Max) | Off22: 0x%h (Max) | Status: %s\n", 
                    Imm12, Off22, (Opcode==31 && Rp==31 && Rd==31 && Rs==31 && Rt==31) ? "PASS" : "FAIL");
        
        // Test 7: J-type Jump instruction
        $display("Test 7: J-type Jump Instruction");
        Inst = 32'b00010_10101_1010101010101010101010;
        //        Opcode Rp    Off22
        #5 $display("  Instruction: 0x%h", Inst);
        #5 $display("  Opcode: %d (J=2) | Rp: %d | Off22: 0x%h (Jump offset)", 
                    Opcode, Rp, Off22);
        #5 $display("  Expected: Opcode=2, Rp=21, Off22=0x2AAAAA | Status: %s\n", 
                    (Opcode==2 && Rp==21 && Off22==22'h2AAAAA) ? "PASS" : "FAIL");
        
        // Test 8: Real instruction - 28400002 (ADDI R1 R0 R0 2)
        $display("Test 8: Real Instruction - 0x28400002");
        Inst = 32'h28400002;
        #5 $display("  Instruction: 0x%h", Inst);
        #5 $display("  Opcode: %d | Rp: %d | Rd: %d | Rs: %d | Imm12: 0x%h", 
                    Opcode, Rp, Rd, Rs, Imm12);
        #5 $display("  Status: %s\n", (Opcode==5 && Rp==1 && Rd==0 && Rs==0 && Imm12==12'h002) ? "PASS" : "FAIL");
        
        // Test 9: Real instruction - 28440005 (ADDI R1 R2 R0 5)
        $display("Test 9: Real Instruction - 0x28440005");
        Inst = 32'h28440005;
        #5 $display("  Instruction: 0x%h", Inst);
        #5 $display("  Opcode: %d | Rp: %d | Rd: %d | Rs: %d | Imm12: 0x%h", 
                    Opcode, Rp, Rd, Rs, Imm12);
        #5 $display("  Status: %s\n", (Opcode==5 && Rp==1 && Rd==2 && Rs==0 && Imm12==12'h005) ? "PASS" : "FAIL");
        
        // Test 10: Real instruction - 004e3200 (ADD R1 R7 R3 R4)
        $display("Test 10: Real Instruction - 0x004e3200");
        Inst = 32'h004e3200;
        #5 $display("  Instruction: 0x%h", Inst);
        #5 $display("  Opcode: %d | Rp: %d | Rd: %d | Rs: %d | Rt: %d", 
                    Opcode, Rp, Rd, Rs, Rt);
        #5 $display("  Status: %s\n", (Opcode==0 && Rp==1 && Rd==7 && Rs==3 && Rt==4) ? "PASS" : "FAIL");
        
        $display("========== TESTBENCH COMPLETE ==========\n");
        $stop;
    end
    
endmodule
