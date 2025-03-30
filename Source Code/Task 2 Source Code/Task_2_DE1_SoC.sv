// Top level for Lab6 task 2, implements 3D parking slot logic 
// including rush hour & car tracking
// CLOCK_50 is the clock input
// KEY[0] used to increase work hour by 1
// SW[9] used as reset signal
// V_GPIO[28] Presence parking 1
// V_GPIO[29] Presence parking 2
// V_GPIO[30] Presence parking 3
// V_GPIO[23] Presence entrance
// V_GPIO[24] Presence exit
// V_GPIO[26] LED parking 1
// V_GPIO[27] LED parking 2
// V_GPIO[32] LED parking 3
// V_GPIO[34] LED full
// V_GPIO[31] Open entrance
// V_GPIO[33] Open exit
// HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 
 
// Author: BLR, University of Washington
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, V_GPIO);

	// define ports
	input  logic CLOCK_50;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input  logic [3:0] KEY;
	input  logic [9:0] SW;
	output logic [9:0] LEDR;
	
	inout  logic [35:23] V_GPIO;
	//input logic [35:23] V_GPIO;

    // Initialize HEX
    /* assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1; */
/* 
	// FPGA output
	assign V_GPIO[26] = SW[0];	// LED parking 1
	assign V_GPIO[27] = SW[1];	// LED parking 2
	assign V_GPIO[32] = SW[2];	// LED parking 3
	assign V_GPIO[34] = SW[3];	// LED full
	assign V_GPIO[31] = SW[4];	// Open entrance
	assign V_GPIO[33] = SW[5];	// Open exit
	 */
	// FPGA input
	assign LEDR[0] = V_GPIO[28];	// Presence parking 1
	assign LEDR[1] = V_GPIO[29];	// Presence parking 2
	assign LEDR[2] = V_GPIO[30];	// Presence parking 3
	assign LEDR[3] = V_GPIO[23];	// Presence entrance
	assign LEDR[4] = V_GPIO[24];	// Presence exit
	
	//// code start here ////
	logic reset; // reset signal
	logic [2:0] parking_status; // indicates parking slot occupied or not
	logic slot_empty,slot_full; // parking slot empty and full signal
	logic work_day_increment; // asserted, when KEY[0] is pressed
	
	logic [3:0] rush_start; // start of first rush hour
	logic [3:0] rush_end; // end of first rush hour
	logic [3:0] work_hour; // current work hour
	logic expired_one_second; // asserted, when 1s is expired
	logic expired_one_hour; // asserted, when 1h is expired
	logic work_day_expired; // asserted, when work day is expired
	logic [2:0] car_track_ram_addr; // address of ram for car tracking
	logic [15:0] car_track_ram_out; // read out of ram 
	
	assign reset = SW[9]; // reset signal
	assign parking_status = {V_GPIO[30],V_GPIO[29],V_GPIO[28]}; // status of current parking slots
	assign slot_full = &parking_status; // parking slots are full
	assign slot_empty = ~(|parking_status); // parking slots are empty
	assign work_day_increment = ~KEY[0]; // asserted, increment work day
	// LED color driver
	assign V_GPIO[26] = V_GPIO[28]; // LED parking 1
	assign V_GPIO[27] = V_GPIO[29]; // LED parking 2
	assign V_GPIO[32] = V_GPIO[30]; // LED parking 3
	assign V_GPIO[34] = (slot_full) ? 1'b1 : 1'b0; // asserted, when 3 slots are occupied
	
	assign V_GPIO[31] = V_GPIO[23] && (~(&parking_status)); // open entrance gate, when car waiting at entrance and a slot is available
	assign V_GPIO[33] = V_GPIO[24]; // open exit gate, when car waiting at exit
	
	// instantiation of hour count module, 25s is 1 hour for simulation & testing
	hour_count #(
		.CNT_1S						(50_000_000),
		.CNT_HOUR					(25)	
	)hour_count_inst(
		.clk						(CLOCK_50),
		.reset						(reset),
		.work_day_increment			(work_day_increment),
		.work_hour					(work_hour),
		.expired_one_second			(expired_one_second),
		.expired_one_hour			(expired_one_hour),
		.work_day_expired			(work_day_expired)
	);
	// Rush Hour
	rush_hour rush_hour_inst(
		.clk						(CLOCK_50),
		.reset						(reset),
		.slot_empty					(slot_empty),
		.slot_full					(slot_full),
		.work_hour					(work_hour),
		.rush_start_exist			(rush_start_exist), // indicates that there exist a start of rush hour, when puul high
		.rush_start					(rush_start),
		.rush_end_exist				(rush_end_exist), // indicates that there exist an end of rush hour, when puul high
		.rush_end					(rush_end)
	);
	// car tracking
	car_track car_track_inst(
		.clk						(CLOCK_50),
		.reset						(reset),
		.work_hour					(work_hour),
		.expired_one_hour			(expired_one_hour),
		.car_enter					((V_GPIO[23] && (~(&parking_status)))), // when there is a car at entrance and parking slot is available, open the gate
		.expired_one_second			(expired_one_second),
		.work_day_expired			(work_day_expired),
		.car_track_ram_addr			(car_track_ram_addr),
		.car_track_ram_out			(car_track_ram_out)
	);
	// diaplay
	display display_inst(
		.parking_status				(parking_status),
		.work_hour					(work_hour),
		.work_day_expired			(work_day_expired),
		.rush_start					(rush_start),
		.rush_start_exist			(rush_start_exist),
		.rush_end					(rush_end),
		.rush_end_exist				(rush_end_exist),
		.car_track_ram_addr			(car_track_ram_addr),
		.car_track_ram_out			(car_track_ram_out),
		.HEX0						(HEX0),
		.HEX1						(HEX1),
		.HEX2						(HEX2),
		.HEX3						(HEX3),
		.HEX4						(HEX4),
		.HEX5						(HEX5)
);
	
