// --------------------------------------------------------------------
// Copyright (c) 2005 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	VGA DLA simulator
// modifed by BRL4 for SRAM; Displays a color grid 
// 320/240, 12 bit color
// VGA controller, PLL, and reset are from DE2 distribution CD
// --------------------------------------------------------------------

/*
	Edits: 
	Skyler Schneider (2010): Wrote improved VGA_Controller module. Also added in the 'color_walker' register to add color to VGA output display.
	Quinton Mincy (2023): Updated pin assignments to be compatable with Cyclone IV board.

*/

module DE2_Default
	(
		////////////////////	Clock Input	 	////////////////////	 
		TD_CLK27,						//	27 MHz
		CLOCK_50,						//	50 MHz
		SMA_CLKIN,						//	External Clock
		////////////////////	Push Button		////////////////////
		KEY,							//	Pushbutton[3:0]
		////////////////////	DPDT Switch		////////////////////
		SW,								//	Toggle Switch[17:0]
		////////////////////	7-SEG Dispaly	////////////////////
		HEX0,							//	Seven Segment Digit 0
		HEX1,							//	Seven Segment Digit 1
		HEX2,							//	Seven Segment Digit 2
		HEX3,							//	Seven Segment Digit 3
		HEX4,							//	Seven Segment Digit 4
		HEX5,							//	Seven Segment Digit 5
		HEX6,							//	Seven Segment Digit 6
		HEX7,							//	Seven Segment Digit 7
		////////////////////////	LED		////////////////////////
		LEDG,							//	LED Green[8:0]
		LEDR,							//	LED Red[17:0]
		////////////////////////	UART	////////////////////////
		UART_TXD,						//	UART Transmitter
		UART_RXD,						//	UART Receiver
		////////////////////////	IRDA	////////////////////////
		//IRDA_TXD,						//	IRDA Transmitter
		IRDA_RXD,						//	IRDA Receiver
		/////////////////////	SDRAM Interface		////////////////
		DRAM_DQ,						//	SDRAM Data bus 16 Bits
		DRAM_ADDR,						//	SDRAM Address bus 12 Bits
		DRAM_LDQM,						//	SDRAM Low-byte Data Mask 
		DRAM_UDQM,						//	SDRAM High-byte Data Mask
		DRAM_WE_N,						//	SDRAM Write Enable
		DRAM_CAS_N,						//	SDRAM Column Address Strobe
		DRAM_RAS_N,						//	SDRAM Row Address Strobe
		DRAM_CS_N,						//	SDRAM Chip Select
		DRAM_BA,						//	SDRAM Bank Address 0
		DRAM_CLK,						//	SDRAM Clock
		DRAM_CKE,						//	SDRAM Clock Enable
		////////////////////	Flash Interface		////////////////
		FL_DQ,							//	FLASH Data bus 8 Bits
		FL_ADDR,						//	FLASH Address bus 22 Bits
		FL_WE_N,						//	FLASH Write Enable
		FL_RST_N,						//	FLASH Reset
		FL_OE_N,						//	FLASH Output Enable
		FL_CE_N,						//	FLASH Chip Enable
		////////////////////	SRAM Interface		////////////////
		SRAM_DQ,						//	SRAM Data bus 16 Bits
		SRAM_ADDR,						//	SRAM Address bus 18 Bits
		SRAM_UB_N,						//	SRAM High-byte Data Mask 
		SRAM_LB_N,						//	SRAM Low-byte Data Mask 
		SRAM_WE_N,						//	SRAM Write Enable
		SRAM_CE_N,						//	SRAM Chip Enable
		SRAM_OE_N,						//	SRAM Output Enable
		////////////////////	ISP1362 Interface	////////////////
		OTG_DATA,						//	ISP1362 Data bus 16 Bits
		OTG_ADDR,						//	ISP1362 Address 2 Bits
		OTG_CS_N,						//	ISP1362 Chip Select
		OTG_RD_N,						//	ISP1362 Write
		OTG_WR_N,						//	ISP1362 Read
		OTG_RST_N,						//	ISP1362 Reset
		OTG_FSPEED,						//	USB Full Speed,	0 = Enable, Z = Disable
		OTG_LSPEED,						//	USB Low Speed, 	0 = Enable, Z = Disable
		OTG_INT0,						//	ISP1362 Interrupt 0
		OTG_INT1,						//	ISP1362 Interrupt 1
		OTG_DREQ0,						//	ISP1362 DMA Request 0
		OTG_DREQ1,						//	ISP1362 DMA Request 1
		OTG_DACK0_N,					//	ISP1362 DMA Acknowledge 0
		OTG_DACK1_N,					//	ISP1362 DMA Acknowledge 1
		////////////////////	LCD Module 16X2		////////////////
		LCD_ON,							//	LCD Power ON/OFF
		LCD_BLON,						//	LCD Back Light ON/OFF
		LCD_RW,							//	LCD Read/Write Select, 0 = Write, 1 = Read
		LCD_EN,							//	LCD Enable
		LCD_RS,							//	LCD Command/Data Select, 0 = Command, 1 = Data
		LCD_DATA,						//	LCD Data bus 8 bits
		////////////////////	SD_Card Interface	////////////////
		SD_DAT,							//	SD Card Data
		SD_DAT3,						//	SD Card Data 3
		SD_CMD,							//	SD Card Command Signal
		SD_CLK,							//	SD Card Clock
		////////////////////	USB JTAG link	////////////////////
		TDI,  							// CPLD -> FPGA (data in)
		TCK,  							// CPLD -> FPGA (clk)
		TCS,  							// CPLD -> FPGA (CS)
	    TDO,  							// FPGA -> CPLD (data out)
		////////////////////	I2C		////////////////////////////
		I2C_SDAT,						//	I2C Data
		I2C_SCLK,						//	I2C Clock
		////////////////////	PS2		////////////////////////////
		PS2_DAT,						//	PS2 Data
		PS2_CLK,						//	PS2 Clock
		////////////////////	VGA		////////////////////////////
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,  						//	VGA Blue[9:0]
		////////////	Ethernet Interface	////////////////////////
		ENET_DATA,						//	DM9000A DATA bus 16Bits
		ENET_CMD,						//	DM9000A Command/Data Select, 0 = Command, 1 = Data
		ENET_CS_N,						//	DM9000A Chip Select
		ENET_WR_N,						//	DM9000A Write
		ENET_RD_N,						//	DM9000A Read
		ENET_RST_N,						//	DM9000A Reset
		ENET_INT,						//	DM9000A Interrupt
		ENET_CLK,						//	DM9000A Clock 25 MHz
		////////////////	Audio CODEC		////////////////////////
		AUD_ADCLRCK,					//	Audio CODEC ADC LR Clock
		AUD_ADCDAT,						//	Audio CODEC ADC Data
		AUD_DACLRCK,					//	Audio CODEC DAC LR Clock
		AUD_DACDAT,						//	Audio CODEC DAC Data
		AUD_BCLK,						//	Audio CODEC Bit-Stream Clock
		AUD_XCK,						//	Audio CODEC Chip Clock
		////////////////	TV Decoder		////////////////////////
		TD_DATA,    					//	TV Decoder Data bus 8 bits
		TD_HS,							//	TV Decoder H_SYNC
		TD_VS,							//	TV Decoder V_SYNC
		TD_RESET,						//	TV Decoder Reset
		////////////////////	GPIO	////////////////////////////
		GPIO_0,							//	GPIO Connection 0
		GPIO_1							//	GPIO Connection 1
	);

