module b4_hex_val 
(
       input logic [3:0] bits4,
       input logic clock, reset,
       output logic [7:0] hex_val
);

always @(posedge clock)
begin
    if(reset==1)
    begin
        hex_val<=0;
    end
    else 
        begin
        if ((bits4>='d0) && (bits4<='d9))
            begin
               hex_val<= bits4 +'d48; 
            end
        else 
        begin
            if((bits4>='d10) && (bits4<='d16))
                begin
                    hex_val<= bits4+ 'd55;
                end
        end
        end
end

endmodule