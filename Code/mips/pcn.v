`include "defines.v"
module pcn(
    input wire clk,
    input wire rst,
    
    input wire branch_flag_i,
    input wire[`RegBus] branch_target_address_i,
    output  reg[`InstAddrBus] pcn,
    output reg ce
);

    always @ (posedge clk)
    begin
        if( rst == `RstEnable)
        begin
            ce <= `ChipDisable; // rst 指令存储器禁用
        end
        else
        begin
            ce <= `ChipEnable; // rst end，指令存储器使能
        end
    end

    always @ (posedge clk)
    begin
        if(ce == `ChipDisable)
        begin
            pcn <= 32'h0000_0000;
        end
        else
        begin
          if(branch_flag_i == `Branch)
            begin
              pcn <= branch_target_address_i;
            end
          else
            pcn <= pcn + 4'h4;
        end
    end


endmodule