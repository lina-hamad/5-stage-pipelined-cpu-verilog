module control_Unit (
    input  [4:0] OPCode,
	input [31:0] Instruction,
    input  [31:0] Rp_v, 
    output reg WB, MEMR, MEMW, ALUSrc, RegWE, 
    output reg RCall, Extender,	
    output reg [2:0] ALUOP,
    output reg [1:0] PC_sel
);

    // 32 instructions max (5-bit opcode)
    reg [11:0] ROM [0:31];

    initial begin
        $readmemh("SignalsFile.dat", ROM);
    end
	
	wire pred_ok = (Rp_v != 0);

    always @(*) begin 
		
		if(Instruction !=0 )begin
		WB        = ROM[OPCode][0];	
		MEMR      = ROM[OPCode][1];
		MEMW      = ROM[OPCode][2];
		ALUSrc    = ROM[OPCode][3];
		ALUOP     = ROM[OPCode][6:4];
		RegWE     = ROM[OPCode][7];	
		PC_sel    = ROM[OPCode][9:8];
		RCall     = ROM[OPCode][10];
		Extender  = ROM[OPCode][11];
		if (!pred_ok) begin
		 PC_sel = 2'b00;	 
		 RegWE = 1'b0; 
		 MEMR = 1'b0;
		 MEMW = 1'b0;
		end
	end
	else	
		{WB,MEMR ,MEMW,ALUSrc,ALUOP,RegWE,PC_sel,RCall,Extender} = 0;

  end
endmodule		  