endmodule  // DE1_SoC

///////////////////// test bench //////////////////////
module DE1_SoC_tb();

logic CLOCK_50;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
logic [3:0] KEY;
logic [9:0] SW;
logic [9:0] LEDR;
logic [34:23] V_GPIO;

initial begin
	CLOCK_50 = 1'b0;
	SW[9] = 1'b1; // reset
	KEY[0] = 1'b1;
	V_GPIO[30] = 1'b0;
	V_GPIO[29] = 1'b0;
	V_GPIO[28] = 1'b0;
	
	V_GPIO[23] = 1'b0;
	V_GPIO[24] = 1'b0;
	repeat(20) @(posedge CLOCK_50);
	SW[9] = 1'b0; // reset release
	// one car entering
	repeat(25) @(posedge CLOCK_50);
	V_GPIO[30] = 1'b0;
	V_GPIO[29] = 1'b0;
	V_GPIO[28] = 1'b1;
	
	V_GPIO[23] = 1'b1;
	@(posedge CLOCK_50);
	V_GPIO[23] = 1'b0;
	// one car entering
	repeat(25) @(posedge CLOCK_50);
	V_GPIO[30] = 1'b0;
	V_GPIO[29] = 1'b1;
	V_GPIO[28] = 1'b1;
	
	V_GPIO[23] = 1'b1;
	@(posedge CLOCK_50);
	V_GPIO[23] = 1'b0;
	// one car leaving
	repeat(25) @(posedge CLOCK_50);
	V_GPIO[30] = 1'b0;
	V_GPIO[29] = 1'b0;
	V_GPIO[28] = 1'b1;
	// one car entering
	repeat(25) @(posedge CLOCK_50);
	V_GPIO[30] = 1'b0;
	V_GPIO[29] = 1'b1;
	V_GPIO[28] = 1'b1;
	
	V_GPIO[23] = 1'b1;
	@(posedge CLOCK_50);
	V_GPIO[23] = 1'b0;
	// one car entering
	repeat(25) @(posedge CLOCK_50);
	V_GPIO[30] = 1'b1;
	V_GPIO[29] = 1'b1;
	V_GPIO[28] = 1'b1;
	
	V_GPIO[23] = 1'b1;
	@(posedge CLOCK_50);
	V_GPIO[23] = 1'b0;
	// two car leaving
	repeat(25) @(posedge CLOCK_50);
	V_GPIO[30] = 1'b0;
	V_GPIO[29] = 1'b0;
	V_GPIO[28] = 1'b1;
	// two car entering
	repeat(25) @(posedge CLOCK_50);
	V_GPIO[30] = 1'b1;
	V_GPIO[29] = 1'b1;
	V_GPIO[28] = 1'b1;
	
	V_GPIO[23] = 1'b1;
	@(posedge CLOCK_50);
	V_GPIO[23] = 1'b0;
		
	@(posedge CLOCK_50);
	
	V_GPIO[23] = 1'b1;
	@(posedge CLOCK_50);
	V_GPIO[23] = 1'b0;
	// three cars leaving 
	repeat(25) @(posedge CLOCK_50);
	V_GPIO[30] = 1'b0;
	V_GPIO[29] = 1'b0;
	V_GPIO[28] = 1'b0;
	repeat(25) @(posedge CLOCK_50);
	repeat(25) @(posedge CLOCK_50);
	$stop;
end

always #10 CLOCK_50 = ~CLOCK_50;

DE1_SoC dut(
	.CLOCK_50			(CLOCK_50), 
	.HEX0				(HEX0), 
	.HEX1				(HEX1), 
	.HEX2				(HEX2), 
	.HEX3				(HEX3), 
	.HEX4				(HEX4), 
	.HEX5				(HEX5), 
	.KEY				(KEY), 
	.SW					(SW), 
	.LEDR				(LEDR), 
	.V_GPIO				(V_GPIO)
);

endmodule

