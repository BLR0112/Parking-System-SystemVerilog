//Jiawen Liu
//12/03/2024
//EE 371
//Lab #6, Task 1

// paking_lot_fsm module, implements FSM of parking lot,
// CLOCK_50 is the clock input
// RSTN used as reset signal
// SIG_A indicates sensor A
// SIG_B indicates sensor B
// ENTER indicates car enter
// EXIT indicates car exit
// Author: BLR, University of Washington
module paking_lot_fsm(
    input logic CLOCK_50,
    input logic RSTN,
    input logic SIG_A,
    input logic SIG_B,
    output logic ENTER,
    output logic EXIT
);
// beat a & b signal, get the positive and negtive edge of a & b signals
// the entering and exting FSMs are triggered by edge of a & b, not logic level
logic [2:0] sig_a_pip,sig_b_pip;
logic sig_a_pos,sig_a_neg;
logic sig_b_pos,sig_b_neg;
// define the states
enum {Init,Blocked_1,Blocked_2,Unblocked} cStateEnter,nStateEnter,cStateExit,nStateExit;
// signals beat
always_ff@(posedge CLOCK_50 or negedge RSTN)begin
    if(~RSTN)begin
        sig_a_pip <= 3'd0;
        sig_b_pip <= 3'd0;
    end
    else begin
        sig_a_pip <= {sig_a_pip[1:0],SIG_A};
        sig_b_pip <= {sig_b_pip[1:0],SIG_B};
    end
end
// edges detect
assign sig_a_pos = (~sig_a_pip[2]) && sig_a_pip[1];
assign sig_a_neg = sig_a_pip[2] && (~sig_a_pip[1]);

assign sig_b_pos = (~sig_b_pip[2] && sig_b_pip[1]);
assign sig_b_neg = sig_b_pip[2] && (~sig_b_pip[1]);
// car entering FSM
always_comb begin
    case(cStateEnter)
        Init:begin // sensor a is blocked
            if(sig_a_pos)begin
                nStateEnter = Blocked_1;
            end
            else begin
                nStateEnter = Init;
            end
        end
        Blocked_1:begin
            if(sig_b_pos)begin // sensor b is blocked
                nStateEnter = Blocked_2;
            end
            else if(sig_a_neg)begin // sensor a is blocked, but car changes direction, leaving lot(not completely entering)
                nStateEnter = Init;
            end
            else begin
                nStateEnter = Blocked_1;
            end
        end
        Blocked_2:begin
            if(sig_a_neg)begin // sensor a is unblocked
                nStateEnter = Unblocked;
            end
            else if(sig_b_neg)begin // sensor b is unblocked, car changes direction, leaving lot(not completely entering)
                nStateEnter = Blocked_1;
            end
            else begin
                nStateEnter = Blocked_2;
            end
        end
        Unblocked:begin
            if(sig_b_neg)begin
                nStateEnter = Init; // car completely enters lot
            end
            else if(sig_a_pos)begin // car changes direction, leaving lot(not completely entering)
                nStateEnter = Blocked_2;
            end
            else begin
                nStateEnter = Unblocked;
            end
        end
    endcase
end

always_ff@(posedge CLOCK_50 or negedge RSTN)begin
    if(~RSTN)begin
        cStateEnter <= Init;
    end
    else begin
        cStateEnter <= nStateEnter;
    end
end

assign ENTER = (cStateEnter == Unblocked) && sig_b_neg;// indicates car completely entering(1 cycle)

// car exiting FSM
always_comb begin
    case(cStateExit)
        Init:begin // b signal is triggered first, sensor b blocked first
            if(sig_b_pos)begin
                nStateExit = Unblocked;
            end
            else begin
                nStateExit = Init;
            end
        end
        Unblocked:begin
            if(sig_a_pos)begin // sensor a is blocked
                nStateExit = Blocked_2;
            end
            else if(sig_b_neg)begin // car changes direction,not exits lot completely
                nStateExit = Init;
            end
            else begin
                nStateExit = Unblocked;
            end
        end
        Blocked_2:begin
            if(sig_b_neg)begin // sensor b is unblocked
                nStateExit = Blocked_1;
            end
            else if(sig_a_neg)begin // car changes direction,not exits lot completely
                nStateExit = Unblocked; 
            end
            else begin
                nStateExit = Blocked_2;
            end
        end
        Blocked_1:begin
            if(sig_a_neg)begin // sensor a is unblocked
                nStateExit = Init;
            end
            else if(sig_b_pos)begin // car changes direction,not exits lot completely
                nStateExit = Blocked_2;
            end
            else begin
                nStateExit = Blocked_1;
            end
        end
    endcase
end

always_ff@(posedge CLOCK_50 or negedge RSTN)begin
    if(~RSTN)begin
        cStateExit <= Init;
    end
    else begin
        cStateExit <= nStateExit;
    end
end

assign EXIT = (cStateExit == Blocked_1) && sig_a_neg;// indicates car completely exiting(1 cycle)

endmodule