`include "defines.v"

module openmips(
	input wire	clk,
	input wire	rst,
 
	input wire[`RegBus]           rom_data_i,
	output wire[`RegBus]           rom_addr_o,
	output wire                    rom_ce_o,
	
	input wire[`RegBus]  ram_data_i,
	output wire[`RegBus] ram_addr_o,
	output wire[`RegBus] ram_data_o,
	output wire  ram_we_o,
	output wire[3:0] ram_sel_o,
	output wire  ram_ce_o,
	
	input wire[`RegBus]  io_data_i,
	output wire[`RegBus] io_addr_o,
	output wire[`RegBus] io_data_o,
	output wire  io_we_o,
	output wire  io_ce_o
); 

	wire[`InstAddrBus] pc;
	wire[`InstAddrBus] id_pc_i;
	wire[`InstBus] id_inst_i;
	
	wire[`AluOpBus] id_aluop_o;
	wire[`AluSelBus] id_alusel_o;
	wire[`RegBus] id_reg1_o;
	wire[`RegBus] id_reg2_o;
	wire id_wreg_o;
	wire[`RegAddrBus] id_wd_o;
	
	wire[`AluOpBus] ex_aluop_i;
	wire[`AluSelBus] ex_alusel_i;
	wire[`RegBus] ex_reg1_i;
	wire[`RegBus] ex_reg2_i;
	wire ex_wreg_i;
	wire[`RegAddrBus] ex_wd_i;
	
	wire ex_wreg_o;
	wire[`RegAddrBus] ex_wd_o;
	wire[`RegBus] ex_wdata_o;

	wire mem_wreg_i;
	wire[`RegAddrBus] mem_wd_i;
	wire[`RegBus] mem_wdata_i;
	
	wire mem_wreg_o;
	wire[`RegAddrBus] mem_wd_o;
	wire[`RegBus] mem_wdata_o;
	
	wire wb_wreg_i;
	wire[`RegAddrBus] wb_wd_i;
	wire[`RegBus] wb_wdata_i;
	
  wire reg1_read;
  wire reg2_read;
  wire[`RegBus] reg1_data;
  wire[`RegBus] reg2_data;
  wire[`RegAddrBus] reg1_addr;
  wire[`RegAddrBus] reg2_addr;
  
  wire branch_i;
  wire[`RegBus] branch_addr_i;
  wire[`RegBus] link_addr_i;
  
  wire[`RegBus] id_inst_ex;
  
  wire[`AluOpBus] ex_aluop_mem;
  wire[`RegBus] ex_mem_addr_o_mem;
  wire[`RegBus] ex_reg2_o_mem;
  
  wire mio_c1;
  wire mio_c2;
  wire mio_c3;
  wire mio_c4;
 	wire[`RegBus] mio_data_w;
	wire[`RegBus] mio_addr_w;
	wire[`RegBus] mioc_m_data_w;
  
  assign rom_addr_o = pc;
	pcn pcn0(

		.clk(clk),
		.rst(rst),
		.branch_flag_i(branch_i),
		.branch_target_address_i(branch_addr_i),
		

		.pcn(pc),
		.ce(rom_ce_o)		
	);
	pc pc0(

		.rst(rst),
		.pc(pc),
		.inst(rom_data_i),

		.id_pc(id_pc_i),
		.id_inst(id_inst_i)      	
	);
	
	id id0(
	
		.rst(rst),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),


		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),

		.reg1_read_o(reg1_read),
		.reg2_read_o(reg2_read), 	  

		.reg1_addr_o(reg1_addr),
		.reg2_addr_o(reg2_addr), 

	  .branch_flag_o(branch_i),
	  .branch_target_address_o(branch_addr_i),
	  
	  .link_addr_o(link_addr_i),

		.aluop_o(id_aluop_o),
		.alusel_o(id_alusel_o),
		.reg1_o(id_reg1_o),
		.reg2_o(id_reg2_o),
		.wd_o(id_wd_o),
		.wreg_o(id_wreg_o),
		.inst_o(id_inst_ex)
	);

	regfile regfile1(
		.clk (clk),
		.rst (rst),
		
		.we	(wb_wreg_i),
		.waddr (wb_wd_i),
		.wdata (wb_wdata_i),
		
		.re1 (reg1_read),
		.raddr1 (reg1_addr),
		.rdata1 (reg1_data),
		
		.re2 (reg2_read),
		.raddr2 (reg2_addr),
		.rdata2 (reg2_data)
	);

		ex ex0(
		.rst(rst),
	 
		.aluop_i(id_aluop_o),
		.alusel_i(id_alusel_o),
		
		.reg1_i(id_reg1_o),
		.reg2_i(id_reg2_o),
		.wd_i(id_wd_o),
		.wreg_i(id_wreg_o),
		
		.link_address_i(link_addr_i),
		
		.inst_i(id_inst_ex),
	  
		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o),
		
		.aluop_o(ex_aluop_mem),
		
		.mem_addr_o(ex_mem_addr_o_mem),
		.reg2_o(ex_reg2_o_mem)
	);

	mem mem0(
		.rst(rst),
	
		.wregaddr_i(ex_wd_o),
		.wregenb_i(ex_wreg_o),
		.wregdata_i(ex_wdata_o),
		
		.aluop_i(ex_aluop_mem),
		.mem_addr_i(ex_mem_addr_o_mem),
		.mem_wrdata_i(ex_reg2_o_mem),
	  
		.wregaddr_o(wb_wd_i), 
		.wregenb_o(wb_wreg_i),
		.wregdata_o(wb_wdata_i),
		
		
		.mem_data_i(mioc_m_data_w), 
		.mem_addr_o(mio_addr_w),
		.mem_data_o(mio_data_w),
		
		.ior_ctl(mio_c1),
		.iow_ctl(mio_c2),
		.mw_ctl(mio_c3),
		.mr_ctl(mio_c4)
	);
	

	mioc mioc0(
	   .ior_ctl_i(mio_c1),
	   .iow_ctl_i(mio_c2),
	   .mw_ctl_i(mio_c3),
	   .mr_ctl_i(mio_c4),
	   
	   .wm_idata_i(mio_data_w),
	   .m_iaddr_i(mio_addr_w),
	   
	   .rmemdata_i(ram_data_i),
	   .wrmemdata_o(ram_data_o),
	   .memaddr_o(ram_addr_o),
	   .memwenb_o(ram_we_o),
	   .mem_ce(ram_ce_o),
	   .mem_sel_o(ram_sel_o),
	   
	   .wiodata_i(io_data_i),
	   .wiodata(io_data_o),
	   .iowenb_o(io_we_o),
	   .io_ce(io_ce_o),
	   .ioaddr(io_addr_o),
	   
	   .rm_idata(mioc_m_data_w)
	);
endmodule

