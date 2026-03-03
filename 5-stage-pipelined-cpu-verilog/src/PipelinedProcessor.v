`timescale 1ns/1ps
module Complete_Pipelined_Processor(
    input wire clk,
    input wire reset
);

// STAGE 1-IF    
    reg [31:0] PC;
    wire [31:0] NextPC;
    wire [31:0] IF_Instruction;
    wire stallSignal;  
																									  
	IF_Stage IFS(clk,reset,stallSignal,NextPC,PC,IF_Instruction); 

 // IF/ID PIPELINE BUFFER
    reg [31:0] IF_ID_PC;
    reg [31:0] IF_ID_Instruction;
    wire killSignal;
	
 IF_ID_Buffer Buf(clk,reset,stallSignal,killSignal,PC,inst,IF_ID_PC,IF_ID_Instruction);	
    
// STAGE 2-ID

    wire [4:0] ID_Opcode, ID_Rp, ID_Rd, ID_Rs, ID_Rt;
    wire [21:0] ID_Offset;
    
    // Register File Signals
    wire [31:0] ID_Rs_val, ID_Rt_val, ID_Rp_val;
    wire [31:0] WB_WriteData;
    wire [4:0] WB_WriteReg;
    wire WB_RegWrite;
    wire [31:0] Return_Address;
    wire EX_RCall;
    
    assign Return_Address = PC + 1 ;
    
    // Register File 
	 wire [4:0] ID_Rt_actual;
     assign ID_Rt_actual = (ID_Opcode == 10) ? ID_Rd : ID_Rt;
    
    // Rp Forwarding in ID Stage (for Control Unit)
	wire [31:0] ID_Rp_val_forwarded;
    wire [31:0] EX_ALU_Result;  // Forward declaration

	assign ID_Rp_val_forwarded = 
        (ID_EX_RegWE && ID_EX_Rd != 5'b0 && ID_EX_Rd == ID_Rp) ? EX_ALU_Result :
	    (EX_MEM_RegWE && EX_MEM_Rd != 5'b0 && EX_MEM_Rd == ID_Rp) ? EX_MEM_ALU_Result :
	    (WB_RegWrite && WB_WriteReg != 5'b0 && WB_WriteReg == ID_Rp) ? WB_WriteData :
	    ID_Rp_val;
	    
    // Control Signals
    wire ID_WB, ID_MEMR, ID_MEMW, ID_ALUSrc, ID_RegWE, ID_RCall, ID_Extender;
    wire [2:0] ID_ALUOP;
    wire [1:0] ID_PC_sel;

    // Immediate Extender
    wire [31:0] ID_Imm_extended;
	
	ID_Stage IDS(clk,IF_ID_PC,IF_ID_Instruction,WB_RegWrite,WB_WriteReg,WB_WriteData,Return_Address,EX_RCall,ID_Extender,ID_Rs_val,ID_Rt_val,ID_Rp_val,ID_Imm_extended ,ID_Opcode,
	ID_Rs,ID_Rt,ID_Rd,ID_Rp,ID_Offset);

	control_Unit CUU(
	    .OPCode(ID_Opcode),
		.Instruction(IF_ID_Instruction),
        .Rp_v(ID_Rp_val_forwarded),
        .WB(ID_WB),
        .MEMR(ID_MEMR),
        .MEMW(ID_MEMW),
        .ALUSrc(ID_ALUSrc),
        .RegWE(ID_RegWE),
        .RCall(ID_RCall),
        .Extender(ID_Extender),
        .ALUOP(ID_ALUOP),
        .PC_sel(ID_PC_sel)
    );
    
    // Hazard Detection Unit
    wire [4:0] EX_Rd;
    wire EX_MEMR;
    
    Hazard_CU hazard_detector (
        .MEMR_EX(EX_MEMR),
        .OPCode(ID_Opcode),
        .rs_D(ID_Rs),
        .rt_D(ID_Rt),
	    .rp_val(ID_Rp_val),
        .rd_EX(EX_Rd),
        .stallSignal(stallSignal),
        .killSignal(killSignal)
    );
 // ID/EX  BUFFER
    
    // Control Signals
    reg ID_EX_WB, ID_EX_MEMR, ID_EX_MEMW, ID_EX_ALUSrc, ID_EX_RegWE, ID_EX_RCall;
    reg [2:0] ID_EX_ALUOP;
    reg [1:0] ID_EX_PC_sel;
    
    // Data Signals
    reg [31:0] ID_EX_PC;
    reg [31:0] ID_EX_Rs_val, ID_EX_Rt_val, ID_EX_Rp_val;
    reg [31:0] ID_EX_Imm_extended;											 
    reg [21:0] ID_EX_Offset;
    reg [4:0] ID_EX_Rs, ID_EX_Rt, ID_EX_Rd, ID_EX_Rp;

 ID_EX_Buffer IDEXBuf(clk,reset,stallSignal,ID_WB,ID_MEMR,ID_MEMW,ID_ALUSrc,ID_RegWE,ID_RCall,ID_ALUOP,ID_PC_sel,
 IF_ID_PC,ID_Rs_val,ID_Rt_val,ID_Rp_val_forwarded,ID_Imm_extended,ID_Offset,ID_Rs,ID_Rt_actual,ID_Rd,ID_Rp,
 ID_EX_WB,ID_EX_MEMR,ID_EX_MEMW,ID_EX_ALUSrc,ID_EX_RegWE,ID_EX_RCall,ID_EX_ALUOP,ID_EX_PC_sel,ID_EX_PC,ID_EX_Rs_val,
 ID_EX_Rt_val,ID_EX_Rp_val,ID_EX_Imm_extended,ID_EX_Offset,ID_EX_Rs,ID_EX_Rt,ID_EX_Rd,ID_EX_Rp);
  
  reg kill2;
  always @(posedge clk or posedge reset) begin
        if (!reset) begin
		kill2 <= killSignal;	
		end
	 end
	 
    // Assign for hazard detection
    assign EX_Rd = ID_EX_Rd;
    assign EX_MEMR = ID_EX_MEMR;
    assign EX_RCall = ID_EX_RCall;
	reg [31:0]inst;
	always @(*)begin
		if(kill2)
			
		  inst <= 32'b0;  
		else
		  inst <= IF_Instruction;
		
		end
 
// STAGE 3: EXECUTE (EX)


// Forwarding Unit Control Signals
wire [1:0] ForwardA, ForwardB, ForwardP;

// Destination registers per pipeline stage
wire [4:0] Rd_EX_stage;
wire [4:0] Rd_MEM_stage;
wire [4:0] Rd_WB_stage;

assign Rd_EX_stage  = ID_EX_Rd;
assign Rd_MEM_stage = EX_MEM_Rd;
assign Rd_WB_stage  = MEM_WB_Rd;

// RegWrite enables per pipeline stage
wire WE_EX_stage;
wire WE_MEM_stage;
wire WE_WB_stage;

assign WE_EX_stage  = ID_EX_RegWE;
assign WE_MEM_stage = EX_MEM_RegWE;
assign WE_WB_stage  = MEM_WB_RegWE;

// Hazard detection signals (Rs, Rt, or Rp match)

wire hazard_MEM;
wire hazard_WB;


assign hazard_MEM =
    WE_MEM_stage &&
    (Rd_MEM_stage != 5'b0) &&
    (Rd_MEM_stage == ID_EX_Rs || Rd_MEM_stage == ID_EX_Rt || Rd_MEM_stage == ID_EX_Rp);

assign hazard_WB =
    WE_WB_stage &&
    (Rd_WB_stage != 5'b0) &&
    (Rd_WB_stage == ID_EX_Rs || Rd_WB_stage == ID_EX_Rt || Rd_WB_stage == ID_EX_Rp);

// Forwarding Unit
Forwarding_Unit forward_unit (
    .WE_MEM   (hazard_MEM),       
    .WE_WB    (hazard_WB),        
    .Rs       (ID_EX_Rs),
    .Rt       (ID_EX_Rt),
    .Rp       (ID_EX_Rp),
    .Rd_MEM   (Rd_MEM_stage),
    .Rd_WB    (Rd_WB_stage),
    .ForwardA (ForwardA),
    .ForwardB (ForwardB),
    .ForwardP (ForwardP)
); 

// Forwarding MUXes
reg [31:0] EX_Forwarded_A;
reg [31:0] EX_Forwarded_B;
reg [31:0] EX_Forwarded_P;

wire [31:0] EX_ALU_A;
wire [31:0] EX_ALU_B;
					   



wire [31:0] MEM_MemData; 
wire ZeroFlag;
EX_Stage EXS(ID_EX_ALUSrc,ID_EX_ALUOP,ID_EX_Rs_val,ID_EX_Rt_val,ID_EX_Rp_val,ID_EX_Imm_extended,ForwardA,ForwardB,ForwardP,
EX_MEM_ALU_Result, MEM_MemData,WB_WriteData,EX_ALU_Result,ZeroFlag,EX_ALU_A,EX_ALU_B,EX_Forwarded_A,EX_Forwarded_B,EX_Forwarded_P);


// PC Control Unit (jumps / calls)
PC_CU pc_control (
    .currentPC(PC),
    .Rs_val(EX_Forwarded_A),
    .Rp_val(EX_Forwarded_P),
    .offset(ID_EX_Offset),
    .PC_sel(ID_EX_PC_sel),
    .NextPC(NextPC)
);

// EX/MEM BUFFER
    
    // Control Signals
    reg EX_MEM_WB, EX_MEM_MEMR, EX_MEM_MEMW, EX_MEM_RegWE;
    
    // Data Signals
    reg [31:0] EX_MEM_ALU_Result;
    reg [31:0] EX_MEM_Rt_val;
    reg [4:0] EX_MEM_Rd;
 

EX_MEM_Buffer EXMEMBuf(clk,reset,ID_EX_WB, ID_EX_MEMR,ID_EX_MEMW,ID_EX_RegWE,EX_ALU_Result,EX_Forwarded_B,ID_EX_Rd,ID_EX_PC,
EX_MEM_WB,EX_MEM_MEMR,EX_MEM_MEMW,EX_MEM_RegWE,EX_MEM_ALU_Result,EX_MEM_Rt_val,EX_MEM_Rd);


	
    // Assign for forwarding
    assign MEM_ALU_Result = EX_MEM_ALU_Result;
    assign MEM_Rd = EX_MEM_Rd;
    assign MEM_RegWE = EX_MEM_RegWE;
    
// STAGE 4: MEMORY ACCESS (MEM)
	MEM_Stage MS(clk,EX_MEM_MEMR,EX_MEM_MEMW,EX_MEM_ALU_Result,EX_MEM_Rt_val,MEM_MemData);

    // MEM/WB BUFFER
    // Control Signals
    reg MEM_WB_WB, MEM_WB_RegWE;
    
    // Data Signals
    reg [31:0] MEM_WB_ALU_Result;
    reg [31:0] MEM_WB_MemData;
    reg [4:0] MEM_WB_Rd;

 MEM_WB_Buffer bb(clk,reset,EX_MEM_WB,EX_MEM_RegWE,EX_MEM_ALU_Result,MEM_MemData,EX_MEM_Rd,MEM_WB_WB,MEM_WB_RegWE,MEM_WB_ALU_Result,MEM_WB_MemData,MEM_WB_Rd);

// STAGE 5: WRITE BACK (WB)
	 WB_Stage WBS(MEM_WB_WB,MEM_WB_ALU_Result,MEM_WB_MemData,MEM_WB_Rd,MEM_WB_RegWE,WB_WriteData,WB_WriteReg,WB_RegWrite);		
	
    // Assign for forwarding
    assign WB_Rd = MEM_WB_Rd;  
	

// WB Stage (Write Back) 

// Monitor key signals during simulation
integer cycle;

// Initialize cycle counter
initial begin
    cycle = 0;
end

// Increment cycle on each clock edge (starts from 1 on first posedge)
always @(posedge clk) begin
    if (!reset) begin
        cycle = cycle + 1;
        
        $display("========================================================================================================================");
        $display("Time: %0t ns | Cycle: %0d", $time, cycle);
        $display("========================================================================================================================");
        
        // IF Stage
        $display("IF  Stage: PC=%0d | Inst=0x%08h", PC, IF_Instruction);
        
        // ID Stage - Generic Instruction Type Display
        $display("ID  Stage: PC=%0d | Inst=0x%08h", IF_ID_PC, IF_ID_Instruction);
        
        // Check for NOP conditions
        if (IF_ID_Instruction == 32'h00000000) begin
            // All zeros = NOP
            $display("           NOP (All zeros)");
        end
        else if (ID_Rp_val_forwarded == 5'b00000) begin
            // Rp = 0 = NOP
            $display("           NOP (Rp value = 0)");
        end
        // Determine instruction type based on opcode
        else if (ID_Opcode >= 0 && ID_Opcode <= 4 || ID_Opcode == 14) begin
            // R-Type Instructions (0-4, 14)
            $display("           Register Type (R-Type): Opcode=%0d, Rp=%0d, Rd=%0d, Rs=%0d, Rt=%0d, Unused=7bits", 
                      ID_Opcode, ID_Rp, ID_Rd, ID_Rs, ID_Rt);
        end
        else if (ID_Opcode >= 5 && ID_Opcode <= 11) begin
            // I-Type Instructions (5-11)
            $display("           Immediate Type (I-Type): Opcode=%0d, Rp=%0d, Rd=%0d, Rs=%0d, Immediate=%0d (0x%03h)", 
                      ID_Opcode, ID_Rp, ID_Rd, ID_Rs,    $signed(ID_Imm_extended), ID_Imm_extended);
        end
        else if (ID_Opcode == 12 || ID_Opcode == 13) begin
            // J-Type Instructions (12-13)
            $display("           Jump Type (J-Type): Opcode=%0d, Rp=%0d, Offset=%0d (0x%06h)", 
                      ID_Opcode, ID_Rp, $signed(ID_Offset), ID_Offset);
        end
        else begin
            $display("           UNKNOWN Type: Opcode=%0d", ID_Opcode);
        end
        
        // EX Stage
        $display("EX  Stage: ALU_Result=%0d | A=%0d, B=%0d | ALUOP=%0d | RegWE=%0b | Rd=R%0d", 
                 $signed(EX_ALU_Result), $signed(EX_ALU_A), $signed(EX_ALU_B), ID_EX_ALUOP, ID_EX_RegWE, ID_EX_Rd);
        
        // MEM Stage
        $display("MEM Stage: MEMR=%0b | MEMW=%0b | Addr=%0d | DataIn=%0d | DataOut=%0d | Rd=R%0d", 
                 EX_MEM_MEMR, EX_MEM_MEMW, $signed(EX_MEM_ALU_Result), $signed(EX_MEM_Rt_val), $signed(MEM_MemData), EX_MEM_Rd);
        
        // WB Stage
        if (WB_RegWrite && WB_WriteReg!=0)
            $display("WB  Stage: [WRITE] R%0d <= %0d | WE=%0b", 
                     WB_WriteReg, $signed(WB_WriteData), WB_RegWrite);
        else
            $display("WB  Stage: [NO WRITE]");
        
        $display("--------------------------------------------------------");
        $display("Control: Stall=%0b | Kill=%0b | Forward: A=%0d B=%0d P=%0d",
                 stallSignal, killSignal, ForwardA, ForwardB, ForwardP);
        $display("========================================================================================================================\n");
    end
end

endmodule	   
module Complete_Pipelined_Processor_TB;

    // Clock and Reset
    reg clk;
    reg reset;
    integer instr_completed;
    
    // Instantiate the Complete Processor
    Complete_Pipelined_Processor CPU (
        .clk(clk),
        .reset(reset)
    );
    
    // Clock Generation - 10ns period (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;
    
    
    // Display all registers
    task display_all_regs;
        integer i;
        begin
            $display("\n============================================");
            $display("       REGISTER FILE CONTENTS          ");
            $display("============================================");
            
            //  CPU -> IDS (ID_Stage) -> RF (regFile)
            $display("R0  = 0x%08h (%0d) | Always Zero", 
                     CPU.IDS.RF.Registers[0], CPU.IDS.RF.Registers[0]);
            $display("R30 = 0x%08h (%0d) | PC", 
                     CPU.IDS.RF.Registers[30], CPU.IDS.RF.Registers[30]);
            $display("R31 = 0x%08h (%0d) | Return Address", 
                     CPU.IDS.RF.Registers[31], CPU.IDS.RF.Registers[31]);
            $display("");
            
            for (i = 1; i < 30; i = i + 1) begin
                $display("R%-2d = 0x%08h (%0d)",
                         i, CPU.IDS.RF.Registers[i], 
                         $signed(CPU.IDS.RF.Registers[i]));
            end
        end
    endtask
    
    // Display memory contents
    task display_memory;
        integer i;
        integer count;
        begin
            $display("\n============================================");
            $display("       DATA MEMORY CONTENTS              ");
            $display("============================================");
            
            count = 0;
            //  CPU -> MS (MEM_Stage) -> DM (DataMem)
            for (i = 0; i < 32; i = i + 1) begin
                if (CPU.MS.DM.Mem[i] != 0) begin
                    $display("Mem[%0d] = 0x%08h (%0d)", 
                             i, CPU.MS.DM.Mem[i], CPU.MS.DM.Mem[i]);
                    count = count + 1;
                end
            end
            
            if (count == 0)
                $display("(All memory locations are zero)");
            else
                $display("\nTotal non-zero locations: %0d", count);
        end
    endtask
    
    // Display instruction memory
    task display_instructions;
        integer i;
        begin
            $display("\n============================================");
            $display("  INSTRUCTION MEMORY (First 20)       ");
            $display("============================================");
            
            // CPU -> IFS (IF_Stage) -> IMem (InstMem)
            for (i = 0; i < 20; i = i + 1) begin
                if (CPU.IFS.IMem.IMem[i] != 0)
                    $display("Inst[%0d] = 0x%08h", i, CPU.IFS.IMem.IMem[i]);
            end
        end
    endtask
    
    // Display performance statistics
    task display_performance;
        real cpi;
        begin
            $display("\n============================================");
            $display("     PERFORMANCE STATISTICS             ");
            $display("============================================");
            $display("Total Cycles:              %0d", CPU.cycle);
            $display("Final PC:                  %0d", CPU.PC);
            $display("Instructions Completed:    ~%0d", instr_completed);
            
            if (instr_completed > 0) begin
                cpi = CPU.cycle / (instr_completed * 1.0);
                $display("Estimated CPI:             %.2f", cpi);
            end
        end
    endtask
    
    // Instruction Counter - Track completed instructions
  
    always @(posedge clk) begin
        if (!reset && !CPU.stallSignal && !CPU.killSignal) begin
           
                instr_completed = instr_completed + 1;
            
        end
    end
    
    // MAIN TEST SEQUENCE
    
    initial begin

        // Initialize counters
        instr_completed = 0;
        
        // Display header
        $display("\n");
        $display("========================================================");
        $display("  5-STAGE PIPELINED RISC PROCESSOR TESTBENCH   ");
        $display("========================================================");
        $display("\n");
        
        // Show loaded instructions
        display_instructions();
        
        // Reset sequence
        $display("\n[%0t ns] Asserting RESET...", $time);
        reset = 1;
        #30; // 3 clock cycles
        reset = 0;
        $display("[%0t ns] RESET Released - Starting Execution", $time);
        $display("\n");
        
        // Run processor for specified cycles
        $display(">>> Processor Running...\n");
        #1000; // 100 cycles
        
        // Display final results
        $display("\n");
        $display("========================================================");
        $display("              FINAL REPORT                            ");
        $display("========================================================");
        
        display_all_regs();
        display_memory();
        display_performance();
        
        // Final message
        $display("\n");
        $display("========================================================");
        $display("           SIMULATION COMPLETE                        ");
        $display("========================================================");
        $display("\n");
        $display("Waveform saved to: complete_processor_waves.vcd");
        $display("View with: gtkwave complete_processor_waves.vcd");
        $display("\n");
        
        $finish;
    end
    
  
    initial begin
        #10000;
        $display("\n========================================================");
        $display("            SIMULATION TIMEOUT                    ");
        $display("========================================================\n");
        $finish;
    end

endmodule