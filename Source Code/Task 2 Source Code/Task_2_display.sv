//Jiawen Liu
//12/03/2024
//EE 371
//Lab #6, Task 2

// display module, implements info display,
// parking_status is the parking slot status
// work_hour is the current work hour
// work_day_expired, work day is expired
// rush_start is the start of rush hour
// rush_start_exist indicates the start of rush hour is valid
// rush_end is the end of rush hour
// rush_end_exist indicates the end of rush hour is valid
// car_track_ram_addr is the read address of ram
// car_track_ram_out is read out of ram
// HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 display infos
// Author: BLR, University of Washington
module display(
	input logic [2:0] parking_status,
	input logic [3:0] work_hour,
	input logic work_day_expired,
	input logic [3:0] rush_start,
	input logic rush_start_exist,
	input logic [3:0] rush_end,
	input logic rush_end_exist,
	input logic [2:0] car_track_ram_addr,
	input logic [15:0] car_track_ram_out,
	output logic [6:0] HEX0,
	output logic [6:0] HEX1,
	output logic [6:0] HEX2,
	output logic [6:0] HEX3,
	output logic [6:0] HEX4,
	output logic [6:0] HEX5
);
// remained slots in parking slot
logic [1:0] remain_slot;
// data to be display at corresponding HEX
logic [3:0] data0;
logic [3:0] data1;
logic [3:0] data2;
logic [3:0] data3;
logic [3:0] data4;
logic [3:0] data5;
// get the remain slots 
always_comb begin
	case(parking_status)
		3'b111:remain_slot = 2'd0;
		3'b000:remain_slot = 2'd3;
		3'b001,3'b010,3'b100:remain_slot = 2'd2;
		3'b011,3'b101,3'b110:remain_slot = 2'd1;
	endcase
end
// get the data to be displayed for each HEX
always_comb begin
	data0 = 4'he;
	data1 = 4'he;
	data2 = 4'he;
	data3 = 4'he;
	data4 = 4'he;
	data5 = work_hour;
	if(work_day_expired)begin
		case({rush_end_exist,rush_start_exist})
			2'b00:begin
				data3 = 4'hd;
				data4 = 4'hd;
			end
			2'b01:begin
				data3 = rush_start;
				data4 = 4'hd;
			end
			2'b11:begin
				data3 = rush_start;
				data4 = rush_end;
			end
			2'b10:begin
				data3 = 4'hd;
				data4 = 4'hd;
			end
		endcase
		data2 = {1'b0,car_track_ram_addr};
		data1 = car_track_ram_out[3:0];
	end
	else begin
		if(&parking_status)begin
			data3 = 4'ha;
			data2 = 4'hb;
			data1 = 4'hc;
			data0 = 4'hc;
		end
		else begin
			data0 = {2'd0,remain_slot};
		end
	end
end
// data format converting
encoder encoder_hex0(
	.dataIn					(data0), // data to be displayed in hex format
	.disCode				(HEX0) // encoded data, which outputs directly to 7-segment display
);
// data format converting
encoder encoder_hex1(
	.dataIn					(data1), // data to be displayed in hex format
	.disCode				(HEX1) // encoded data, which outputs directly to 7-segment display
);
// data format converting
encoder encoder_hex2(
	.dataIn					(data2), // data to be displayed in hex format
	.disCode				(HEX2) // encoded data, which outputs directly to 7-segment display
);
// data format converting
encoder encoder_hex3(
	.dataIn					(data3), // data to be displayed in hex format
	.disCode				(HEX3) // encoded data, which outputs directly to 7-segment display
);
// data format converting
encoder encoder_hex4(
	.dataIn					(data4), // data to be displayed in hex format
	.disCode				(HEX4) // encoded data, which outputs directly to 7-segment display
);
// data format converting
encoder encoder_hex5(
	.dataIn					(data5), // data to be displayed in hex format
	.disCode				(HEX5) // encoded data, which outputs directly to 7-segment display
);

endmodule

///////////////////// test bench //////////////////////
`timescale 1ns/1ps
module display_tb();

logic [2:0] parking_status;
logic [3:0] rush_start;
logic rush_start_exist;
logic [3:0] rush_end;
logic rush_end_exist;
logic [3:0] work_hour;
logic work_day_expired;
logic [2:0] car_track_ram_addr;
logic [15:0] car_track_ram_out;

logic [6:0] HEX0;
logic [6:0] HEX1;
logic [6:0] HEX2;
logic [6:0] HEX3;
logic [6:0] HEX4;
logic [6:0] HEX5;

logic clk;

initial begin
	clk = 1'b0;
	parking_status = 3'd0;
	work_hour = 4'd0;
	work_day_expired = 1'b0;
	rush_start = 4'd0;
	rush_start_exist = 1'b0;
	rush_end = 4'd0;
	rush_end_exist = 1'b0;
	car_track_ram_addr = 3'd0;
	car_track_ram_out = 16'd0;
	repeat(2) @(posedge clk);
	parking_status = 3'd1;
	repeat(2) @(posedge clk);
	work_hour = 4'd1;
	
	repeat(2) @(posedge clk);
	parking_status = 3'd2;
	repeat(2) @(posedge clk);
	work_hour = 4'd2;
	
	repeat(2) @(posedge clk);
	parking_status = 3'd7;
	rush_start = 4'd2;
	rush_start_exist = 1'b1;
	repeat(2) @(posedge clk);
	work_hour = 4'd3;
	
	repeat(2) @(posedge clk);
	parking_status = 3'd2;
	repeat(2) @(posedge clk);
	work_hour = 4'd4;
	
	repeat(2) @(posedge clk);
	parking_status = 3'd1;
	repeat(2) @(posedge clk);
	work_hour = 4'd5;
	
	repeat(2) @(posedge clk);
	parking_status = 3'd0;
	rush_end = 4'd5;
	rush_end_exist = 1'b1;
	
	repeat(4) @(posedge clk);
	work_hour = 4'd6;
	
	repeat(4) @(posedge clk);
	work_hour = 4'd7;
	
	repeat(4) @(posedge clk);
	work_day_expired = 1'b1;
	@(posedge clk);
	car_track_ram_addr = 3'd7;
	car_track_ram_out = 2'd3;
	@(posedge clk);
	car_track_ram_addr = 3'd6;
	car_track_ram_out = 2'd3;
	@(posedge clk);
	car_track_ram_addr = 3'd5;
	car_track_ram_out = 2'd3;
	@(posedge clk);
	car_track_ram_addr = 3'd4;
	car_track_ram_out = 2'd3;
	@(posedge clk);
	car_track_ram_addr = 3'd3;
	car_track_ram_out = 2'd3;
	@(posedge clk);
	car_track_ram_addr = 3'd2;
	car_track_ram_out = 2'd3;
	@(posedge clk);
	car_track_ram_addr = 3'd1;
	car_track_ram_out = 2'd2;
	@(posedge clk);
	car_track_ram_addr = 3'd0;
	car_track_ram_out = 2'd1;
	
	repeat(5) @(posedge clk);
	$stop;
end

always #10 clk = ~clk;


display dut(
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

endmodule