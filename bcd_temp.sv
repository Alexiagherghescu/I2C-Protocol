module bcd_temp(
    input logic [11:0] ctrl_senzor_temp,
    output logic [3:0] zeci, unit, zecimala
);

assign zeci= (ctrl_senzor_temp/100)%10;
assign unit= (ctrl_senzor_temp/10)%10;
assign zecimala= (ctrl_senzor_temp/1)%10;

endmodule