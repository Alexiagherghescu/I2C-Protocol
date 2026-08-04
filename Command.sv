module command
(
    input logic [7:0] command,
    input logic empty_fifo, 
    output logic read_en,
    input logic reset, clock,
    output logic signal_inc, signal_dec, signal_reset, 
    output logic message_temp, message_inc, message_dec, message_reset, message_help,message_error, message_status
);
logic data_valid; 
always @(posedge clock)
begin
    if(reset==1)
        begin
            signal_inc<=0; 
            signal_dec<=0; 
            signal_reset<=0;                                               
            message_inc<=0; 
            message_dec<=0; 
            message_reset<=0; 
            message_help<=0;
            message_error<=0; 
            message_status<=0; 
            message_temp<=0;
        end
    else 
        begin
            signal_inc<=0; 
            signal_dec<=0; 
            signal_reset<=0;                                               
            message_inc<=0; 
            message_dec<=0; 
            message_reset<=0; 
            message_help<=0;
            message_error<=0; 
            message_status<=0; 
            message_temp<=0;
            
            if(empty_fifo==0 && read_en==0)
                begin
                    read_en<=1'b1;
                end 
           else begin
                    read_en<=1'b0;
                end
          data_valid<=read_en;      
                
        if (data_valid==1'b1)
        begin
        case(command)
        
        "T","t":                  
           begin                  
               message_temp<=1; 
           end                    
        
        
        "I","i" : 
            begin
                signal_inc<=1;
                message_inc<=1;  
            end
            
        "D", "d":
            begin
                signal_dec<=1;
                message_dec<=1; 
            end
        
         "R", "r":
            begin
                signal_reset<=1 ; 
                message_reset<=1; 
            end
         
          "S","s":
             begin
                 message_status<=1; 
             end
             
           "?" :
               begin
                 message_help<=1;   
               end
           default:
           begin
                message_error<=1;
           end
           
        endcase
        end
        end

end

endmodule
