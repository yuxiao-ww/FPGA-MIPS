`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:50:10 11/03/2014 
// Design Name: 
// Module Name:    Output_2_Disp 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module 	 Prep_IO(input  wire clk_100mhz,
	// I/O:
						input  wire[15:0]SW,
						output wire led_clk,
						output wire led_clrn,
						output wire led_sout,
						output wire LED_PEN,
				
						output wire seg_clk,
						output wire seg_clrn,
						output wire seg_sout,
						output wire SEG_PEN,
						output Buzzer
						);
				


	
wire[31:0]Div;
wire CK;

	wire[7:0] Seg0 = (SW[0]) ? 8'b00000011 : 8'hFE;
	wire[7:0] Seg1 = (SW[1]) ? 8'b10011111 : 8'hFE;
	wire[7:0] Seg2 = (SW[2]) ? 8'b00100101 : 8'hFE;
	wire[7:0] Seg3 = (SW[3]) ? 8'b00001101 : 8'hFE;
	wire[7:0] Seg4 = (SW[4]) ? 8'b10011001 : 8'hFE;
	wire[7:0] Seg5 = (SW[5]) ? 8'b01001001 : 8'hFE;
	wire[7:0] Seg6 = (SW[6]) ? 8'b01000001 : 8'hFE;
	wire[7:0] Seg7 = (SW[7]) ? 8'b00011111 : 8'hFE;
	
	wire[7:0] Seg8  = (SW[8])  ? 8'b00000001 : 8'hFE;
	wire[7:0] Seg9  = (SW[9 ]) ? 8'b00001001 : 8'hFE;
	wire[7:0] Seg10 = (SW[10]) ? 8'b00010001 : 8'hFE;
	wire[7:0] Seg11 = (SW[11]) ? 8'b11000001 : 8'hFE;
	wire[7:0] Seg12 = (SW[12]) ? 8'b01100011 : 8'hFE;
	wire[7:0] Seg13 = (SW[13]) ? 8'b10000101 : 8'hFE;
	wire[7:0] Seg14 = (SW[14]) ? 8'b01100001 : 8'hFE;
	wire[7:0] Seg15 = (SW[15]) ? 8'b01110001 : 8'hFE;
	
	wire[63:0] disp_data =(|SW[15:8]) ? {Seg8,Seg9,Seg10,Seg11,Seg12,Seg13,Seg14,Seg15} :
												   {Seg0,Seg1,Seg2,Seg3,Seg4,Seg5,Seg6,Seg7};
	wire [15:0] led;
	
	clk_div       U8(clk_100mhz,1'b0,SW[2],Div,CK);

	P2S 			  #(.DATA_BITS(64),.DATA_COUNT_BITS(6)) 
						  P7SEG (clk_100mhz,
									1'b0,
									Div[20],
									disp_data,
									seg_clk,
									seg_clrn,
									seg_sout,
									SEG_PEN
									);
									
									
	LED_P2S 			  #(.DATA_BITS(16),.DATA_COUNT_BITS(4)) 
					      PLED (clk_100mhz,
									1'b0,
									Div[20],
									led,
									led_clk,
									led_clrn,
									led_sout,
									LED_PEN
									);
	/*assign led = ~{SW[0],SW[1],SW[2],SW[3],SW[4],SW[5],SW[6],SW[7],
						SW[8],SW[9],SW[10],SW[11],SW[12],SW[13],SW[14],SW[15]};*/								
	assign Buzzer = 1;
	
	openmips_min_sopc   mips_soc1(
    .clk(clk_100mhz),
    .rst(SW[15]),
	 .led(led),
	 .sel(SW[1:0])
    );
	
endmodule





		


