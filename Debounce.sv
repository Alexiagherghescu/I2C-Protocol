module debouncer #(parameter not_noise= 650000)
(
    input logic in, clock,
    output logic out
);
logic [19:0] count=0;
logic stare_stabila=0;
logic stare_anterioara=0;

always_ff @(posedge clock)
begin
    if (in!=stare_stabila)
    begin
    if(count==not_noise)
    begin
        stare_stabila<=in;
        count<=0;
    end
    else count<=count+1;
    end
  else count<=0;
  
  stare_anterioara<= stare_stabila;
end
 assign out= (stare_stabila==1 && stare_anterioara==0);


endmodule