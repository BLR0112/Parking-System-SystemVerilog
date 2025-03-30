//Jiawen Liu
//12/03/2024
//EE 371
//Lab #6, Task 1

// counter module, count how many car in lot,
// CLOCK_50 is the clock input
// RSTN is the reset
// INC asserts, increase the car number
// DEC asserts, decrease the car number
// cntNum is the current car number
// Author: BLR, University of Washington
module counter #(
    parameter MAX = 5'd25
)(
    input logic CLOCK_50,
    input logic RSTN,
    input logic INC,
    input logic DEC,
    output logic [4:0] cntNum
);

logic [4:0] cnt;
// counts the car number 
always_ff@(posedge CLOCK_50 or negedge RSTN)begin
    if(~RSTN)begin
        cnt <= 5'd0;
    end
    else if(INC && (cnt < MAX))begin // lot is not full, car number can increase
        cnt <= cnt + 5'd1;
    end
    else if(DEC && (cnt > 5'd0))begin // lot is not empty, cat r number can decrease
        cnt <= cnt - 5'd1;
    end
    else begin
        cnt <= cnt;
    end
end
assign cntNum = cnt;
endmodule