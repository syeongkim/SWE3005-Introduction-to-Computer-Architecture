`timescale 100ps / 100ps

module detector_010 (clk, reset, in, out);

input clk, in, reset;
output reg out;

reg[1:0] scurr, snext;

parameter[1:0] Init = 2'b00, Got0 = 2'b01, Got01 = 2'b10, Got010 = 2'b11;

always @ (in, scurr) begin
    case (scurr)
        Init: if (in == 1) snext = Init; else snext = Got0;
        Got0: if (in == 1) snext = Got01; else snext = Got0;
        Got01: if (in == 1) snext = Init; else snext = Got010;
        Got010: if (in == 1) snext = Got01; else snext = Got0;
    endcase
end

always @ (scurr) begin
    if (scurr == Got010) out = 1; else out = 0;
end

always @ (posedge clk) begin 
    if (reset == 1) scurr <= Init; else scurr <= snext;
end

endmodule
