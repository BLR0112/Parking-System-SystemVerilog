// Top level for task 1, implements 3D parking slot logic 
// CLOCK_50 is the clock input
// V_GPIO[28] signal A
// V_GPIO[29] signal B
// V_GPIO[23] reset
// V_GPIO[26] LEDL
// V_GPIO[27] LEDR

// HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 
 
// Author: BLR, University of Washington
module DE1_SoC(
    input logic CLOCK_50,
    output logic [6:0] HEX0,
    output logic [6:0] HEX1,
    output logic [6:0] HEX2,
    output logic [6:0] HEX3,
    output logic [6:0] HEX4,
    output logic [6:0] HEX5,
	inout [35:0] V_GPIO
);

logic SIG_A,SIG_B;
logic ENTER,EXIT;
logic RSTN;
logic INC,DEC;
logic [4:0] cntNum;

assign V_GPIO[23] = 1'bz;
assign V_GPIO[28] = 1'bz;
assign V_GPIO[29] = 1'bz;

assign V_GPIO[26] = LEDL; // GPIO 26 drivers left led
assign V_GPIO[27] = LEDR; // GPIO 26 drivers left right


assign RSTN = ~V_GPIO[23]; // GPIO 23 connected to switch, used as reset signal
assign SIG_A = V_GPIO[28]; // GPIO 28 connected to switch, used as signal a
assign SIG_B = V_GPIO[29]; // GPIO 28 connected to switch, used as signal b
// when a car enters, ENTER signal asserts for one clock cycle
// when a car exits, EXIT signal asserts for one clock cycle
paking_lot_fsm paking_lot_fsm_inst(
    .CLOCK_50           (CLOCK_50),
    .RSTN               (RSTN),
    .SIG_A              (SIG_A),
    .SIG_B              (SIG_B),
    .ENTER              (ENTER),
    .EXIT               (EXIT)
);
// counts the car remain in the lot(cntNum), INC is high, cntNum increases by 1
// DEC is high, cntNum decreases by 1
assign INC = ENTER;
assign DEC = EXIT;
counter #(
    .MAX                (5'd25)
)counter_inst(
    .CLOCK_50           (CLOCK_50),
    .RSTN               (RSTN),
    .INC                (INC),
    .DEC                (DEC),
    .cntNum             (cntNum)
);
// drives LEDL & LEDS accordingly
assign LEDL = SIG_A;
assign LEDR = SIG_B;
// encodes the cntNum based on codebook(schmetic)so that it can be displayed correctly
display display_inst(
    .CLOCK_50           (CLOCK_50),
    .RSTN               (RSTN),
    .cntNum             (cntNum),
    .HEX0               (HEX0),
    .HEX1               (HEX1),
    .HEX2               (HEX2),
    .HEX3               (HEX3),
    .HEX4               (HEX4),
    .HEX5               (HEX5)
);
endmodule

/////////////////// test bench ////////////////////////////

`timescale 1ns/1ps
module DE1_SoC_tb();

logic clk_50m;
logic [7:0] G_HEX0,G_HEX1,G_HEX2,G_HEX3,G_HEX4,G_HEX5;
wire [35:0] V_GPIO;

initial begin
	clk_50m = 0;
	forever #10 clk_50m = ~clk_50m;
end 

DE1_SoC dut(
    .CLOCK_50			(clk_50m),
    //input logic RESET, // V_GPIO 23
    .G_HEX0				(HEX0),
    .G_HEX1				(HEX1),
    .G_HEX2				(HEX2),
    .G_HEX3				(HEX3),
    .G_HEX4				(HEX4),
    .G_HEX5				(HEX5),
	.V_GPIO				(V_GPIO)
);

logic RESET,SW_A,SW_B;
logic LEDL,LEDR;

//input logic RESET, // V_GPIO 23
//output logic LEDL, // V_GPIO 26
//output logic LEDR, // V_GPIO 27
//input logic SW_A,  // V_GPIO 28
//input logic SW_B   // V_GPIO 29
assign V_GPIO[23] = ~RESET;
assign V_GPIO[28] = SW_A;
assign V_GPIO[29] = SW_B;
initial begin
	RESET = 1'b0;
	SW_A = 1'b0;
	SW_B = 1'b0;
	#1000
	RESET = 1'b1;
	#110
	// 1st car entering
	car_entering();
	// 2nd car entering
	car_entering();
	// 3rd car entering
	car_entering();
	// 4th car entering
	car_entering();
	// 5th car entering
	car_entering();
	// 6th car entering
	car_entering();
	// 7th car entering
	car_entering();
	// 8th car entering
	car_entering();
	// 9th car entering
	car_entering();
	// 10th car entering
	car_entering();
	// 11th car entering
	car_entering();
	// 12th car entering
	car_entering();
	// 13th car entering
	car_entering();
	// 14th car entering
	car_entering();
	// 15th car entering
	car_entering();
	// 16th car entering
	car_entering();
	// 17th car entering
	car_entering();
	// 18th car entering
	car_entering();
	// 19th car entering
	car_entering();
	// 20th car entering
	car_entering();
	// 21th car entering
	car_entering();
	// 22th car entering
	car_entering();
	// 23th car entering
	car_entering();
	// 24th car entering
	car_entering();
	// 25th car entering
	car_entering();
	// additional car entering
	car_entering();
	// additional car entering
	car_entering();
	// additional car entering
	car_entering();
	// 1st car exiting
	car_entering();
	// 2nd car exiting
	car_exiting();
	// 3rd car exiting
	car_exiting();
	// 4th car exiting
	car_exiting();
	// 5th car exiting
	car_exiting();
	// 6th car exiting
	car_exiting();
	// additional car entering
	car_entering();
	// additional car exiting
	car_exiting();
	// additional car entering
	car_entering();
	// additional car exiting
	car_exiting();
	#1000
	$finish;
end

task car_entering();
	SW_A = 1'b1;
	#100
	SW_B = 1'b1;
	#100
	SW_A = 1'b0;
	#100
	SW_B = 1'b0;
	#100;
endtask
task car_exiting();
	SW_B = 1'b1;
	#100
	SW_A = 1'b1;
	#100
	SW_B = 1'b0;
	#100
	SW_A = 1'b0;
	#100;
endtask

endmodule