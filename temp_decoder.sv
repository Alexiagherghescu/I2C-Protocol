
     module ctrl_senzor(
    input logic [15:0] data_out,
    input logic clock, reset,
    output logic sign,
    output logic [11:0] ctrl_senzor_temp
);

logic [12:0] temp;

always @(posedge clock)
begin
    if(reset==1)
        begin
        ctrl_senzor_temp<=0;
        sign<=1'b0;
        end
    else 
        begin
        
        sign<=data_out[15];
        temp<=data_out[15:3];
        
        if(data_out[15]==0)
            begin
                ctrl_senzor_temp<=(data_out[15:3]*10)>>4;   
            end
        else 
            begin
                ctrl_senzor_temp<=((data_out[14:3]+1'b1)-'d4096)>>4; 
            end
         
        end
     

end
endmodule