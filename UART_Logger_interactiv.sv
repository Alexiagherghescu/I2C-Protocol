module UART_logger_interactiv
(
    input logic rx,up_button, down_button, reset_button,
    input logic clock,reset,
    input logic [11:0] temp_converted,
    output logic tx
);

wire [7:0]  rx_dout, rx_fifo_dout,tx_fifo_dout, data;
wire s_tick, rx_done, rd_en, full_tx, rd_en_tx;
wire rst_cnt, up_cnt, down_cnt;
wire inc, dec, rst;
wire message_temp,  message_inc, message_dec, message_reset, message_help,message_error, message_status;
wire data_valid;
wire w1, w2, w3;
wire [15:0] led;
wire [23:0] temp_val;
wire [31:0] ascii_val;
wire empty_fifo,emty_fifo_tx;


assign w1=(up_cnt||inc);
assign w2=(down_cnt||dec);
assign w3= (rst_cnt||rst);


RX  #(.BITS('d8))
RX
(
    .rx(rx),
    .s_tick(s_tick),
    .rx_dout(rx_dout),
    .rx_done(rx_done),
    .reset(reset),
    .clock(clock)  
);
fifo_generator_0 fifo_RX (
  .clk(clock),     
  .srst(reset),   
  .din(rx_dout),     
  .wr_en(rx_done), 
  .rd_en(rd_en), 
  .dout(rx_fifo_dout),   
  .full(),   
  .empty(empty_fifo)  
);

BaudRate #(.BaudRate('d9600),
          .freq ('d100000000),
          .BITS('d16))
 BaudRate
(
    .done(s_tick),
    .reset(reset), 
    .clock(clock)
);
command command
(
     .command(rx_fifo_dout),
     .reset(reset),
     . empty_fifo(empty_fifo), 
     . read_en(rd_en),
     .clock(clock),
     .signal_inc(inc), 
     .signal_dec(dec), 
     .signal_reset(rst), 
     .message_temp(message_temp),
     .message_inc(message_inc), 
     .message_dec(message_dec), 
     .message_reset(message_reset), 
     .message_help(message_help),
     .message_error(message_error), 
     .message_status(message_status)
);

debouncer #(.not_noise(5))
debouncer_up
(
   .in(up_button), 
   .clock(clock),
   .out(up_cnt)
);


debouncer #(.not_noise(5))
debouncer_down
(
   .in(down_button), 
   .clock(clock),
   .out(down_cnt)
);

debouncer #(.not_noise(5))
debouncer_reset
(
   .in(reset_button), 
   .clock(clock),
   .out(rst_cnt)
);

counter16b counter16b    
(                        
   .up(w1),          
   .down(w2),      
   .reset(w3),      
   .clock(clock),        
   .out(led )            
);  
   
binary_to_ascii binary_to_ascii
(
    .counter_val(led),
    .clock(clock), 
    .reset(reset),
    .ascii_val(ascii_val),
    .temp_val(temp_val),
    .temp_converted(temp_converted)
);            

FSM_mesja FSM_mesja
(
  .full(full_tx), 
  .message_inc(w1), 
  .message_dec(w2), 
  .message_reset(w3), 
  .message_help(message_help),
  .message_error(message_error),
  .message_status(message_status), 
  .message_temp(message_temp),
  .clock(clock), 
  .reset(reset),
  .ascii_val(ascii_val),  
  .temp_val(temp_val),
  .data(data),
  .data_valid(data_valid),
  .start_bit()
);


fifo_generator_0 fifo_TX (  
  .clk(clock),              
  .srst(reset),             
  .din(data),            
  .wr_en(data_valid),          
  .rd_en(rd_en_tx),            
  .dout(tx_fifo_dout),              
  .full(full_tx),                  
  .empty(emty_fifo_tx)                  
);  


TX #(.BITS('d8))        
TX                      
(                       
  .tx(tx),
  .tx_done(rd_en_tx)   ,           
  .s_tick(s_tick),      
  .tx_din(tx_fifo_dout),     
  .tx_start(~emty_fifo_tx),   
  .reset(reset),        
  .clock(clock)         
);   
                                           

                                           
endmodule