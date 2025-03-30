// endoder module, encode the data in hex format to the code for 7-segment display
// 7-segment display codebook
// common anode
// segment turned on --> applying low logic
// segment turned off --> applying high logic

///////////////
//     0
//    ---
// 5 |   | 1
//   | 6 |
//    ---
// 4 |   | 2
//   |   |
//    ---
//     3
//////////////

// Author: BLR, University of Washington
module encoder(
	input logic [3:0] dataIn, // data to be displayed in hex format
	output logic [6:0] disCode // encoded data, which outputs directly to 7-segment display
);
// codebook 
always_comb begin
	case(dataIn)
		4'h0: disCode = 7'b100_0000; // '0'
		4'h1: disCode = 7'b111_1001; // '1'
		4'h2: disCode = 7'b010_0100; // '2'
		4'h3: disCode = 7'b011_0000; // '3'
		4'h4: disCode = 7'b001_1001; // '4'
		4'h5: disCode = 7'b001_0010; // '5'
		4'h6: disCode = 7'b000_0010; // '6'
		4'h7: disCode = 7'b111_1000; // '7'
		4'h8: disCode = 7'b000_0000; // '8'
		4'h9: disCode = 7'b001_0000; // '9'
		4'ha: disCode = 7'b000_1110; // 'F'
		4'hb: disCode = 7'b100_0001; // 'U'
		4'hc: disCode = 7'b100_0110; // 'L'
		4'hd: disCode = 7'b011_1111; // '-'
		4'he: disCode = 7'b111_1111; // ' '
		4'hf: disCode = 7'b111_1111; // ' '
	endcase
end

endmodule


// testbench for encoder module
// the data to be displayed increases by 1 at each positive edge of clock, and will be automatically overflow.
`timescale 1ns/1ps
module encoder_testbench();

logic clk; // clock signal
logic rstn; // reset signal, active low
logic [3:0] dataIn; // input data of encoder module
logic [6:0]	disCode; // output data of encoder module

// signals initialization, simulation time is 500ns
initial begin
	clk = 1'b0;
	rstn = 1'b0;
	dataIn = 4'd0;
	#100
	rstn = 1'b1;
	#400
	$finish;
end

always #10 clk = ~clk; // generates a 50MHz clock

// dataIn increases by 1, traversing all possible input values
always@(posedge clk or negedge rstn)begin
	if(~rstn)begin
		dataIn <= 4'd0;
	end
	else begin
		dataIn <= dataIn + 4'd1;
	end
end

// instantiation of encoder module
encoder encoder_dut(
	.dataIn				(dataIn),
	.disCode			(disCode)
);
endmodule
