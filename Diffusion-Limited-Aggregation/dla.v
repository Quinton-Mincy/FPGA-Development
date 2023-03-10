/*
Quinton Mincy

Modified top module (DE2-Default)

Edits: 
	#Removed unneccesary ports/interfaces from code
	#Added the Color_Controller module to change color in realtime
*/
module dla
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
		////////////////////	SRAM Interface		////////////////
		SRAM_DQ,						//	SRAM Data bus 16 Bits
		SRAM_ADDR,						//	SRAM Address bus 18 Bits
		SRAM_UB_N,						//	SRAM High-byte Data Mask 
		SRAM_LB_N,						//	SRAM Low-byte Data Mask 
		SRAM_WE_N,						//	SRAM Write Enable
		SRAM_CE_N,						//	SRAM Chip Enable
		SRAM_OE_N,						//	SRAM Output Enable
		////////////////////	VGA		////////////////////////////
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,  						//	VGA Blue[9:0]
		////////////////	TV Decoder		////////////////////////
		TD_RESET,						//	TV Decoder Reset--necessary for 27MgHz(TD_CLK27) clock
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
output reg [8:0]	LEDG;					//	LED Green[8:0]
output reg [17:0]	LEDR;					//	LED Red[17:0]
///////////////////////		SDRAM Interface	////////////////////////
inout	   [15:0]DRAM_DQ;				//	SDRAM Data bus 16 Bits
output   [11:0]DRAM_ADDR;				//	SDRAM Address bus 12 Bits
output			DRAM_LDQM;				//	SDRAM Low-byte Data Mask 
output			DRAM_UDQM;				//	SDRAM High-byte Data Mask
output			DRAM_WE_N;				//	SDRAM Write Enable
output			DRAM_CAS_N;				//	SDRAM Column Address Strobe
output			DRAM_RAS_N;				//	SDRAM Row Address Strobe
output			DRAM_CS_N;				//	SDRAM Chip Select
output    [1:0]DRAM_BA;				//	SDRAM Bank Address 0
output			DRAM_CLK;				//	SDRAM Clock
output			DRAM_CKE;				//	SDRAM Clock Enable
////////////////////////	SRAM Interface	////////////////////////
inout	   [15:0]SRAM_DQ;				//	SRAM Data bus 16 Bits
output	[17:0]SRAM_ADDR;				//	SRAM Address bus 18 Bits
output			SRAM_UB_N;				//	SRAM High-byte Data Mask
output			SRAM_LB_N;				//	SRAM Low-byte Data Mask 
output			SRAM_WE_N;				//	SRAM Write Enable
output			SRAM_CE_N;				//	SRAM Chip Enable
output			SRAM_OE_N;				//	SRAM Output Enable
////////////////////////	VGA			////////////////////////////
output			VGA_CLK;   				//	VGA Clock
output			VGA_HS;					//	VGA H_SYNC
output			VGA_VS;					//	VGA V_SYNC
output			VGA_BLANK;				//	VGA BLANK
output			VGA_SYNC;				//	VGA SYNC
output	[9:0]	VGA_R;   				//	VGA Red[9:0]
output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
output	[9:0]	VGA_B;   				//	VGA Blue[9:0]/
////////////////////	TV Devoder		////////////////////////////
output		TD_RESET;				//	TV Decoder Reset
//////////////////////////////////////////////////////////////////////
////////////////////////////////////
//DLA state machine variables
wire reset;
reg [17:0] starting_location; //location of first pixel
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
wire [15:0] Color_Walker;
reg [3:0] sum; //neighbor sum
reg lock; //did we stay in sync?
reg memwait; //slow mem?
////////////////////////////////////////
///////////////////////////////////////////////////////////////////////


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

Color_Controller	s5 (	.iCLK(VGA_CTRL_CLK),.iSW(SW),.oColor_Walker(Color_Walker));
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
//assign LEDG = led;

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
		LEDR<= 18'h0;
		LEDG<= 8'h0;
		if(SW[0]) begin
			LEDR[0] <= 1;
			starting_location <= {9'd25,9'd200} ;	//bottom left of screen
		end
		else if(SW[1]) begin
			LEDR[1] <= 1;
			starting_location <= {9'd25,9'd60} ;	//top left of screen
		end
		else if(SW[2])begin
			LEDR[2] <= 1;
			starting_location <= {9'd295,9'd60} ;	//top right of screen
		end
		else if(SW[3])begin
			LEDR[3] <= 1;
			starting_location <= {9'd295,9'd200} ;	//bottom right of screen
		end
		else begin
			//LEDG[8]<=1;
			starting_location <= {9'd160,9'd120} ; //middle of screen
		end
		
		state <= init;	//first state in regular state machine 
	end
	
	//modify display during sync
	else if ((~VGA_VS | ~VGA_HS) & KEY[3])  //sync is active low; KEY3 is pause
	begin
		case(state)
			
			init: //write a single dot in the middle of the screen
			begin
				//addr_reg <= {9'd160,9'd120} ;	//(x,y)
				addr_reg <= starting_location ;	//(x,y)
				we <= 1'b0;								
				//write a white dot in the middle of the screen
				data_reg <= Color_Walker;
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
				//led <= sum;
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
				data_reg <= Color_Walker ;
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