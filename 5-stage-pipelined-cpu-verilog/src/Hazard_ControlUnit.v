module Hazard_CU(
    input        MEMR_EX,
    input [4:0]  OPCode,
    input [4:0]  rs_D,
    input [4:0]  rt_D,
	input [31:0] rp_val,
    input [4:0]  rd_EX,
    output reg   stallSignal,
    output reg   killSignal
);
    // load-use stall
    always @(*) begin
         
		if ((rp_val !=0) && MEMR_EX && (rd_EX != 0) && ((rd_EX == rs_D) || (rd_EX == rt_D)))
            stallSignal = 1'b1;
        else
            stallSignal = 1'b0;
    end

    // control hazard kill						  
    always @(*) begin
		if(rp_val !=0)begin
        killSignal = 1'b0;
            case (OPCode)
                5'd11, //J 
                5'd12, // CALL
                5'd13: // JR
                    killSignal = 1'b1;
                default: killSignal = 1'b0;
            endcase
		end
		else killSignal = 1'b0;
    end
endmodule	 

module Hazard_CU_tb;
    reg MEMR_EX;
    reg [4:0] OPCode;
    reg [4:0] rs_D;
    reg [4:0] rt_D;
    reg [31:0] rp_val;
    reg [4:0] rd_EX;
    wire stallSignal;
    wire killSignal;
    
    // Instantiate the Hazard Control Unit
    Hazard_CU uut (
        .MEMR_EX(MEMR_EX),
        .OPCode(OPCode),
        .rs_D(rs_D),
        .rt_D(rt_D),
        .rp_val(rp_val),
        .rd_EX(rd_EX),
        .stallSignal(stallSignal),
        .killSignal(killSignal)
    );
    
    initial begin
        $display("\n========== HAZARD CONTROL UNIT TESTBENCH ==========\n");
        $display("Test | MEMR_EX | OPCode | rs_D | rt_D | rp_val | rd_EX | Stall | Kill | Status");
        $display("-------------------------------------------------------------------------------");
        
        // Test 1: No hazard - rp_val = 0 (not a valid instruction path)
        $display("\nTest 1: No Hazard - rp_val = 0");
        MEMR_EX = 1'b0; OPCode = 5'd5; rs_D = 5'd1; rt_D = 5'd2; rp_val = 32'h00000000; rd_EX = 5'd3;
        #5 $display("  1   | %b       | %d     | %d    | %d    | 0x%h | %d     | %b     | %b    | %s", 
                    MEMR_EX, OPCode, rs_D, rt_D, rp_val, rd_EX, stallSignal, killSignal,
                    (stallSignal==1'b0 && killSignal==1'b0) ? "PASS" : "FAIL");
        #10;
        
        // Test 2: Load-use stall - MEMR_EX=1, rd_EX matches rs_D
        $display("\nTest 2: Load-Use Stall - MEMR_EX=1, rd_EX matches rs_D");
        MEMR_EX = 1'b1; OPCode = 5'd5; rs_D = 5'd5; rt_D = 5'd2; rp_val = 32'hFFFFFFFF; rd_EX = 5'd5;
        #5 $display("  2   | %b       | %d     | %d    | %d    | 0x%h | %d     | %b     | %b    | %s", 
                    MEMR_EX, OPCode, rs_D, rt_D, rp_val, rd_EX, stallSignal, killSignal,
                    (stallSignal==1'b1 && killSignal==1'b0) ? "PASS" : "FAIL");
        #10;
        
        // Test 3: Load-use stall - MEMR_EX=1, rd_EX matches rt_D
        $display("\nTest 3: Load-Use Stall - MEMR_EX=1, rd_EX matches rt_D");
        MEMR_EX = 1'b1; OPCode = 5'd5; rs_D = 5'd1; rt_D = 5'd6; rp_val = 32'h00000001; rd_EX = 5'd6;
        #5 $display("  3   | %b       | %d     | %d    | %d    | 0x%h | %d     | %b     | %b    | %s", 
                    MEMR_EX, OPCode, rs_D, rt_D, rp_val, rd_EX, stallSignal, killSignal,
                    (stallSignal==1'b1 && killSignal==1'b0) ? "PASS" : "FAIL");
        #10;
        
        // Test 4: Load-use stall - both rs_D and rt_D match rd_EX
        $display("\nTest 4: Load-Use Stall - Both rs_D and rt_D match rd_EX");
        MEMR_EX = 1'b1; OPCode = 5'd5; rs_D = 5'd7; rt_D = 5'd7; rp_val = 32'hAAAAAAAA; rd_EX = 5'd7;
        #5 $display("  4   | %b       | %d     | %d    | %d    | 0x%h | %d     | %b     | %b    | %s", 
                    MEMR_EX, OPCode, rs_D, rt_D, rp_val, rd_EX, stallSignal, killSignal,
                    (stallSignal==1'b1 && killSignal==1'b0) ? "PASS" : "FAIL");
        #10;
        
        // Test 5: No stall - MEMR_EX=0 (not a memory read)
        $display("\nTest 5: No Stall - MEMR_EX=0 (Not Memory Read)");
        MEMR_EX = 1'b0; OPCode = 5'd5; rs_D = 5'd8; rt_D = 5'd2; rp_val = 32'h12345678; rd_EX = 5'd8;
        #5 $display("  5   | %b       | %d     | %d    | %d    | 0x%h | %d     | %b     | %b    | %s", 
                    MEMR_EX, OPCode, rs_D, rt_D, rp_val, rd_EX, stallSignal, killSignal,
                    (stallSignal==1'b0 && killSignal==1'b0) ? "PASS" : "FAIL");
        #10;
        
        // Test 6: No stall - rd_EX = 0 (R0 cannot cause stall)
        $display("\nTest 6: No Stall - rd_EX = 0 (R0 Protected)");
        MEMR_EX = 1'b1; OPCode = 5'd5; rs_D = 5'd0; rt_D = 5'd2; rp_val = 32'hFFFFFFFF; rd_EX = 5'd0;
        #5 $display("  6   | %b       | %d     | %d    | %d    | 0x%h | %d     | %b     | %b    | %s", 
                    MEMR_EX, OPCode, rs_D, rt_D, rp_val, rd_EX, stallSignal, killSignal,
                    (stallSignal==1'b0 && killSignal==1'b0) ? "PASS" : "FAIL");
        #10;
        
        // Test 7: No stall - no register dependency
        $display("\nTest 7: No Stall - No Register Dependency");
        MEMR_EX = 1'b1; OPCode = 5'd5; rs_D = 5'd9; rt_D = 5'd10; rp_val = 32'h11111111; rd_EX = 5'd15;
        #5 $display("  7   | %b       | %d     | %d    | %d    | 0x%h | %d     | %b     | %b    | %s", 
                    MEMR_EX, OPCode, rs_D, rt_D, rp_val, rd_EX, stallSignal, killSignal,
                    (stallSignal==1'b0 && killSignal==1'b0) ? "PASS" : "FAIL");
        #10;
        
        // Test 8: Control Hazard - J instruction (OPCode=11)
        $display("\nTest 8: Control Hazard - J Instruction (OPCode=11)");
        MEMR_EX = 1'b0; OPCode = 5'd11; rs_D = 5'd1; rt_D = 5'd2; rp_val = 32'hFFFFFFFF; rd_EX = 5'd3;
        #5 $display("  8   | %b       | %d     | %d    | %d    | 0x%h | %d     | %b     | %b    | %s", 
                    MEMR_EX, OPCode, rs_D, rt_D, rp_val, rd_EX, stallSignal, killSignal,
                    (stallSignal==1'b0 && killSignal==1'b1) ? "PASS" : "FAIL");
        #10;
        
        // Test 9: Control Hazard - CALL instruction (OPCode=12)
        $display("\nTest 9: Control Hazard - CALL Instruction (OPCode=12)");
        MEMR_EX = 1'b0; OPCode = 5'd12; rs_D = 5'd1; rt_D = 5'd2; rp_val = 32'h12345678; rd_EX = 5'd3;
        #5 $display("  9   | %b       | %d     | %d    | %d    | 0x%h | %d     | %b     | %b    | %s", 
                    MEMR_EX, OPCode, rs_D, rt_D, rp_val, rd_EX, stallSignal, killSignal,
                    (stallSignal==1'b0 && killSignal==1'b1) ? "PASS" : "FAIL");
        #10;
        
        // Test 10: Control Hazard - JR instruction (OPCode=13)
        $display("\nTest 10: Control Hazard - JR Instruction (OPCode=13)");
        MEMR_EX = 1'b0; OPCode = 5'd13; rs_D = 5'd1; rt_D = 5'd2; rp_val = 32'hAAAAAAAA; rd_EX = 5'd3;
        #5 $display("  10  | %b       | %d     | %d    | %d    | 0x%h | %d     | %b     | %b    | %s", 
                    MEMR_EX, OPCode, rs_D, rt_D, rp_val, rd_EX, stallSignal, killSignal,
                    (stallSignal==1'b0 && killSignal==1'b1) ? "PASS" : "FAIL");
        #10;
        
        // Test 11: Non-control instruction (OPCode=5, ADDI)
        $display("\nTest 11: No Control Hazard - ADDI Instruction (OPCode=5)");
        MEMR_EX = 1'b0; OPCode = 5'd5; rs_D = 5'd1; rt_D = 5'd2; rp_val = 32'hFFFFFFFF; rd_EX = 5'd3;
        #5 $display("  11  | %b       | %d     | %d    | %d    | 0x%h | %d     | %b     | %b    | %s", 
                    MEMR_EX, OPCode, rs_D, rt_D, rp_val, rd_EX, stallSignal, killSignal,
                    (stallSignal==1'b0 && killSignal==1'b0) ? "PASS" : "FAIL");
        #10;
        
        // Test 12: Control Hazard with rp_val=0 (NOT kill)
        $display("\nTest 12: No Control Hazard - rp_val=0 Even for J Instruction");
        MEMR_EX = 1'b0; OPCode = 5'd11; rs_D = 5'd1; rt_D = 5'd2; rp_val = 32'h00000000; rd_EX = 5'd3;
        #5 $display("  12  | %b       | %d     | %d    | %d    | 0x%h | %d     | %b     | %b    | %s", 
                    MEMR_EX, OPCode, rs_D, rt_D, rp_val, rd_EX, stallSignal, killSignal,
                    (stallSignal==1'b0 && killSignal==1'b0) ? "PASS" : "FAIL");
        #10;
        
        // Test 13: Combined Hazards - Load-use AND Control (both signals active)
        $display("\nTest 13: Combined Hazards - Load-Use Stall + CALL Instruction");
        MEMR_EX = 1'b1; OPCode = 5'd12; rs_D = 5'd11; rt_D = 5'd2; rp_val = 32'h11111111; rd_EX = 5'd11;
        #5 $display("  13  | %b       | %d     | %d    | %d    | 0x%h | %d     | %b     | %b    | %s", 
                    MEMR_EX, OPCode, rs_D, rt_D, rp_val, rd_EX, stallSignal, killSignal,
                    (stallSignal==1'b1 && killSignal==1'b1) ? "PASS" : "FAIL");
        #10;
        
        // Test 14: Edge case - OPCode=14 (non-control)
        $display("\nTest 14: No Hazard - OPCode=14 (Not Control Instruction)");
        MEMR_EX = 1'b0; OPCode = 5'd14; rs_D = 5'd1; rt_D = 5'd2; rp_val = 32'hFFFFFFFF; rd_EX = 5'd3;
        #5 $display("  14  | %b       | %d     | %d    | %d    | 0x%h | %d     | %b     | %b    | %s", 
                    MEMR_EX, OPCode, rs_D, rt_D, rp_val, rd_EX, stallSignal, killSignal,
                    (stallSignal==1'b0 && killSignal==1'b0) ? "PASS" : "FAIL");
        #10;
        
        // Test 15: Memory read with rp_val=0 (not stall)
        $display("\nTest 15: No Stall - MEMR_EX=1 but rp_val=0");
        MEMR_EX = 1'b1; OPCode = 5'd5; rs_D = 5'd12; rt_D = 5'd2; rp_val = 32'h00000000; rd_EX = 5'd12;
        #5 $display("  15  | %b       | %d     | %d    | %d    | 0x%h | %d     | %b     | %b    | %s", 
                    MEMR_EX, OPCode, rs_D, rt_D, rp_val, rd_EX, stallSignal, killSignal,
                    (stallSignal==1'b0 && killSignal==1'b0) ? "PASS" : "FAIL");
        #10;
        
        $stop;
    end
    
endmodule