////////////////////////	Clock Input	 	////////////////////////
input			TD_CLK27;				//	27 MHz
input			CLOCK_50;				//	50 MHz
input			SMA_CLKIN;				//	External Clock
////////////////////////	Push Button		////////////////////////
input	[3:0]	KEY;					//	Pushbutton[3:0]
////////////////////////	DPDT Switch		////////////////////////
input	[17:0]	SW;						//	Toggle Switch[17:0]
////////////////////////	7-SEG Dispaly	////////////////////////
output	[6:0]	HEX0;					//	Seven Segment Digit 0
output	[6:0]	HEX1;					//	Seven Segment Digit 1
output	[6:0]	HEX2;					//	Seven Segment Digit 2
output	[6:0]	HEX3;					//	Seven Segment Digit 3
output	[6:0]	HEX4;					//	Seven Segment Digit 4
output	[6:0]	HEX5;					//	Seven Segment Digit 5
output	[6:0]	HEX6;					//	Seven Segment Digit 6
output	[6:0]	HEX7;					//	Seven Segment Digit 7
////////////////////////////	LED		////////////////////////////
output	[8:0]	LEDG;					//	LED Green[8:0]
output	[17:0]	LEDR;					//	LED Red[17:0]
////////////////////////////	UART	////////////////////////////
output			UART_TXD;				//	UART Transmitter
input			UART_RXD;				//	UART Receiver
////////////////////////////	IRDA	////////////////////////////
//output			IRDA_TXD;				//	IRDA Transmitter
input			IRDA_RXD;				//	IRDA Receiver
///////////////////////		SDRAM Interface	////////////////////////
inout	[15:0]	DRAM_DQ;				//	SDRAM Data bus 16 Bits
output	[11:0]	DRAM_ADDR;				//	SDRAM Address bus 12 Bits
output			DRAM_LDQM;				//	SDRAM Low-byte Data Mask 
output			DRAM_UDQM;				//	SDRAM High-byte Data Mask
output			DRAM_WE_N;				//	SDRAM Write Enable
output			DRAM_CAS_N;				//	SDRAM Column Address Strobe
output			DRAM_RAS_N;				//	SDRAM Row Address Strobe
output			DRAM_CS_N;				//	SDRAM Chip Select
output	[1:0]	DRAM_BA;				//	SDRAM Bank Address 0
output			DRAM_CLK;				//	SDRAM Clock
output			DRAM_CKE;				//	SDRAM Clock Enable
////////////////////////	Flash Interface	////////////////////////
inout	[7:0]	FL_DQ;					//	FLASH Data bus 8 Bits
output	[21:0]	FL_ADDR;				//	FLASH Address bus 22 Bits
output			FL_WE_N;				//	FLASH Write Enable
output			FL_RST_N;				//	FLASH Reset
output			FL_OE_N;				//	FLASH Output Enable
output			FL_CE_N;				//	FLASH Chip Enable
////////////////////////	SRAM Interface	////////////////////////
inout	[15:0]	SRAM_DQ;				//	SRAM Data bus 16 Bits
output	[17:0]	SRAM_ADDR;				//	SRAM Address bus 18 Bits
output			SRAM_UB_N;				//	SRAM High-byte Data Mask
output			SRAM_LB_N;				//	SRAM Low-byte Data Mask 
output			SRAM_WE_N;				//	SRAM Write Enable
output			SRAM_CE_N;				//	SRAM Chip Enable
output			SRAM_OE_N;				//	SRAM Output Enable
////////////////////	ISP1362 Interface	////////////////////////
inout	[15:0]	OTG_DATA;				//	ISP1362 Data bus 16 Bits
output	[1:0]	OTG_ADDR;				//	ISP1362 Address 2 Bits
output			OTG_CS_N;				//	ISP1362 Chip Select
output			OTG_RD_N;				//	ISP1362 Write
output			OTG_WR_N;				//	ISP1362 Read
output			OTG_RST_N;				//	ISP1362 Reset
output			OTG_FSPEED;				//	USB Full Speed,	0 = Enable, Z = Disable
output			OTG_LSPEED;				//	USB Low Speed, 	0 = Enable, Z = Disable
input			OTG_INT0;				//	ISP1362 Interrupt 0
input			OTG_INT1;				//	ISP1362 Interrupt 1
input			OTG_DREQ0;				//	ISP1362 DMA Request 0
input			OTG_DREQ1;				//	ISP1362 DMA Request 1
output			OTG_DACK0_N;			//	ISP1362 DMA Acknowledge 0
output			OTG_DACK1_N;			//	ISP1362 DMA Acknowledge 1
////////////////////	LCD Module 16X2	////////////////////////////
inout	[7:0]	LCD_DATA;				//	LCD Data bus 8 bits
output			LCD_ON;					//	LCD Power ON/OFF
output			LCD_BLON;				//	LCD Back Light ON/OFF
output			LCD_RW;					//	LCD Read/Write Select, 0 = Write, 1 = Read
output			LCD_EN;					//	LCD Enable
output			LCD_RS;					//	LCD Command/Data Select, 0 = Command, 1 = Data
////////////////////	SD Card Interface	////////////////////////
inout			SD_DAT;					//	SD Card Data
inout			SD_DAT3;				//	SD Card Data 3
inout			SD_CMD;					//	SD Card Command Signal
output			SD_CLK;					//	SD Card Clock
////////////////////////	I2C		////////////////////////////////
inout			I2C_SDAT;				//	I2C Data
output			I2C_SCLK;				//	I2C Clock
////////////////////////	PS2		////////////////////////////////
input		 	PS2_DAT;				//	PS2 Data
input			PS2_CLK;				//	PS2 Clock
////////////////////	USB JTAG link	////////////////////////////
input  			TDI;					// CPLD -> FPGA (data in)
input  			TCK;					// CPLD -> FPGA (clk)
input  			TCS;					// CPLD -> FPGA (CS)
output 			TDO;					// FPGA -> CPLD (data out)
////////////////////////	VGA			////////////////////////////
output			VGA_CLK;   				//	VGA Clock
output			VGA_HS;					//	VGA H_SYNC
output			VGA_VS;					//	VGA V_SYNC
output			VGA_BLANK;				//	VGA BLANK
output			VGA_SYNC;				//	VGA SYNC
output	[9:0]	VGA_R;   				//	VGA Red[9:0]
output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
////////////////	Ethernet Interface	////////////////////////////
inout	[15:0]	ENET_DATA;				//	DM9000A DATA bus 16Bits
output			ENET_CMD;				//	DM9000A Command/Data Select, 0 = Command, 1 = Data
output			ENET_CS_N;				//	DM9000A Chip Select
output			ENET_WR_N;				//	DM9000A Write
output			ENET_RD_N;				//	DM9000A Read
output			ENET_RST_N;				//	DM9000A Reset
input			ENET_INT;				//	DM9000A Interrupt
output			ENET_CLK;				//	DM9000A Clock 25 MHz
////////////////////	Audio CODEC		////////////////////////////
output/*inout*/	AUD_ADCLRCK;			//	Audio CODEC ADC LR Clock
input			AUD_ADCDAT;				//	Audio CODEC ADC Data
inout			AUD_DACLRCK;			//	Audio CODEC DAC LR Clock
output			AUD_DACDAT;				//	Audio CODEC DAC Data
inout			AUD_BCLK;				//	Audio CODEC Bit-Stream Clock
output			AUD_XCK;				//	Audio CODEC Chip Clock
////////////////////	TV Devoder		////////////////////////////
input	[7:0]	TD_DATA;    			//	TV Decoder Data bus 8 bits
input			TD_HS;					//	TV Decoder H_SYNC
input			TD_VS;					//	TV Decoder V_SYNC
output			TD_RESET;				//	TV Decoder Reset
////////////////////////	GPIO	////////////////////////////////
inout	[35:0]	GPIO_0;					//	GPIO Connection 0
inout	[35:0]	GPIO_1;					//	GPIO Connection 1

