// datapath module, implements datapath logic to find rush hour,
// clk is the clock input
// reset used as reset signal
// rush_start_valid indicates current work hour is the start of rush hour
// rush_end_valid indicates current work hour is the end of rush hour
// work_hour indicates current work hour
// rush_start is the first start of rush hour
// rush_start_exist indicates the rush hour start exists
// rush_end is the first start of rush hour
// rush_end_exist indicates the rush hour end exists
// Author: BLR, University of Washington
module datapath(
	input logic clk,
	input logic reset,
	input logic rush_start_valid,
	input logic rush_end_valid,
	input logic [3:0] work_hour,
	output logic [3:0] rush_start,
	output logic rush_start_exist,
	output logic [3:0] rush_end,
	output logic rush_end_exist
);
// indicates the first rush start/end
logic first_rush_start;
logic first_rush_end;
// fisrt rush start is recorded, when asserted
always_ff @(posedge clk or posedge reset)begin
	if(reset)begin
		first_rush_start <= 1'b0;
	end
	else if(rush_start_valid)begin
		first_rush_start <= 1'b1;
	end
	else begin
		first_rush_start <= first_rush_start;
	end
end
// get the first start of rush hour
always_ff @(posedge clk or posedge reset)begin
	if(reset)begin
		rush_start <= 'd0;
		rush_start_exist <= 1'b0;
	end
	else if(rush_start_valid && (~first_rush_start))begin
		rush_start <= work_hour;
		rush_start_exist <= 1'b1;
	end
	else begin
		rush_start <= rush_start;
		rush_start_exist <= rush_start_exist;
	end
end
// fisrt rush end is recorded, when asserted
always_ff @(posedge clk or posedge reset)begin
	if(reset)begin
		first_rush_end <= 1'b0;
	end
	else if(rush_end_valid)begin
		first_rush_end <= 1'b1;
	end
	else begin
		first_rush_end <= first_rush_end;
	end
end
// get the first end of rush hour
always_ff @(posedge clk or posedge reset)begin
	if(reset)begin
		rush_end <= 'd0;
		rush_end_exist <= 1'b0;
	end
	else if(rush_end_valid && (~first_rush_end))begin
		rush_end <= work_hour;
		rush_end_exist <= 1'b1;
	end
	else begin
		rush_end <= rush_end;
		rush_end_exist <= rush_end_exist;
	end
end

endmodule

////////////////// test bench //////////////////
`timescale 1ns/1ps
module datapath_tb();

logic clk,reset,work_day_increment;
logic [3:0] work_hour;
logic expired_one_second,expired_one_hour,work_day_expired;

logic slot_empty;
logic slot_full;
logic rush_start_valid;
logic rush_end_valid;

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

control control_inst(
	.clk					(clk),
	.reset					(reset),
	.slot_empty				(slot_empty),
	.slot_full				(slot_full),
	.rush_start_valid		(rush_start_valid),
	.rush_end_valid			(rush_end_valid)
);

datapath dut(
	.clk					(clk),
	.reset					(reset),
	.rush_start_valid		(rush_start_valid),
	.rush_end_valid			(rush_end_valid),
	.work_hour				(work_hour),
	.rush_start				(rush_start),
	.rush_start_exist		(rush_start_exist),
	.rush_end				(rush_end),
	.rush_end_exist			(rush_end_exist)
);
endmodule