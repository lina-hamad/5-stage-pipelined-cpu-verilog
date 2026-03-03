module DataMem (
    input  wire        Clk,
    input  wire        MemW,
    input  wire        MemR,
    input  wire [31:0] Address,
    input  wire [31:0] DataIn,
    output reg  [31:0] DataOut
);
    parameter size = 1024;          // was 64
    reg [31:0] Mem [0:size-1];

    wire in_range = (Address < size);

    initial $readmemh("DataMemory.dat", Mem);

    always @(*) begin
        if (MemR) begin
            if (in_range) DataOut = Mem[Address];
            else begin
                DataOut = 32'h00000000;
                $display("OUT OF RANGE READ: Address=%0d (max=%0d)", Address, size-1);
            end
        end else begin
            DataOut = 32'h00000000;
        end
    end

    always @(posedge Clk) begin
        if (MemW) begin
            if (in_range) begin 
				
				Mem[Address] <= DataIn;	
				 $display("Address=%0d (data in=%0d)", Address, DataIn);
				end
            else $display("OUT OF RANGE WRITE: Address=%0d (max=%0d)", Address, size-1);
        end
    end
endmodule						

`timescale 1ns/1ps

module DataMem_tb;

    reg         Clk;
    reg         MemW;
    reg         MemR;
    reg  [31:0] Address;
    reg  [31:0] DataIn;
    wire [31:0] DataOut;

    // DUT
    DataMem DUT (
        .Clk(Clk),
        .MemW(MemW),
        .MemR(MemR),
        .Address(Address),
        .DataIn(DataIn),
        .DataOut(DataOut)
    );

    integer i;

    // Clock generation
    initial begin
        Clk = 0;
        forever #5 Clk = ~Clk;   // 10ns period
    end

    initial begin
        // init
        MemW   = 0;
        MemR   = 0;
        Address = 0;
        DataIn  = 0;

        #10;

        $display("========================================");
        $display(" Reading first 19 values from DataMemory ");
        $display(" Address | DataOut ");
        $display("========================================");

        // Read first 19 memory locations
        MemR = 1;
        for (i = 0; i < 19; i = i + 1) begin
            Address = i;
            #10;   // wait for combinational read
            $display("   %2d    | 0x%08h", Address, DataOut);
        end

        MemR = 0;

        $display("========================================");
        $finish;
    end

endmodule
