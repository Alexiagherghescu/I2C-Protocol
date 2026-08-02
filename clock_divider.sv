module clock_divider #(parameter CLOCK_FREQ=1000000,
                       parameter I2C_FREQ =100000,
                       parameter sample=4)
(
    input logic clock, reset,
    output logic done_tick
);


localparam Tick_FREQ     = I2C_FREQ*sample;
localparam Final_Val     = CLOCK_FREQ/Tick_FREQ;
localparam Counter_Width = $clog2(Final_Val);

logic [Counter_Width-1:0] counter;

always @(posedge clock)
begin
    if(reset==1)
    begin
        counter   <= 0;
        done_tick <=1'b0;
    end
    else
    begin
        if(counter==Final_Val-1)
        begin
            counter   <= 0;
            done_tick <=1'b1;
        end
        else
        begin
            counter   <=counter+1;
            done_tick <=0;
        end
    end


end

endmodule