`timescale 1ns / 1ps
     
module tb_i2c_master();

    logic clock;
    logic reset;
    logic en;
    logic done_tick;

    logic [6:0] addr_slave;
    logic [6:0] addr_reg;

    wire [15:0] data_out;
    wire        scl;
    wire        rw;
    wire        sda;

 

    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    initial begin
        done_tick = 0;
        forever begin
            #240;
            done_tick = 1;
            #10;
            done_tick = 0;
        end
    end

    i2c_master dut_master (
        .clock(clock),
        .reset(reset),
        .en(en),
        .done_tick(done_tick),
        .data_out(data_out),
        .addr_slave(addr_slave),
        .addr_reg(addr_reg),
        .scl(scl),
        .rw(rw),
        .sda(sda)
    );

    i2c_slave_sensor #(
        .SLAVE_ADDR(7'h4B),
        .TEMP_DATA(16'h1980)
    ) slave_sensor (
        .scl(scl),
        .sda(sda)
    );

    initial begin
        addr_slave = 7'h4B;
        addr_reg   = 7'h00;
        
        reset = 1;
        en    = 0;
        #100;

        reset = 0;
        #100;

        en = 1;
        #1000; 
        en = 0;

        #350000;
        $finish;
    end
endmodule