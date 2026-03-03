
`timescale 1ns / 1ps

module Extender(sel,Imm,out);
  input sel;
  input [11:0] Imm;
  output reg [31:0] out;
  
  always @(*) begin	
    if(!sel) out = {20'b0,Imm};
    else out = {{20{Imm[11]}},Imm};
  end
  
endmodule

module Extender_tb;
    reg sel;
    reg [11:0] Imm;
    wire [31:0] out;
    
    // Instantiate the Extender module
    Extender uut (
        .sel(sel),
        .Imm(Imm),
        .out(out)
    );
    
    initial begin
        $display("\n========== EXTENDER TESTBENCH ==========\n");
        $display("Mode | Input (Imm)  | Output         | Expected       | Status");
        $display("=====================================================================");
        
        // Test 1: Zero-extend positive number
        #5 sel = 1'b0; Imm = 12'h0FF;
        #5 $display("ZERO |     0x%h     | 0x%h | 0x000000FF | %s", Imm, out, (out == 32'h000000FF) ? "PASS" : "FAIL");
        
        // Test 2: Zero-extend larger number
        #5 sel = 1'b0; Imm = 12'hABC;
        #5 $display("ZERO |     0x%h     | 0x%h | 0x00000ABC | %s", Imm, out, (out == 32'h00000ABC) ? "PASS" : "FAIL");
        
        // Test 3: Zero-extend max value
        #5 sel = 1'b0; Imm = 12'hFFF;
        #5 $display("ZERO |     0x%h     | 0x%h | 0x00000FFF | %s", Imm, out, (out == 32'h00000FFF) ? "PASS" : "FAIL");
        
        // Test 4: Zero-extend zero
        #5 sel = 1'b0; Imm = 12'h000;
        #5 $display("ZERO |     0x%h     | 0x%h | 0x00000000 | %s", Imm, out, (out == 32'h00000000) ? "PASS" : "FAIL");
        
        // Test 5: Sign-extend positive number (MSB=0)
        #5 sel = 1'b1; Imm = 12'h123;
        #5 $display("SIGN |     0x%h     | 0x%h | 0x00000123 | %s", Imm, out, (out == 32'h00000123) ? "PASS" : "FAIL");
        
        // Test 6: Sign-extend negative number (MSB=1)
        #5 sel = 1'b1; Imm = 12'h800;
        #5 $display("SIGN |     0x%h     | 0x%h | 0xFFFFF800 | %s", Imm, out, (out == 32'hFFFFF800) ? "PASS" : "FAIL");
        
        // Test 7: Sign-extend negative number (all 1s in MSB area)
        #5 sel = 1'b1; Imm = 12'hFFF;
        #5 $display("SIGN |     0x%h     | 0x%h | 0xFFFFFFFF | %s", Imm, out, (out == 32'hFFFFFFFF) ? "PASS" : "FAIL");
        
        // Test 8: Sign-extend with pattern
        #5 sel = 1'b1; Imm = 12'hF5A;
        #5 $display("SIGN |     0x%h     | 0x%h | 0xFFFFF5A | %s", Imm, out, (out == 32'hFFFFFF5A) ? "PASS" : "FAIL");
        
        // Test 9: Toggle from zero to sign extend (positive)
        #5 sel = 1'b0; Imm = 12'h555;
        #5 $display("ZERO |     0x%h     | 0x%h | 0x00000555 | %s", Imm, out, (out == 32'h00000555) ? "PASS" : "FAIL");
        #5 sel = 1'b1; Imm = 12'h555;
        #5 $display("SIGN |     0x%h     | 0x%h | 0x00000555 | %s", Imm, out, (out == 32'h00000555) ? "PASS" : "FAIL");
        
        // Test 10: Toggle from zero to sign extend (negative)
        #5 sel = 1'b0; Imm = 12'hAAA;
        #5 $display("ZERO |     0x%h     | 0x%h | 0x00000AAA | %s", Imm, out, (out == 32'h00000AAA) ? "PASS" : "FAIL");
        #5 sel = 1'b1; Imm = 12'hAAA;
        #5 $display("SIGN |     0x%h     | 0x%h | 0xFFFFFAAA | %s", Imm, out, (out == 32'hFFFFFAAA) ? "PASS" : "FAIL");
        
        $stop;
    end
    
endmodule