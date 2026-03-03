`timescale 1ns / 1ps

module regFile (
    input  wire        clk,
    input  wire        we,
    input  wire [4:0]  Rs, Rt, Rp, wa,
    input  wire [31:0] data_in,
    input  wire [31:0] pc_value,
    input  wire [31:0] return_addr,
    input  wire        update_r31,
    output wire [31:0] Rs_v, Rt_v, Rp_v
);
    reg [31:0] Registers [0:31];
    integer i;
    
    initial begin
        for (i = 0; i < 32; i = i + 1)
            Registers[i] = 32'h00000000;
        Registers[1] = 32'h00000001; // R1 = 1 for testing
    end
   
    always @(negedge clk) begin
        Registers[0] <= 32'h00000000;  // R0 always zero
        Registers[30] <= pc_value;      // R30 always PC
        
        if (update_r31) // R31 only updates on CALL
            Registers[31] <= return_addr -2;
        
        // Normal writes (but NOT to R0, R30, R31)
        if (we && wa != 5'd0 && wa != 5'd30 && wa != 5'd31)
            Registers[wa] <= data_in;
    end
    
    assign Rs_v = (Rs == 5'd30) ? pc_value : Registers[Rs];
    assign Rt_v = (Rt == 5'd30) ? pc_value : Registers[Rt];
    assign Rp_v = (Rp == 0)? 1:Registers[Rp];   
	
endmodule 		 

module regFile_tb;
    reg clk;
    reg we;
    reg [4:0] Rs, Rt, Rp, wa;
    reg [31:0] data_in;
    reg [31:0] pc_value;
    reg [31:0] return_addr;
    reg update_r31;
    wire [31:0] Rs_v, Rt_v, Rp_v;
    
    // Instantiate the Register File module
    regFile uut (
        .clk(clk),
        .we(we),
        .Rs(Rs),
        .Rt(Rt),
        .Rp(Rp),
        .wa(wa),
        .data_in(data_in),
        .pc_value(pc_value),
        .return_addr(return_addr),
        .update_r31(update_r31),
        .Rs_v(Rs_v),
        .Rt_v(Rt_v),
        .Rp_v(Rp_v)
    );
    
    // Clock generation
    always begin
        clk = 0;
        #10 clk = 1;
        #10 clk = 0;
    end
    
    initial begin
        $display("\n========== REGISTER FILE TESTBENCH ==========\n");
        
        // Initialize inputs
        we = 0;
        Rs = 5'b0;
        Rt = 5'b0;
        Rp = 5'b0;
        wa = 5'b0;
        data_in = 32'h00000000;
        pc_value = 32'h00000000;
        return_addr = 32'h00000000;
        update_r31 = 0;
        
        #20;
        
        // Test 1: Read initial values (R0 and R1)
        $display("Test 1: Read Initial Values");
        Rs = 5'd0; Rt = 5'd1; Rp = 5'd1;
        #5 $display("  R0 = %h (expected: 00000000), R1 = %h (expected: 00000001), Rp(R1) = %h", Rs_v, Rt_v, Rp_v);
        #15;
        
        // Test 2: Write to R2
        $display("\nTest 2: Write to R2");
        wa = 5'd2; data_in = 32'hDEADBEEF; we = 1;
        #20;
        we = 0;
        Rs = 5'd2;
        #5 $display("  Wrote 0xDEADBEEF to R2, Read back: %h (expected: DEADBEEF)", Rs_v);
        #15;
        
        // Test 3: Write to R3 and R4
        $display("\nTest 3: Write Multiple Registers");
        wa = 5'd3; data_in = 32'h12345678; we = 1;
        #20;
        we = 0;
        #20;
        wa = 5'd4; data_in = 32'hCAFEBABE; we = 1;
        #20;
        we = 0;
        Rs = 5'd3; Rt = 5'd4;
        #5 $display("  R3 = %h (expected: 12345678), R4 = %h (expected: CAFEBABE)", Rs_v, Rt_v);
        #20;
        
        // Test 4: Test R0 protection (should remain 0)
        $display("\nTest 4: R0 Protection (write should be ignored)");
        wa = 5'd0; data_in = 32'hFFFFFFFF; we = 1;
        #20;
        we = 0;
        Rs = 5'd0;
        #5 $display("  Attempted write to R0, Read back: %h (expected: 00000000)", Rs_v);
        #20;
        
        // Test 5: Test R30 (PC register)
        $display("\nTest 5: R30 (PC Register)");
        pc_value = 32'h00001000;
        #5 $display("  PC Value set to: %h", pc_value);
        Rs = 5'd30;
        #5 $display("  Read R30: %h (expected: 00001000 - direct from pc_value)", Rs_v);
        #15;
        
        // Test 6: Test R31 update (CALL return address)
        $display("\nTest 6: R31 Update (CALL - return address)");
        return_addr = 32'h00002000;
        update_r31 = 1;
        #20;
        update_r31 = 0;
        Rs = 5'd31;
        #5 $display("  Return address: %h, R31 = %h (expected: 00001FFE)", return_addr, Rs_v);
        #20;
        
        // Test 7: Test Rp register (special handling for R0)
        $display("\nTest 7: Rp Register (R0 should return 1)");
        Rp = 5'd0;
        #5 $display("  Rp(R0) = %h (expected: 00000001)", Rp_v);
        Rp = 5'd2;
        #5 $display("  Rp(R2) = %h (expected: DEADBEEF)", Rp_v);
        #15;
        
        // Test 8: Multiple read operations
        $display("\nTest 8: Multiple Simultaneous Reads");
        Rs = 5'd2; Rt = 5'd3; Rp = 5'd4;
        #5 $display("  Rs(R2) = %h, Rt(R3) = %h, Rp(R4) = %h", Rs_v, Rt_v, Rp_v);
        #15;
        
        // Test 9: Write to R5 and immediately read
        $display("\nTest 9: Write and Read Same Register");
        wa = 5'd5; data_in = 32'hABCDEF00; we = 1;
        #20;
        we = 0;
        Rs = 5'd5;
        #5 $display("  Wrote 0xABCDEF00 to R5, Read back: %h (expected: ABCDEF00)", Rs_v);
        #20;
        
        // Test 10: R30 protection (cannot write via wa)
        $display("\nTest 10: R30 Protection (write should be ignored)");
        wa = 5'd30; data_in = 32'hFFFFFFFF; we = 1;
        #20;
        we = 0;
        Rs = 5'd30; pc_value = 32'h00005000;
        #5 $display("  Attempted write to R30, Read back: %h (expected: 00005000 - from pc_value)", Rs_v);
        #20;
        
        $display("\n===========================================\n");
        $stop;
    end
    
endmodule