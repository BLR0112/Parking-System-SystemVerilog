// control module, implements FSM to find rush hour,
// which describes the state machine of rush hour finding logic
// clk is the clock input
// reset used as reset signal
// slot_empty indicates that parking slot is empty
// slot_full indicates that parking slot is full
// rush_start_valid indicates current work hour is the start of rush hour
// rush_end_valid indicates current work hour is the end of rush hour
// Author: BLR, University of Washington
module control(
	input logic clk,
	input logic reset,
	input logic slot_empty,
	input logic slot_full,
	output logic rush_start_valid,
	output logic rush_end_valid
);

// state difinition
enum {S0,S1,S2,S3,S4,S5} ps,ns; 

always_ff @(posedge clk or posedge reset)begin
	if(reset)begin
		ps <= S0;
	end
	else begin
		ps <= ns;
	end
end

always_comb begin
	ns = S0;
	case(ps)
		S0:begin
			if(slot_empty)begin
				ns = S1;
			end
			else begin
				ns = S0;
			end
		end
		S1:begin // slot is empty
			if(~slot_empty)begin
				ns = S2;
			end
			else begin
				ns = S1;
			end
		end
		S2:begin // slot is not empty and not full
			if(slot_empty)begin
				ns = S1;
			end
			else if(slot_full)begin
				ns = S3;
			end
			else begin
				ns = S2;
			end
		end
		S3:begin // slot is full, start of rush
			if(~slot_full)begin
				ns = S4;
			end
			else begin
				ns = S3;
			end
		end
		S4:begin // slot is not empty
			if(slot_empty)begin
				ns = S5;
			end
			else begin
				ns = S4;
			end
		end
		S5:begin // slot is empty, end of rush
			if(~slot_empty)begin
				ns = S2;
			end
			else begin
				ns = S5;
			end
		end
	endcase
end
// output the control signal for datapath module
always_comb begin
	rush_start_valid = 1'b0;
	rush_end_valid = 1'b0;
	if(ps == S3)begin
		rush_start_valid = 1'b1;
		rush_end_valid = 1'b0;
	end
	else if(ps == S5)begin
		rush_start_valid = 1'b0;
		rush_end_valid = 1'b1;
	end
	else begin
		rush_start_valid = 1'b0;
		rush_end_valid = 1'b0;
	end
end

endmodule

///////////////////// test bench //////////////////////
`timescale 1ns/1ps
module control_tb();
logic clk;
logic reset;
logic slot_empty;
logic slot_full;
logic rush_start_valid;
logic rush_end_valid;

initial begin
	clk = 1'b0;
	reset = 1'b1;
	slot_empty = 1'b1;
	slot_full = 1'b0;
	repeat(5) @(posedge clk);
	reset = 1'b0;
	repeat(5) @(posedge clk);
	slot_empty = 1'b0;
	repeat(5) @(posedge clk);
	slot_empty = 1'b1;
	repeat(5) @(posedge clk);
	slot_empty = 1'b0;
	repeat(5) @(posedge clk);
	slot_full = 1'b1;
	repeat(5) @(posedge clk);
	slot_full = 1'b0;
	repeat(5) @(posedge clk);
	slot_full = 1'b1;
	repeat(5) @(posedge clk);
	slot_full = 1'b0;
	repeat(5) @(posedge clk);
	slot_empty = 1'b1;
	repeat(5) @(posedge clk);
	slot_empty = 1'b0;
	repeat(5) @(posedge clk);
	$stop;
end

always #10 clk = ~clk;

control dut(
	.clk					(clk),
	.reset					(reset),
	.slot_empty				(slot_empty),
	.slot_full				(slot_full),
	.rush_start_valid		(rush_start_valid),
	.rush_end_valid			(rush_end_valid)
);

endmodule