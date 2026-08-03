module i2c_master         
(    
    input  logic clock, reset, en, done_tick,
    output logic [15:0] data_out,  
    output logic [6:0] addr_slave,
    output logic [6:0] addr_reg,
    output logic scl,
    output logic rw, 
    inout  wire  sda  
);

logic [15:0] shift_reg;
logic [3:0] bit_count;
logic sda_out;
logic sda_en;
assign sda = sda_en ? sda_out : 1'bz;
logic [1:0] q_tick;

typedef enum logic [4:0]{
    IDLE,
    START_COND,
    TX_SLAVE_ADDR_W,
    RX_ACK_1,
    TX_REG_ADDR,
    RX_ACK_2,
    RESET_COND,
    TX_SLAVE_ADDR_R,
    RX_ACK_3,
    RX_DATA_BYTE_MSB,
    TX_ACK,
    RX_DATA_BYTE_LSB,
    TX_NACK,
    STOP_COND
} state_t;

state_t state = IDLE;

always_ff @(posedge clock) begin
    if (reset) begin
        state<= IDLE;
        scl <= 1'b1;
        sda_en <= 1'b0; 
        sda_out <= 1'b1;
        q_tick <= 0;
        bit_count<= 0;
        data_out <= 16'b0; 
        rw <= 1'b0;
    end else if (done_tick) begin
        
        case (state)
            IDLE: begin
                scl<= 1'b1;
                sda_en<= 1'b0; 
                q_tick<= 0;
                
                if (en) begin
                    state<=START_COND;
                end
            end
            
            START_COND: begin
                sda_en <= 1'b1; 
                case (q_tick)
                    2'd0:  begin scl <=1'b1; sda_out <=1'b1; end      
                    2'd1: begin scl <=1'b1; sda_out <=1'b1; end
                    2'd2: begin scl <=1'b1; sda_out <=1'b0; end 
                    2'd3: begin scl <=1'b1; sda_out <=1'b0; end 
                endcase
                
                if (q_tick == 2'd3) begin
                    q_tick<= 0;
                    bit_count<= 7;
                    shift_reg<= {addr_slave, 1'b0}; 
                    state<= TX_SLAVE_ADDR_W;
                end else begin
                    q_tick<= q_tick + 1;
                end
            end
            
            TX_SLAVE_ADDR_W: begin
                sda_en <= 1'b1;
                case (q_tick)
                    2'd0 : begin 
                    scl <= 1'b0; 
                    sda_out <= shift_reg[bit_count]; 
                    end 
                    
                    2'd1: begin 
                    scl <= 1'b0;
                    sda_out <= shift_reg[bit_count]; 
                     end 
                     
                    2'd2:begin scl <= 1'b1; end 
                    
                    2'd3: begin scl <= 1'b1; end 
                endcase
                
                if (q_tick == 2'd3) begin
                    q_tick<= 0;
                  if (bit_count == 0) 
                    begin
                    state<= RX_ACK_1;
                    end
                    else       begin
                                  bit_count <= bit_count - 1;
                               end
                end else begin
                    q_tick <= q_tick + 1;
                end
            end
            
            RX_ACK_1: begin
                sda_en <= 1'b0; 
                case (q_tick)
                    2'd0: begin scl <= 1'b0; end
                    2'd1: begin scl <= 1'b0; end
                    2'd2:begin scl <= 1'b1; end 
                    2'd3: begin scl <= 1'b1; end 
                endcase
                
                if (q_tick == 2'd3) begin
                    q_tick <= 0;
                    bit_count<= 7;
                    shift_reg<= addr_reg; 
                    state <= TX_REG_ADDR;
                end else begin
                    q_tick<= q_tick + 1;
                end
            end
            
            TX_REG_ADDR: begin
                sda_en <= 1'b1;
                case (q_tick)
                    2'd0: begin 
                    scl <= 1'b0;
                    sda_out <= shift_reg[bit_count]; 
                    end 
                    2'd1: begin
                     scl <= 1'b0; 
                     sda_out <= shift_reg[bit_count]; 
                    end 
                    2'd2: begin scl <= 1'b1; end 
                    2'd3: begin scl <= 1'b1; end 
                endcase
                
                if (q_tick == 2'd3) begin
                    q_tick <= 0;
                    if (bit_count == 0) 
                    begin
                    state <= RX_ACK_2;
                    end
                    else               
                        begin
                             bit_count <= bit_count - 1;
                        end
                end else begin
                    q_tick <= q_tick + 1;
                end
            end
            
            RX_ACK_2: begin
                sda_en <= 1'b0;
                case (q_tick)
                    2'd0: begin scl <= 1'b0; end
                    2'd1: begin scl <= 1'b0; end
                    2'd2: begin scl <= 1'b1; end
                    2'd3: begin scl <= 1'b1; end 
                endcase
                
                if (q_tick == 2'd3) begin
                    q_tick<= 0;
                    state<= RESET_COND;
                end else begin
                    q_tick <= q_tick + 1;
                end
            end
            
            RESET_COND: begin
                sda_en <= 1'b1;
                case (q_tick)
                    2'd0: begin scl <= 1'b0; sda_out <= 1'b1; end 
                    2'd1: begin scl <= 1'b1; sda_out <= 1'b1; end 
                    2'd2: begin scl <= 1'b1; sda_out <= 1'b0; end 
                    2'd3: begin scl <= 1'b1; sda_out <= 1'b0; end 
                endcase
                
                if (q_tick == 2'd3) begin
                    q_tick    <= 0;
                    bit_count <= 7;
                    shift_reg <= {addr_slave, 1'b1}; 
                    state     <= TX_SLAVE_ADDR_R;
                end else begin
                    q_tick <= q_tick + 1;
                end
            end
            
            TX_SLAVE_ADDR_R: begin
                sda_en <= 1'b1;
                case (q_tick)
                    2'd0: 
                    begin 
                    scl <= 1'b0; 
                    sda_out <= shift_reg[bit_count]; 
                    end 
                    2'd1: 
                    begin                              
                    scl <= 1'b0;                       
                    sda_out <= shift_reg[bit_count];   
                    end                                
                    2'd2: begin scl <= 1'b1; end 
                    2'd3: begin scl <= 1'b1; end 
                endcase
                
                if (q_tick == 2'd3) begin
                    q_tick <= 0;
                    if (bit_count == 0) begin
                    state <= RX_ACK_3;
                    end
                    else              
                    begin  
                    bit_count <= bit_count - 1;
                    end
                end else begin
                    q_tick <= q_tick + 1;
                end
            end
            
            RX_ACK_3: begin
                sda_en <= 1'b0;
                case (q_tick)
                    2'd0:  begin scl <= 1'b0; end
                    2'd1: begin scl <= 1'b0; end
                    2'd2: begin scl <= 1'b1; end 
                    2'd3: begin scl <= 1'b1; end 
                endcase
                
                if (q_tick == 2'd3) begin
                    q_tick <= 0;
                    bit_count <= 7;
                    state <= RX_DATA_BYTE_MSB;
                end else begin
                    q_tick <= q_tick + 1;
                end
            end
            
            RX_DATA_BYTE_MSB: begin
                sda_en <= 1'b0; 
                case (q_tick)
                    2'd0:  begin scl <= 1'b0; end 
                    2'd1: begin scl <= 1'b0; end 
                    2'd2: begin 
                        scl <= 1'b1; 
                        shift_reg[bit_count+8] <= sda; 
                    end
                    2'd3: begin scl <= 1'b1; end 
                endcase
                
                if (q_tick == 2'd3) begin
                    q_tick <= 0;
                    if (bit_count == 0) 
                    begin
                    state <= TX_ACK; 
                    end
                    else                
                    begin
                    bit_count <= bit_count - 1;
                    end
                end 
                    else
                     begin
                        q_tick <= q_tick + 1;
                    end
            end
            
            TX_ACK:
            begin
                sda_en <= 1'b1;
                case (q_tick)
                    2'd0: begin 
                        scl <= 1'b0; 
                        sda_out <= 1'b0; 
                    end 
                    2'd1: begin 
                        scl <= 1'b0; 
                        sda_out <= 1'b0; 
                    end 
                    2'd2: begin 
                        scl <= 1'b1; 
                    end 
                    2'd3: begin 
                        scl <= 1'b1; 
                    end 
                endcase 
                if (q_tick == 2'd3) begin
                    q_tick    <= 0;
                    bit_count <= 7;                 
                    state     <= RX_DATA_BYTE_LSB;  
                end else begin
                    q_tick <= q_tick + 1;
                end
            
            end
            
            RX_DATA_BYTE_LSB:
            begin
            sda_en <= 1'b0;
                
                case (q_tick)
                    2'd0: begin scl <= 1'b0; end 
                    2'd1: begin scl <= 1'b0; end 
                    2'd2: begin 
                        scl <= 1'b1;
                        shift_reg[bit_count] <= sda; 
                    end
                    2'd3: begin scl <= 1'b1; end 
                endcase
                
                if (q_tick == 2'd3) begin
                    q_tick <= 0;
                    if (bit_count == 0) begin
                        state <= TX_NACK; 
                    end else begin
                        bit_count <= bit_count - 1;
                    end
                end else begin
                    q_tick <= q_tick + 1;
                end
            
            end
            
            TX_NACK: begin
                sda_en <= 1'b1;
                case (q_tick)
                    2'd0: begin 
                    scl <= 1'b0; 
                    sda_out <= 1'b1;
                    end 
                    
                    2'd1: begin 
                    scl <= 1'b0; 
                    sda_out <= 1'b1; 
                    end 
                    
                    2'd2: begin 
                    scl <= 1'b1; 
                    end 
                    2'd3: begin 
                    scl <= 1'b1;
                    end 
                endcase
                
                if (q_tick == 2'd3) begin
                    q_tick<= 0;
                    state<= STOP_COND;
                end else begin
                    q_tick <= q_tick + 1;
                end
            end
            
            STOP_COND: begin
                sda_en <= 1'b1;
                case (q_tick)
                    2'd0: begin scl <= 1'b0; 
                            sda_out <= 1'b0; 
                          end 
                    2'd1: begin 
                            scl <= 1'b1; 
                            sda_out <= 1'b0; 
                           end 
                    2'd2:  begin 
                            scl <= 1'b1; 
                            sda_out <= 1'b1;
                           end 
                     2'd3: begin
                             scl <= 1'b1;
                             sda_out <= 1'b1; 
                           end 
                endcase
                
                if (q_tick == 2'd3) begin
                    q_tick<= 0;
                    data_out <= shift_reg;
                    state<= IDLE;
                end 
                else 
                    begin
                        q_tick<= q_tick + 1;
                    end
            end
            
            default: state<= IDLE;
        endcase
    end
end

endmodule