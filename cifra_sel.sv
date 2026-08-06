module cifra_sel
(
    input logic [1:0] in,
    output logic [4:0] out
);

always_comb
begin
    case(in)
    2'd0: out=5'b11110;
    2'd1: out=5'b11101;
    2'd2: out=5'b11011;
    2'd3: out=5'b10111;
    default : out=5'b11111;
    endcase
end

endmodule