//////////////////////////////////////////////////////////////////////
////////////////////////////////////
//DLA state machine variables
wire reset;
reg [17:0] addr_reg; //memory address register for SRAM
reg [15:0] data_reg; //memory data register  for SRAM
reg we ;		//write enable for SRAM
reg [3:0] state;	//state machine
reg [7:0] led;		//debug led register
reg [30:0] x_rand;	//shift registers for random number gen  
reg [28:0] y_rand;
wire seed_low_bit, x_low_bit, y_low_bit; //rand low bits for SR
reg [8:0] x_walker; //particle coords
reg [8:0] y_walker;
reg [15:0] color_walker;
reg [3:0] sum; //neighbor sum
reg lock; //did we stay in sync?
reg memwait; //slow mem?
////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

//	LCD ON
assign	LCD_ON		=	1'b0;
assign	LCD_BLON	=	1'b0;

//	All inout port turn to tri-state
assign	DRAM_DQ		=	16'hzzzz;
assign	FL_DQ		=	8'hzz;
assign	SRAM_DQ		=	16'hzzzz;
assign	OTG_DATA	=	16'hzzzz;
assign	SD_DAT		=	1'bz;
assign	ENET_DATA	=	16'hzzzz;
assign	GPIO_0		=	36'hzzzzzzzzz;
assign	GPIO_1		=	36'hzzzzzzzzz;

