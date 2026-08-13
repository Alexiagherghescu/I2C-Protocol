module reading_timer #(parameter clock_freq=100000000,
                        parameter reading_time_per_sec=2)
(
    input logic clock, reset,
    output logic done
);

localparam Final_Value= clock_freq/reading_time_per_sec;
logic [$clog2(Final_Value)-1:0] counter;

always @(posedge clock)
begin
    if(reset==1)
        begin
            counter<=0;
            done<=1'b0;
        end
    else
        begin
        if(counter==Final_Value)
            begin
                done<=1'b1;
                counter<=0;  
            end
         else
            begin
                counter<=counter+1;
                done<=1'b0;
            end
        end


end


endmodule