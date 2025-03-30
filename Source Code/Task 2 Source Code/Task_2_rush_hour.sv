//Jiawen Liu
//12/03/2024
//EE 371
//Lab #6, Task 2

// rush_hour module, implements to find rush hour,
// which consists of control & datapath module
// clk is the clock input
// reset used as reset signal
// slot_empty indicates that parking slot is empty
// slot_full indicates that parking slot is full
// work_hour is the current work hour, used for start & end of rush hour finding
// rush_start_exist indicates that there is a valid rush hour start
// rush_start is the first start of rush hour
// rush_end_exist indicates that there is a valid rush hour end
// rush_end is the first end of rush hour
// Author: BLR, University of Washington
module rush_hour(
	input logic clk,
	input logic reset,
	input logic slot_empty,
	input logic slot_full,
	input logic [3:0] work_hour,
	output logic rush_start_exist,
	output logic [3:0] rush_start,
	output logic rush_end_exist,
	output logic [3:0] rush_end
);

logic rush_start_valid; // indecates that the current work hour is the start of rush hour
logic rush_end_valid; // indecates that the current work hour is the end of rush hour

// control module for rush hour finding module
control control_inst(
	.clk						(clk),
	.reset						(reset),
	.slot_empty					(slot_empty),
	.slot_full					(slot_full),
	.rush_start_valid			(rush_start_valid),
	.rush_end_valid				(rush_end_valid)
);
// datapath module for rush hour finding module
datapath datapath_inst(
	.clk						(clk),
	.reset						(reset),
	.rush_start_valid			(rush_start_valid),
	.rush_end_valid				(rush_end_valid),
	.work_hour					(work_hour),
	.rush_start					(rush_start),
	.rush_start_exist			(rush_start_exist),
	.rush_end					(rush_end),
	.rush_end_exist				(rush_end_exist)
);

endmodule

///////////////////// test bench //////////////////
`timescale 1ns/1ps
module rush_hour_tb();

logic clk,reset,work_day_increment;
logic [3:0] work_hour;
logic expired_one_second,expired_one_hour,work_day_expired;
logic slot_empty;
logic slot_full;
logic [3:0] rush_start;
logic rush_start_exist;
logic [3:0] rush_end;
logic rush_end_exist;

initial begin
	clk = 1'b0;
	reset = 1'b1;
	work_day_increment = 1'b0;
	slot_empty = 1'b1;
	slot_full = 1'b0;
	repeat(25) @(posedge clk);
	reset = 1'b0;
	repeat(25) @(posedge clk);
	slot_empty = 1'b0;
	repeat(25) @(posedge clk);
	slot_empty = 1'b1;
	repeat(25) @(posedge clk);
	slot_empty = 1'b0;
	repeat(25) @(posedge clk);
	slot_full = 1'b1;
	repeat(25) @(posedge clk);
	slot_full = 1'b0;
	repeat(25) @(posedge clk);
	slot_full = 1'b1;
	repeat(25) @(posedge clk);
	slot_full = 1'b0;
	repeat(25) @(posedge clk);
	slot_empty = 1'b1;
	repeat(25) @(posedge clk);
	slot_empty = 1'b0;
	repeat(25) @(posedge clk);
	$stop;
end

always #10 clk = ~clk;

// small valuses for CNT_1S & CNT_HOUR to speeds up simulation
hour_count #(
	.CNT_1S					(5),
	.CNT_HOUR				(5)	
)hour_count_inst(
	.clk					(clk),
	.reset					(reset),
	.work_day_increment		(work_day_increment),
	.work_hour				(work_hour),
	.expired_one_second		(expired_one_second),
	.expired_one_hour		(expired_one_hour),
	.work_day_expired		(work_day_expired)
);

rush_hour dut(
	.clk					(clk),
	.reset					(reset),
	.slot_empty				(slot_empty),
	.slot_full				(slot_full),
	.work_hour				(work_hour),
	.rush_start_exist		(rush_start_exist),
	.rush_start				(rush_start),
	.rush_end_exist			(rush_end_exist),
	.rush_end				(rush_end)
);

endmodule