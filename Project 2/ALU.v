`timescale 100ps / 100ps

module ALU(
    input [15:0] A,
    input [15:0] B,
    input Cin,
    input [3:0] OP,
    output reg Cout,
    output reg [15:0] C
    );
    
    always @(*) begin
        Cout = 0;

        case(OP)
            4'b0000: begin
                {Cout, C} = A + B + Cin;
            end
            4'b0001: begin
                C = A - (B + Cin);
                Cout = ({1'b0, A} < ({1'b0, B} + Cin)) ? 1 : 0;
            end
            4'b0010: C = A;
            4'b0011: C = ~(A & B);
            4'b0100: C = ~(A | B);
            4'b0101: C = ~(A ^ B);
            4'b0110: C = ~A;
            4'b0111: C = A & B;
            4'b1000: C = A | B;
            4'b1001: C = A ^ B;
            4'b1010: C = A >> 1;
            4'b1011: C = $signed(A) >>> 1;
            4'b1100: C = {A[0], A[15:1]};
            4'b1101: C = A << 1;
            4'b1110: C = $signed(A) <<< 1;
            4'b1111: C = {A[14:0], A[15]};
            default: C = 16'h0000;
        endcase
    end

endmodule