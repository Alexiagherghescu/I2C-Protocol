module counter16b
(
    input logic up, down, reset, clock,
    output logic [15:0] out
);

always_ff @(posedge clock)
begin
if(reset==1)
  out<= 'b0;
  else
  begin
    if(up==1 && down==0)
    out<= out+1;
      else
      begin
       if(down==1 && up==0)
       out<= out-1;
      end
  end 

end

endmodule