wire [31:0]	mSEG7_DIG;
reg	 [31:0]	Cont;
wire		VGA_CTRL_CLK;
wire		AUD_CTRL_CLK;
wire [9:0]	mVGA_R;
wire [9:0]	mVGA_G;
wire [9:0]	mVGA_B;
wire [19:0]	mVGA_ADDR;			//video memory address
wire [9:0]  Coord_X, Coord_Y;	//display coods
wire		DLY_RST;

assign	TD_RESET	=	1'b1;	//	Allow 27 MHz input
//assign	AUD_ADCLRCK	=	AUD_DACLRCK;
//assign	AUD_XCK		=	AUD_CTRL_CLK;

assign	LEDR =	18'h0;

Reset_Delay			r0	(	.iCLK(CLOCK_50),.oRESET(DLY_RST)	);

VGA_Audio_PLL 		p1	(	.areset(~DLY_RST),.inclk0(TD_CLK27),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK),.c2(VGA_CLK)	);


VGA_Controller		u1	(	//	Host Side
							.iCursor_RGB_EN(4'b0111),
							.oAddress(mVGA_ADDR),
							.oCoord_X(Coord_X),
							.oCoord_Y(Coord_Y),
							.iRed(mVGA_R),
							.iGreen(mVGA_G),
							.iBlue(mVGA_B),
							//	VGA Side
							.oVGA_R(VGA_R),
							.oVGA_G(VGA_G),
							.oVGA_B(VGA_B),
							.oVGA_H_SYNC(VGA_HS),
							.oVGA_V_SYNC(VGA_VS),
							.oVGA_SYNC(VGA_SYNC),
							.oVGA_BLANK(VGA_BLANK),
							//	Control Signal
							.iCLK(VGA_CTRL_CLK),
							.iRST_N(DLY_RST)	);


// SRAM_control
assign SRAM_ADDR = addr_reg;
assign SRAM_DQ = (we)? 16'hzzzz : data_reg ;
assign SRAM_UB_N = 0;					// hi byte select enabled
assign SRAM_LB_N = 0;					// lo byte select enabled
assign SRAM_CE_N = 0;					// chip is enabled
assign SRAM_WE_N = we;					// write when ZERO
assign SRAM_OE_N = 0;					//output enable is overidden by WE

// Show SRAM on the VGA
assign  mVGA_R = {SRAM_DQ[15:12], 6'b0} ;
assign  mVGA_G = {SRAM_DQ[11:8], 6'b0} ;
assign  mVGA_B = {SRAM_DQ[7:4], 6'b0} ;

// DLA state machine
assign reset = ~KEY[0];
assign LEDG = led;

//right-most bit for rand number shift regs
//your basic XOR random # gen
assign x_low_bit = x_rand[27] ^ x_rand[30];
assign y_low_bit = y_rand[26] ^ y_rand[28];

//state names
parameter init=4'd0, test1=4'd1, test2=4'd2, test3=4'd3, test4=4'd4, test5=4'd5, test6=4'd6, 
	draw_walker=4'd7, update_walker=4'd8, new_walker=4'd9 ;

always @ (posedge VGA_CTRL_CLK)
begin
	
	if (reset)		//synch reset assumes KEY0 is held down 1/60 second
	begin
		//clear the screen
		addr_reg <= {Coord_X[9:1],Coord_Y[9:1]} ;	// [17:0]
		we <= 1'b0;								//write some memory
		data_reg <= 16'b0;						//write all zeros (black)		
		//init random number generators to alternating bits
		x_rand <= 31'h55555555;
		y_rand <= 29'h55555555;
		//init a randwalker to just left of center
		x_walker <= 9'd155;
		y_walker <= 9'd120;
		//
		color_walker <= 16'hFFFF;
		
		state <= init;	//first state in regular state machine 
	end
	
	//modify display during sync
	else if ((~VGA_VS | ~VGA_HS) & KEY[3])  //sync is active low; KEY3 is pause
	begin
		case(state)
			
			init: //write a single dot in the middle of the screen
			begin
				addr_reg <= {9'd50,9'd120} ;	//(x,y)
				we <= 1'b0;								
				//write a white dot in the middle of the screen
				data_reg <= 16'hFFFF;
				state <= test1 ;

			end			
					
			test1: //read left neighbor
			begin	
				lock <= 1'b1; 	//set the interlock to detect end of sync interval
				sum <= 0; 		//init sum of neighbors
				we <= 1'b1; 	//no memory write 
				//read  left neighbor 
				addr_reg <= {x_walker-9'd1,y_walker};
				state <= test2 ;			
			end
			
			test2: //check left neighbor and read right neighbor 
			begin				
				we <= 1'b1; //no memory write 
				sum <= sum + {3'b0, SRAM_DQ[15]};	
				//read right neighbor 
				addr_reg <= {x_walker+9'd1,y_walker};
				state <= test3 ;	
			end
			
			test3: //check right neighbor and read upper neighbor 
			begin
				we <= 1'b1; //no memory write 
				sum <= sum + {3'b0, SRAM_DQ[15]};
				//read upper neighbor 
				addr_reg <= {x_walker,y_walker - 9'd1};
				state <= test4 ;							
			end
			
			test4: //check upper neighbor and read lower neighbor 
			begin
				we <= 1'b1; //no memory write 
				sum <= sum + {3'b0, SRAM_DQ[15]};
				//read lower neighbor 
				addr_reg <= {x_walker,y_walker + 9'd1};
				state <= test5 ;							
			end
			
			test5: //check lower neighbor
			begin
				we <= 1'b1; //no memory write 
				sum <= sum + {3'b0, SRAM_DQ[15]} ;
				state <= test6 ;
				led <= sum;
			end	
			
			test6:
			begin
				if (lock & sum>0) // then there is a neighbor
				begin
					state <= draw_walker;
				end
				else // if get here, then no neighbors, so update position
					state <= update_walker; 
			end
			
			draw_walker: //draw the walker
			begin
				we <= 1'b0; // memory write 
				addr_reg <= {x_walker,y_walker};
				data_reg <= color_walker ;
				state <= new_walker ;	
			end
			
			update_walker: //update the walker
			begin
				we <= 1'b1; //no mem write
				//inc/dec x while staying on screen
				if (x_walker<9'd318 & x_rand[30]==1)
					x_walker <= x_walker+1;
				else if (x_walker>9'd2 & x_rand[30]==0)
					x_walker <= x_walker-1;
				//inc/dec y while staying on screen
				if (y_walker<9'd237 & y_rand[28]==1)
					y_walker <= y_walker+1;
				else if (y_walker>9'd2 & y_rand[28]==0)
					y_walker <= y_walker-1;
				//update the x,y random number gens
				x_rand <= {x_rand[29:0], x_low_bit} ;
				y_rand <= {y_rand[27:0], y_low_bit} ;
				state <= test1 ;	
			end
			
			new_walker: //generate a new one
			begin
				we <= 1'b1; // no memory write
				//init randwalker x
				if (x_rand[30])
					x_walker <= 9'd318;
				else
					x_walker <= 9'd2;
				//init randwalker y
				if (y_rand[28])
					y_walker <= 9'd238;
				else
					y_walker <= 9'd2;
				//update the x,y random number gens
				//the new color
				//color_walker <= color_walker - 1;
				x_rand <= {x_rand[29:0], x_low_bit} ;
				y_rand <= {y_rand[27:0], y_low_bit} ;
				state <= test1;
			end
		endcase
	end
	
	//show display when not blanking, 
	//which implies we=1 (not enabled); and use VGA module address
	else
	begin
		lock <= 1'b0; //clear lock if display starts because this destroys mem addr_reg
		addr_reg <= {Coord_X[9:1],Coord_Y[9:1]} ;
		we <= 1'b1;
	end
end

endmodule //top module