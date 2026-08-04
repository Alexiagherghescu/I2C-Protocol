module binary_to_ascii
(
    input logic [15:0] counter_val,
    input logic [11:0] temp_converted,
    input logic clock, reset,
    output logic [31:0] ascii_val, 
    output logic [23:0] temp_val
);

b4_hex_val b4_hex_val_poz0
(
       .bits4(counter_val[3:0]),
       .clock(clock), 
       .reset(reset),
       .hex_val(ascii_val[7:0])
);


b4_hex_val b4_hex_val_poz1
(
       .bits4(counter_val[7:4]),
       .clock(clock), 
       .reset(reset),
       .hex_val(ascii_val[15:8])
);


b4_hex_val b4_hex_val_poz2
(
       .bits4(counter_val[11:8]),
       .clock(clock), 
       .reset(reset),
       .hex_val(ascii_val[23:16])
);

b4_hex_val b4_hex_val_poz3
(
       .bits4(counter_val[15:12]),
       .clock(clock), 
       .reset(reset),
       .hex_val(ascii_val[31:24])
);

b4_hex_val b4_hex_val_temp0
(
       .bits4(temp_converted[3:0]),
       .clock(clock), 
       .reset(reset),
       .hex_val(temp_val[7:0])
);

b4_hex_val b4_hex_val_temp1
(
       .bits4(temp_converted[7:4]),
       .clock(clock), 
       .reset(reset),
       .hex_val(temp_val[15:8])
);

b4_hex_val b4_hex_val_temp2
(
       .bits4(temp_converted[11:8]),
       .clock(clock), 
       .reset(reset),
       .hex_val(temp_val[23:16])
);

endmodule