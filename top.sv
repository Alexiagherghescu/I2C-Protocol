module top
(
    input logic rx , reset, clock, up_button, down_button, reset_button,
    inout logic sda,
    output logic scl, tx, led_sign,
    output logic [7:0] segmente,
    output logic [4:0] digits,
    output logic [11:0] ctrl_senzor_temp
);


localparam addr_slave= 'h4B;
localparam addr_reg= 'h00;
localparam Celsius='d10;

wire en_i2c, done_tick;
wire [15:0] data_out;
wire [1:0] sel_mux;
wire [3:0] out_mux;

wire point;
assign point= (sel_mux=='d1) ? 1'b1: 1'b0;

wire [3:0] w_zeci, w_unit, w_zecimala;
wire [11:0] temp_converted;
assign temp_converted= {w_zeci, w_unit, w_zecimala};


UART_logger_interactiv UART_logger_interactiv
(
    .rx(rx),
    .up_button(up_button), 
    .down_button(down_button), 
    .reset_button(reset_button),
    .clock(clock),
    .reset(reset),
    .temp_converted(temp_converted),
    .tx(tx)
);

i2c_master i2c_master         
(    
    .clock(clock), 
    .reset(reset), 
    .en(en_i2c), 
    .done_tick(done_tick),
    .data_out(data_out),  
    .addr_slave(addr_slave),
    .addr_reg(addr_reg),
    .scl(scl),
    .rw(), 
    .sda(sda) 
);



reading_timer #(.clock_freq(100000000),
                .reading_time_per_sec(10))
reading_timer
(
    .clock(clock), 
    .reset(reset),
    .done(en_i2c)
);



clock_divider #(.CLOCK_FREQ(100000000),
                .I2C_FREQ (100000),
                .sample(10))
clock_divider
(
    .clock(clock), 
    .reset(reset),
    .done_tick(done_tick)
);

ctrl_senzor(
   .data_out(data_out),
   .clock(clock), 
   .reset(reset),
   .sign(led_sign),
   .ctrl_senzor_temp(ctrl_senzor_temp)
);

bcd_temp(
    .ctrl_senzor_temp(ctrl_senzor_temp),
    .zeci(w_zeci), 
    .unit(w_unit), 
    .zecimala(w_zecimala)
);

timer #(.limit(17'd99999)) 
timer_mux
(
    .clock(clock),
    .sel(sel_mux)
);

mux mux
(
    .sel(sel_mux),
    .unit(w_unit), 
    .zeci(w_zeci), 
    .C(Celsius),
    .zecimala(w_zecimala),
    . out(out_mux)
);

seg7 seg7
(
    .in(out_mux),
    .point(point),
    .segmente(segmente)
);


cifra_sel cifra_sel
(
    .in(sel_mux),
    .out(digits)
);
endmodule