module BaudRate #(parameter BaudRate='d9600,
                  parameter freq= 'd100000000,
                  parameter BITS= 'd16)
( 
    input logic reset, clock,
    output logic done
);

localparam Final_Value= freq/(16*BaudRate) -1;
logic [BITS-1:0] count='d0;
always @(posedge clock)
begin
 if (reset==1) begin
        done<=0;
        count<=0;
     end 
 else begin    
    if(count== Final_Value) begin
        done<=1;
        count<=0;
    end
    else begin
    count<=count+1;
    done<=0;
    end
end
end

endmodule
