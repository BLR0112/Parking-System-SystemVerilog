// car_track module, implements car tracking,
// clk is the clock input
// reset used as reset signal
// work_hour is the current work hour
// expired_one_second, 1s is expired
// car_enter is that there is a car entering
// expired_one_hour, 1h is expried
// work_day_expired, work day is expried
// car_track_ram_addr is the read address of ram
// car_track_ram_out is read out of ram
// Author: BLR, University of Washington
module car_track(
	input logic clk,
	input logic reset,
	input logic [3:0] work_hour,
	input logic expired_one_hour,
	input logic car_enter,
	input logic expired_one_second,
	input logic work_day_expired,
	output logic [2:0] car_track_ram_addr,
	output logic [15:0] car_track_ram_out
);
// signals definition
logic [2:0] wr_addr,rd_addr;
logic [15:0] wr_data,rd_data;
logic wr_en;

logic [15:0] car_number;
logic [1:0] car_enter_pip;
logic car_enter_valid;
// edge detect
always_ff @(posedge clk or posedge reset)begin
	if(reset)begin
		car_enter_pip <= 'd0;
	end
	else begin
		car_enter_pip <= {car_enter_pip[0],car_enter};
	end
end
// car enter is valid
assign car_enter_valid = (~car_enter_pip[1]) && car_enter_pip[0];
// count car number of entering
always_ff @(posedge clk or posedge reset)begin
	if(reset)begin
		car_number <= 'd0;
	end
	else if(car_enter_valid)begin
		car_number <= car_number + 'd1;
	end
	else begin
		car_number <= car_number;
	end
end
// write car number
always_ff @(posedge clk or posedge reset)begin
	if(reset)begin
		wr_addr <= 'd0;
		wr_data <= 'd0;
		wr_en <= 1'b0; 
	end
	else if(expired_one_hour)begin
		wr_addr <= work_hour;
		wr_data <= car_number;
		wr_en <= 1'b1;
	end
	else begin
		wr_addr <= wr_addr;
		wr_data <= wr_data;
		wr_en <= 1'b0;
	end
end
// ram instantiation
dual_ram8x16 dual_ram8x16_inst(
	.clk					(clk),
	.wr_addr				(wr_addr),
	.wr_data				(wr_data),
	.wr_en					(wr_en),
	.rd_addr				(rd_addr),
	.rd_data				(rd_data)
);
// read ram
always_ff @(posedge clk or posedge reset)begin
	if(reset)begin
		rd_addr <= 3'd0;
	end
	else if(work_day_expired && expired_one_second)begin
		rd_addr <= rd_addr - 'd1;
	end
	else begin
		rd_addr <= rd_addr;
	end
end

assign car_track_ram_addr = rd_addr;
assign car_track_ram_out = rd_data;

endmodule

///////////////////// test bench //////////////////////
`timescale 1ns/1ps
module car_track_tb();
logic clk;
logic reset;
logic [3:0] work_hour;
logic expired_one_hour;
logic car_enter;
logic expired_one_second;
logic work_day_expired;
logic [2:0] car_track_ram_addr;
logic [15:0] car_track_ram_out;

// small valuses for CNT_1S & CNT_HOUR to speeds up simulation
hour_count #(
	.CNT_1S					(5),
	.CNT_HOUR				(5)	
)hour_count_sim(
	.clk					(clk),
	.reset					(reset),
	.work_day_increment		(1'b0),
	.work_hour				(work_hour),
	.expired_one_second		(expired_one_second),
	.expired_one_hour		(expired_one_hour),
	.work_day_expired		(work_day_expired)
);

car_track dut(
	.clk					(clk),
	.reset					(reset),
	.work_hour				(work_hour),
	.expired_one_hour		(expired_one_hour),
	.car_enter				(car_enter),
	.expired_one_second		(expired_one_second),
	.work_day_expired		(work_day_expired),
	.car_track_ram_addr		(car_track_ram_addr),
	.car_track_ram_out		(car_track_ram_out)
);

initial begin
	clk = 1'b0;
	reset = 1'b1;
	car_enter = 1'b0;
	repeat(5) @(posedge clk);
	reset = 1'b0;
	car_entering();
	repeat(25) @(posedge clk);
	car_entering();
	repeat(25) @(posedge clk);
	car_entering();
	repeat(25) @(posedge clk);
	car_entering();
	repeat(25) @(posedge clk);
	car_entering();
	repeat(25) @(posedge clk);
	car_entering();
	repeat(25) @(posedge clk);
	car_entering();
	repeat(25) @(posedge clk);
	repeat(25) @(posedge clk);
	repeat(25) @(posedge clk);
	repeat(25) @(posedge clk);
	repeat(25) @(posedge clk);
	repeat(25) @(posedge clk);
	$stop;
end

always #10 clk = ~clk;

task car_entering();
	@(posedge clk)begin
		car_enter = 1'b1;
	end
	@(posedge clk)begin
		car_enter = 1'b0;
	end
	@(posedge clk);
endtask

endmodule