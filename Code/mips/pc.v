`include "defines.v"

module pc(
    input wire rst,
    input wire[`InstAddrBus] pc,
    input wire[`InstBus] inst,

    output reg[`InstAddrBus] id_pc,
    output reg[`InstBus] id_inst
);

    always @ (*)
    begin
      if(rst == `RstEnable)
      begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
      end
      else
      begin
        id_pc <= pc;
        id_inst <= inst;
      end
    end
endmodule