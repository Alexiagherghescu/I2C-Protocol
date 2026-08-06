module RX #(parameter BITS='d8)
(
   input logic rx, 
   input logic s_tick, reset, clock ,
   output logic [BITS-1:0] rx_dout,
   output logic rx_done
);
typedef enum logic [1:0] {
        IDLE  ,
        START ,
        RECEPTIE  ,
        STOP  
    } state_t;
 
 state_t state=IDLE;
 
 
 logic [BITS-1:0] shiftreg = '0;
 logic [$clog2(BITS)-1:0] bit_count= '0;
 logic [3:0] tick_count= '0;
 
 
 always @(posedge clock) begin
 
 if (reset==1) begin
     shiftreg <= '0;
     bit_count<= '0; 
     tick_count<='0;
     state<=IDLE;
     rx_dout<='0;
     rx_done<='0;
 end
 
 else begin
 rx_done<=0;
    if (s_tick==1)
        begin
        case(state)
        
        IDLE: begin
        
        if (rx==0) begin
                    state<=START;
                    tick_count<=0;
                   end
        else begin
                state<=IDLE;
             end
        end
        
        
        START: begin
        if(tick_count==7) 
             begin 
                  if(rx==0) 
                        begin
                         state<= RECEPTIE; 
                         bit_count<=0;
                         tick_count<=0;      
                        end
                  else begin
                  state<= IDLE;
                  end
             end
        else begin
                tick_count<= tick_count + 1;
             end
        end
        
        RECEPTIE: 
        begin
        if (tick_count==15) begin
        
         shiftreg[bit_count]<= rx;
         
        begin
            if(bit_count==BITS-1) 
                             begin
                                state<= STOP;
                                bit_count<=0;
                                tick_count<=0;
                             end
            else begin
                    bit_count<=bit_count+1;
                    tick_count<=0;
                 end
        end
        end
        else begin
         tick_count<= tick_count +1;
        end
        end
        
        STOP:
        begin
            if(tick_count==15)
            begin
                 if(rx==1) 
                     begin
                         rx_done<=1;
                         rx_dout<= shiftreg;
                         state<=IDLE;
                     end 
                  else begin
                       rx_dout<=0;
                       state<= IDLE;  
                       end                   
             end
             else begin
                    tick_count<=tick_count+1;
                  end
        end
        endcase
        
        end
 
 end
 end


endmodule