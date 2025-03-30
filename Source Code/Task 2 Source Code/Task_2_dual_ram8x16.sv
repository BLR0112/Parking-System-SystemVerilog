// dual_ram8x16 module, implements dual port RAM,
// clk is the clock input
// wr_addr is the write address
// wr_data is the write data
// wr_en is the write enable signal
// rd_addr is the read address
// rd_data is the read out data
// Author: BLR, University of Washington
module dual_ram8x16(
	input logic clk,
	input logic [2:0] wr_addr,
	input logic [15:0] wr_data,
	input logic wr_en,
	input logic [2:0] rd_addr,
	output logic [15:0] rd_data
);
// defines the ram memory 8x16
logic [15:0] ram_mem [0:7];

/* initial begin
	ram_mem[0] = 'd0;
	ram_mem[1] = 'd0;
	ram_mem[2] = 'd0;
	ram_mem[3] = 'd0;
	ram_mem[4] = 'd0;
	ram_mem[5] = 'd0;
	ram_mem[6] = 'd0;
	ram_mem[7] = 'd0;
end */
// ram write
always_ff @(posedge clk)begin
	if(wr_en)begin
		ram_mem[wr_addr] <= wr_data;
	end
end
// ram read
assign rd_data = ram_mem[rd_addr];

endmodule

//////////////// test bench ////////////////
`timescale 1ns/1ps
module dual_ram8x16_tb();

logic clk;
logic [2:0] wr_addr;
logic [15:0] wr_data;
logic wr_en;
logic [2:0] rd_addr;
logic [15:0] rd_data;

initial begin
	clk = 1'b0;
	rd_addr = 'd0;
	wr_en = 1'b0;
	wr_addr = 'd0;
	wr_data = 'd0;
	repeat(5) @(posedge clk);
	ram_write();
	@(posedge clk);
	ram_read();
	ram_read();
	ram_read();
	ram_read();
	ram_read();
	ram_read();
	ram_read();
	ram_read();
	repeat(5) @(posedge clk);
	$stop;
end

always #10 clk = ~clk;

dual_ram8x16 dut(
	.clk				(clk),
	.wr_addr			(wr_addr),
	.wr_data			(wr_data),
	.wr_en				(wr_en),
	.rd_addr			(rd_addr),
	.rd_data			(rd_data)
);

task ram_write();
	@(posedge clk)begin
		wr_en = 1'b0;
	end
	@(posedge clk)begin
		wr_addr = 'd0;
		wr_data = 'd1;
		wr_en = 1'b1;
	end
	@(posedge clk)begin
		wr_addr = 'd1;
		wr_data = 'd2;
		wr_en = 1'b1;
	end
	@(posedge clk)begin
		wr_addr = 'd2;
		wr_data = 'd3;
		wr_en = 1'b1;
	end
	@(posedge clk)begin
		wr_addr = 'd3;
		wr_data = 'd4;
		wr_en = 1'b1;
	end
	@(posedge clk)begin
		wr_addr = 'd4;
		wr_data = 'd5;
		wr_en = 1'b1;
	end
	@(posedge clk)begin
		wr_addr = 'd5;
		wr_data = 'd6;
		wr_en = 1'b1;
	end
	@(posedge clk)begin
		wr_addr = 'd6;
		wr_data = 'd7;
		wr_en = 1'b1;
	end
	@(posedge clk)begin
		wr_addr = 'd7;
		wr_data = 'd8;
		wr_en = 1'b1;
	end
	@(posedge clk)begin
		wr_en = 1'b0;
	end
endtask

task ram_read();
	@(posedge clk)begin
		rd_addr = rd_addr + 'd1;
	end
endtask

endmodule