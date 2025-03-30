//Jiawen Liu
//12/03/2024
//EE 371
//Lab #6, Task 1

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
    input logic [4:0] bcdNum,
    output logic [6:0] codeNum
);

always_comb begin
    case(bcdNum)
        5'd0: codeNum = 7'b100_0000; // '0'
        5'd1: codeNum = 7'b111_1001; // '1'
        5'd2: codeNum = 7'b010_0100; // '2'
        5'd3: codeNum = 7'b011_0000; // '3'
        5'd4: codeNum = 7'b001_1001; // '4'
        5'd5: codeNum = 7'b001_0010; // '5'
        5'd6: codeNum = 7'b000_0010; // '6'
        5'd7: codeNum = 7'b111_1000; // '7'
        5'd8: codeNum = 7'b000_0000; // '8'
        5'd9: codeNum = 7'b001_0000; // '9'
        5'd10:codeNum = 7'b000_1000; // 'A'
        5'd12:codeNum = 7'b100_0110; // 'C'
        5'd14:codeNum = 7'b000_0110; // 'E'
        5'd15:codeNum = 7'b000_1110; // 'F'
        5'd21:codeNum = 7'b100_0111; // 'L'
        5'd27:codeNum = 7'b000_1000; // 'R'
        5'd30:codeNum = 7'b100_0001; // 'U'
        default:codeNum = 7'b111_1111;
    endcase
end

endmodule