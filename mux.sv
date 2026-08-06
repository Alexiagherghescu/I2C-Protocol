module mux
(
    input logic [1:0] sel,
    input logic [3:0] unit, zeci, zecimala,C,
    output logic [3:0] out
);

always_comb
begin
    case(sel)
    2'd0: out= zeci;
    2'd1: out= unit;
    2'd2: out= zecimala;
    2'd3: out=C;
    default : out=4'b0000;
    endcase
end
endmodule