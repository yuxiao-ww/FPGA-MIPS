`include "defines.v"
module mem(
    input wire rst,
    input wire[`RegAddrBus] wregaddr_i,
    input wire wregenb_i,
    input wire[`RegBus] wregdata_i,
    
    input wire[`AluOpBus] aluop_i,
    input wire[`RegBus] mem_wrdata_i,
    input wire[`RegBus] mem_addr_i,

    output reg[`RegAddrBus] wregaddr_o,
    output reg  wregenb_o,
    output reg[`RegBus] wregdata_o,
    
    
    //beta
    input wire[`RegBus] mem_data_i,

    output reg ior_ctl,
    output reg iow_ctl,
    output reg mw_ctl,
    output reg mr_ctl,
    
    output reg[`RegBus] mem_addr_o,
    output reg[`RegBus] mem_data_o
    
);
    assign zero32 = `ZeroWord;
        
    always @ (*)
    begin
        if(rst == `RstEnable)
        begin
            wregaddr_o <= `NOPRegAddr;
            wregenb_o <= `WriteDisable;
            wregdata_o <= `ZeroWord;
            mem_addr_o <= `ZeroWord;
            mem_data_o <= `ZeroWord;
            ior_ctl <= 1'b0;
            iow_ctl <= 1'b0;
            mw_ctl <= 1'b0; 
            mr_ctl <= 1'b0;
        end
        else
        begin
            wregaddr_o <= wregaddr_i;
            wregenb_o <= wregenb_i;
            wregdata_o <= wregdata_i;
            mem_addr_o <= `ZeroWord;
            mem_data_o <= `ZeroWord;
            ior_ctl <= 1'b0;
            iow_ctl <= 1'b0;
            mw_ctl <= 1'b0; 
            mr_ctl <= 1'b0;            
            case (aluop_i)
              `EXE_LW_OP: begin
                ior_ctl <= (((mem_addr_i & 32'hFFFF_F000) == 32'hFFFF_F000) ? 1'b1:1'b0);
                mr_ctl <= !ior_ctl;
                mem_addr_o <= mem_addr_i;
                wregdata_o <= mem_data_i;
              end
              `EXE_SW_OP: begin
                iow_ctl <= (((mem_addr_i & 32'hFFFF_F000) == 33'hFFFF_F000) ? 1'b1:1'b0);
                mw_ctl <= !iow_ctl;
                mem_addr_o <= mem_addr_i;
                mem_data_o  <=  mem_wrdata_i;
              end
            endcase
        end
    end

endmodule