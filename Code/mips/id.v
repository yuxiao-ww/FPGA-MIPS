`include "defines.v"

module id(

	input wire										rst,
	input wire[`InstAddrBus]			pc_i,
	input wire[`InstBus]          inst_i,
	
	input wire[`RegBus]           reg1_data_i,
	input wire[`RegBus]           reg2_data_i,

	//reg data control
	output reg                    reg1_read_o,
	output reg                    reg2_read_o,     
	output reg[`RegAddrBus]       reg1_addr_o,
	output reg[`RegAddrBus]       reg2_addr_o, 	      
	
	//alu output
	output reg[`AluOpBus]         aluop_o,
	output reg[`AluSelBus]        alusel_o,
	output reg[`RegBus]           reg1_o,
	output reg[`RegBus]           reg2_o,
	output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o,
	
	output reg branch_flag_o,
	output reg[`RegBus] branch_target_address_o,
	output reg[`RegBus] link_addr_o,
	
	output wire[`RegBus] inst_o
);

  wire[5:0] op = inst_i[31:26];
  wire[4:0] op2 = inst_i[10:6];
  wire[5:0] op3 = inst_i[5:0];
  wire[4:0] op4 = inst_i[20:16];
  reg[`RegBus]	imm;
  reg instvalid;
  
  wire[`RegBus] imm_sll2_signedext;
  wire[`RegBus] pc_plus_8;
  wire[`RegBus] pc_plus_4;
  
  assign pc_plus_8 = pc_i + 8;
  assign pc_plus_4 = pc_i + 4;
  
  assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};
  
  assign inst_o = inst_i;
  
	always @ (*) begin	
		if (rst == `RstEnable) begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			instvalid <= `InstValid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			imm <= 32'h0;			
	  end else begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= inst_i[15:11];
			wreg_o <= `WriteDisable;
			instvalid <= `InstInvalid;	   
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[25:21];
			reg2_addr_o <= inst_i[20:16];		
			imm <= `ZeroWord;
			link_addr_o <= `ZeroWord;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;
			
		  case (op)
		    `EXE_SPECIAL_INST:		begin
		    	case (op2)
		    		5'b00000:			begin
		    			case (op3)
		    				`EXE_OR:	begin
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
		  						alusel_o <= `EXE_RES_LOGIC; 	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end  
		    				`EXE_AND:	begin
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_AND_OP;
		  						alusel_o <= `EXE_RES_LOGIC;	  reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
								end  	
		    				`EXE_XOR:	begin
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_XOR_OP;
		  						alusel_o <= `EXE_RES_LOGIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
								end  				
		    				`EXE_NOR:	begin
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_NOR_OP;
		  						alusel_o <= `EXE_RES_LOGIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
								end 
								`EXE_SLLV: begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLL_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end 
								`EXE_SRLV: begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRL_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end 					
								`EXE_SRAV: begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRA_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;			
		  						end			
								`EXE_SYNC: begin
									wreg_o <= `WriteDisable;		aluop_o <= `EXE_NOP_OP;
		  						alusel_o <= `EXE_RES_NOP;		reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
								
								`EXE_JR: begin
								  wreg_o <= `WriteDisable;  aluop_o <= `EXE_JR_OP;
								  alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;
								  reg2_read_o <= 1'b0;  link_addr_o <= `ZeroWord;
								  branch_target_address_o <= reg1_o;  branch_flag_o <= `Branch;
								  instvalid <= `InstValid;
								 end
												  									
						    default:	begin
						    end
						  endcase
						 end
						default: begin
						end
					endcase	
					end									  
		  	`EXE_ORI:			begin                        //ORIָÁî
		  		  wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
		  		  alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];
					instvalid <= `InstValid;	
		  	end
		  	`EXE_ANDI:			begin
		  		  wreg_o <= `WriteEnable;		aluop_o <= `EXE_AND_OP;
		  		  alusel_o <= `EXE_RES_LOGIC;	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end	 	
		  	`EXE_XORI:			begin
		  		  wreg_o <= `WriteEnable;		aluop_o <= `EXE_XOR_OP;
		  		  alusel_o <= `EXE_RES_LOGIC;	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end	 		
		  	`EXE_LUI:			begin
		  		  wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
		  		  alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {inst_i[15:0], 16'h0};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end		
				`EXE_PREF:			begin
		  		  wreg_o <= `WriteDisable;		aluop_o <= `EXE_NOP_OP;
		  		  alusel_o <= `EXE_RES_NOP; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;	  	  	
					instvalid <= `InstValid;	
				end
				`EXE_J: begin
					 wreg_o <= `WriteDisable;  aluop_o <= `EXE_J_OP;
           alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b0;
					 reg2_read_o <= 1'b0;  link_addr_o <= `ZeroWord;
					 branch_flag_o <= `Branch; instvalid <= `InstValid;
					 branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
				  end
        `EXE_JAL: begin
				    wreg_o <= `WriteEnable; aluop_o <= `EXE_JAL_OP;
						alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b0;
						reg2_read_o <= 1'b0; wd_o <= 5'b111_11;
						link_addr_o <= pc_plus_8; branch_flag_o <= `Branch;
						instvalid <= `InstValid; 
						branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b0};
					end
					`EXE_BEQ: begin
						wreg_o <= `WriteDisable;  aluop_o <= `EXE_BEQ_OP;
						alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;
						reg2_read_o <= 1'b1;  instvalid <= `InstValid;
						if(reg1_o == reg2_o) begin
						   branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
						   branch_flag_o <= `Branch;
						  end
						end
						`EXE_BNE: begin
						  wreg_o <= `WriteDisable; aluop_o <= `EXE_BLEZ_OP;
							alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;  instvalid <= `InstValid;
							if(reg1_o != reg2_o) begin
							   branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
							  	branch_flag_o <= `Branch;
							  end
							end
							
							`EXE_LW: begin
						    wreg_o <= `WriteEnable;  aluop_o <= `EXE_LW_OP;
						    alusel_o <= `EXE_RES_LOAD_STORE;  reg1_read_o <= 1'b1;
						    reg2_read_o <= 1'b0;  wd_o <= inst_i[20:16];
						    instvalid <= `InstValid;
						  end											  	
						  
						  `EXE_SW:  begin
						    wreg_o <= `WriteDisable; aluop_o <= `EXE_SW_OP;
						    reg1_read_o <= 1'b1;  reg2_read_o <= 1'b1;
						    instvalid <= `InstValid;  alusel_o <= `EXE_RES_LOAD_STORE;
						   end
		    default:			begin
		    end
		  endcase		  //case op
		  
		  if (inst_i[31:21] == 11'b00000000000) begin
		  	if (op3 == `EXE_SLL) begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLL_OP;
		  		alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;	
				end else if ( op3 == `EXE_SRL ) begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRL_OP;
		  		alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;	
				end else if ( op3 == `EXE_SRA ) begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRA_OP;
		  		alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;	
				end
			end		  
		  
		end       //if
	end         //always
	

	always @ (*) begin
		if(rst == `RstEnable) begin
			reg1_o <= `ZeroWord;		
	  end else if(reg1_read_o == 1'b1) begin
	  	reg1_o <= reg1_data_i;
	  end else if(reg1_read_o == 1'b0) begin
	  	reg1_o <= imm;
	  end else begin
	    reg1_o <= `ZeroWord;
	  end
	end
	
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
	  end else if(reg2_read_o == 1'b1) begin
	  	 reg2_o <= reg2_data_i;
	  end else if(reg2_read_o == 1'b0) begin
	  	reg2_o <= imm;
	  end else begin
	    reg2_o <= `ZeroWord;
	  end
	end

endmodule