// hour_count module, implements timing counting,
// timing for 1s & 1h and work day,
// generates current work hour
// clk is the clock input
// work_day_increment used to increase work hour by 1
// reset used as reset signal
// work_hour is the current work hour
// expired_one_second, 1s is expired
// expired_one_hour, 1h is expried
// work_day_expired, work day is expried
// Author: BLR, University of Washington
module hour_count #(
	parameter CNT_1S = 28'd50_000_000,
	parameter CNT_HOUR = 12'd3600
)(
	input logic clk,
	input logic reset,
	input logic work_day_increment,
	output logic [3:0] work_hour,
	output logic expired_one_second,
	output logic expired_one_hour,
	output logic work_day_expired
);

logic [27:0] cnt1; // count for second
logic [11:0] cnt2; // count for hour

logic [3:0] work_hours; // how manys hours for current day

assign work_hours = (work_day_increment) ? 4'd9 : 4'd8; // one more work hour when work_day_increment valid(high)
// counting for 1 second
always_ff @(posedge clk or posedge reset)begin
	if(reset)begin
		cnt1 <= 'd0;
		expired_one_second <= 1'b0;
	end
	else if(cnt1 == CNT_1S-1)begin
		cnt1 <= 'd0;
		expired_one_second <= 1'b1;
	end
	else begin
		cnt1 <= cnt1 + 'd1;
		expired_one_second <= 1'b0;
	end
end
// counting for 1 hour
always_ff @(posedge clk or posedge reset)begin
	if(reset)begin
		cnt2 <= 'd0;
		expired_one_hour <= 1'b0;
	end
	else if(expired_one_second && (cnt2 == (CNT_HOUR-1)))begin
		cnt2 <= 'd0;
		expired_one_hour <= 1'b1;
	end
	else if(expired_one_second)begin
		cnt2 <= cnt2 + 'd1;
		expired_one_hour <= 1'b0;
	end
	else begin
		cnt2 <= cnt2;
		expired_one_hour <= 1'b0;
	end
end
// counting for current work hour
always_ff @(posedge clk or posedge reset)begin
	if(reset)begin
		work_hour <= 'd0;
	end
	else if(expired_one_hour && (work_hour < work_hours-1))begin
		work_hour <= work_hour + 'd1;
	end
	else begin
		work_hour <= work_hour;
	end
end
// work hour is expired 
always_ff @(posedge clk or posedge reset)begin
	if(reset)begin
		work_day_expired <= 1'b0;
	end
	else if(expired_one_hour && (work_hour == work_hours-1))begin
		work_day_expired <= 1'b1;
	end
	else begin
		work_day_expired <= work_day_expired;
	end
end

endmodule

//////////////// test bench ////////////////
`timescale 1ns/1ps
module hour_count_tb();
logic clk,reset,work_day_increment;
logic [3:0] work_hour;
logic expired_one_second,expired_one_hour,work_day_expired;

initial begin
	clk = 1'b0;
	reset = 1'b1;
	work_day_increment = 1'b0;
	repeat(5) @(posedge clk);
	reset = 1'b0;
	repeat(250) @(posedge clk);
	reset = 1'b1;
	repeat(5) @(posedge clk);
	reset = 1'b0;
	repeat(250) @(posedge clk);
	work_day_increment = 1'b1;
	repeat(25) @(posedge clk);
	$stop;
end

always #10 clk = ~clk;

// small valuses for CNT_1S & CNT_HOUR to speeds up simulation
hour_count #(
	.CNT_1S					(5),
	.CNT_HOUR				(5)	
)dut(
	.clk					(clk),
	.reset					(reset),
	.work_day_increment		(work_day_increment),
	.work_hour				(work_hour),
	.expired_one_second		(expired_one_second),
	.expired_one_hour		(expired_one_hour),
	.work_day_expired		(work_day_expired)
);
endmodule