module InstMem (input [31:0] Address, output reg [31:0] instruction);
    parameter size = 1024;
    reg [31:0] IMem [0:size-1];
    wire in_range = (Address < size);

    initial $readmemh("instMem.dat", IMem);

    always @(*) begin
        if (in_range) instruction = IMem[Address];
        else instruction = 32'h00000000; // NOP
    end
endmodule
