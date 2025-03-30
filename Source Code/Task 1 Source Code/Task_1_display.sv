// display module, count how many car in lot,
// CLOCK_50 is the clock input
// RSTN is the reset
// cntNum is the current car number
// HEX0,HEX1,HEX2,HEX3,HEX4,HEX5
// Author: BLR, University of Washington
module display(
    input logic CLOCK_50,
    input logic RSTN,
    input logic [4:0] cntNum,
    output logic [6:0] HEX0,
    output logic [6:0] HEX1,
    output logic [6:0] HEX2,
    output logic [6:0] HEX3,
    output logic [6:0] HEX4,
    output logic [6:0] HEX5
);
// data to be displayed
logic [4:0] bcd0,bcd1,bcd2,bcd3,bcd4,bcd5;
// gets the data to be displayed
always_ff@(posedge CLOCK_50 or negedge RSTN)begin
    if(~RSTN)begin // reset state, no display info
        bcd0 <= 5'd31;
        bcd1 <= 5'd31;
        bcd2 <= 5'd31;
        bcd3 <= 5'd31;
        bcd4 <= 5'd31;
        bcd5 <= 5'd31;
    end
    else begin
        if(cntNum == 5'd0)begin // display 'CLEAR' & '0'
            bcd0 <= 5'd0;
            bcd1 <= 5'd27;
            bcd2 <= 5'd10;
            bcd3 <= 5'd14;
            bcd4 <= 5'd21;
            bcd5 <= 5'd12;
        end
        else if(cntNum == 5'd25)begin // display 'FULL' & '25'
            bcd0 <= 5'd5;
            bcd1 <= 5'd2;
            bcd2 <= 5'd21;
            bcd3 <= 5'd21;
            bcd4 <= 5'd30;
            bcd5 <= 5'd15;
        end
        else begin // display only number
            bcd2 <= 5'd31;
            bcd3 <= 5'd31;
            bcd4 <= 5'd31;
            bcd5 <= 5'd31;
            if(cntNum >= 5'd20)begin
                bcd0 <= cntNum - 5'd20;
                bcd1 <= 5'd2;
            end
            else if(cntNum >= 5'd10)begin
                bcd0 <= cntNum - 5'd10;
                bcd1 <= 5'd1;
            end
            else begin
                bcd0 <= cntNum;
                bcd1 <= 5'd31;
            end
        end
    end
end
// data format convert
encoder encoder_inst0(
    .bcdNum         (bcd0),
    .codeNum        (HEX0)
);
// data format convert
encoder encoder_inst1(
    .bcdNum         (bcd1),
    .codeNum        (HEX1)
);
// data format convert
encoder encoder_inst2(
    .bcdNum         (bcd2),
    .codeNum        (HEX2)
);
// data format convert
encoder encoder_inst3(
    .bcdNum         (bcd3),
    .codeNum        (HEX3)
);
// data format convert
encoder encoder_inst4(
    .bcdNum         (bcd4),
    .codeNum        (HEX4)
);
// data format convert
encoder encoder_inst5(
    .bcdNum         (bcd5),
    .codeNum        (HEX5)
);

endmodule