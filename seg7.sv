module seg7
(
    input logic [3:0] in,
    input logic point,
    output logic [7:0] segmente
);

always_comb 
begin
case(in)
    4'd0: segmente=8'b11000000;
    4'd1: segmente=8'b11111001;
    4'd2: segmente=8 'b10100100;
    4'd3: segmente=8 'b10110000;
    4'd4: segmente=8 'b10011001;
    4'd5: segmente=8 'b10010010;
    4'd6: segmente=8 'b10000010;
    4'd7: segmente=8 'b11111000;
    4'd8: segmente=8 'b10000000;
    4'd9: segmente=8 'b10010000;
    4'd10:segmente=8 'b11000110;
 default: segmente=8 'b11111111;
endcase

    if(point==1)
        begin
            segmente[7]=1'b0;
        end
end

endmodule