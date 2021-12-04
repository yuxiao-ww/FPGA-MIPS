`include "defines.v"
module inst_rom(
	 input wire clk,
    input wire ce, //Enable Port
    input wire[`InstAddrBus] addr, //Input the addr that want to read
    output reg[`InstBus] inst //Output the inst in the readed addr.
);

    reg[`InstBus] inst_mem[0:`InstMemNum - 1];
    initial
    begin
        inst_mem[0] = 32'h3c01_ffff;
        inst_mem[1] = 32'h0080_2024;
        inst_mem[2] = 32'h0081_2025;
        inst_mem[3] = 32'h3421_f008;
        inst_mem[4] = 32'h3403_0010;
        inst_mem[5] = 32'h8c22_0000;
        inst_mem[6] = 32'h3484_f004;
        inst_mem[7] = 32'hac82_0000;
        inst_mem[8] = 32'h0060_0008;
      end

    always @ (*)
    begin
        if( ce == `ChipDisable )
        begin
            inst <= `ZeroWord;
        end
        else
        begin
            inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
        end
    end
endmodule