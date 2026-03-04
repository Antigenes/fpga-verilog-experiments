module cmd(
    input clk,
    input rst,
    input [7:0] rx_data,       
    input rx_vld,             
    input [15:0] mem_rdata,//从内存读回的数据 (用于r命令)
    output reg [15:0] debug_addr, 
    output reg [15:0] debug_wdata,
    output reg debug_we,         
    output reg core_en,          
    output reg [15:0] result_display//r命令读取结果
);


reg [3:0] hex_val;
always @(*) begin
    if (rx_data >= "0" && rx_data <= "9") begin
        hex_val = rx_data - "0";
    end else if (rx_data >= "a" && rx_data <= "f") begin
        hex_val = rx_data - "a" + 4'hA;
    end else if (rx_data >= "A" && rx_data <= "F") begin
        hex_val = rx_data - "A" + 4'hA;
    end else begin
        hex_val = 4'h0;//非十六进制字符，默认为0
    end
end

//状态机
localparam S_IDLE       = 4'd0; 
localparam S_W_ADDR_1   = 4'd1; 
localparam S_W_ADDR_2   = 4'd2; 
localparam S_W_ADDR_3   = 4'd3; 
localparam S_W_ADDR_4   = 4'd4; 
localparam S_W_DATA_1   = 4'd5; 
localparam S_W_DATA_2   = 4'd6; 
localparam S_W_DATA_3   = 4'd7; 
localparam S_W_DATA_4   = 4'd8; 
localparam S_R_ADDR_1   = 4'd9; 
localparam S_R_ADDR_2   = 4'd10;
localparam S_R_ADDR_3   = 4'd11;
localparam S_R_ADDR_4   = 4'd12;
localparam S_R_FETCH    = 4'd13;
localparam S_R_DONE     = 4'd14;

reg [3:0] current_state, next_state;
reg [15:0] temp_addr_reg; 
reg [15:0] temp_data_reg; 

always @(posedge clk or posedge rst) begin
    if (rst) begin
        current_state <= S_IDLE;
        temp_addr_reg <= 16'h0000;
        temp_data_reg <= 16'h0000;
        debug_addr <= 16'h0000;
        debug_wdata <= 16'h0000;
        debug_we <= 1'b0;
        core_en <= 1'b0;
        result_display <= 16'h0000;
    end else begin
        debug_we <= 1'b0; 
        
        case (current_state)
            S_IDLE: begin
                if (rx_vld) begin
                    if (rx_data == "w") begin
                        next_state <= S_W_ADDR_1;
                        temp_addr_reg <= 16'h0000;
                        temp_data_reg <= 16'h0000;
                    end else if (rx_data == "r") begin
                        next_state <= S_R_ADDR_1;
                        temp_addr_reg <= 16'h0000;
                        result_display <= 16'h0000;
                    end else if (rx_data == "q") begin
                        next_state <= S_IDLE;
                        core_en <= 1'b1;
                    end else if (rx_data == "p") begin
                        next_state <= S_IDLE;
                        core_en <= 1'b0;
                    end else begin
                        next_state <= S_IDLE;
                    end
                end else begin
                    next_state <= S_IDLE;
                end
            end

            S_W_ADDR_1: begin
                if (rx_vld) begin
                    temp_addr_reg <= hex_val << 12;
                    next_state <= S_W_ADDR_2;
                end else next_state <= S_W_ADDR_1;
            end
            S_W_ADDR_2: begin
                if (rx_vld) begin
                    temp_addr_reg <= temp_addr_reg | (hex_val << 8);
                    next_state <= S_W_ADDR_3;
                end else next_state <= S_W_ADDR_2;
            end
            S_W_ADDR_3: begin
                if (rx_vld) begin
                    temp_addr_reg <= temp_addr_reg | (hex_val << 4);
                    next_state <= S_W_ADDR_4;
                end else next_state <= S_W_ADDR_3;
            end
            S_W_ADDR_4: begin
                if (rx_vld) begin
                    temp_addr_reg <= temp_addr_reg | hex_val;
                    debug_addr <= temp_addr_reg | hex_val;
                    next_state <= S_W_DATA_1;
                end else next_state <= S_W_ADDR_4;
            end

            S_W_DATA_1: begin
                if (rx_vld) begin
                    temp_data_reg <= hex_val << 12;
                    next_state <= S_W_DATA_2;
                end else next_state <= S_W_DATA_1;
            end
            S_W_DATA_2: begin
                if (rx_vld) begin
                    temp_data_reg <= temp_data_reg | (hex_val << 8);
                    next_state <= S_W_DATA_3;
                end else next_state <= S_W_DATA_2;
            end
            S_W_DATA_3: begin
                if (rx_vld) begin
                    temp_data_reg <= temp_data_reg | (hex_val << 4);
                    next_state <= S_W_DATA_4;
                end else next_state <= S_W_DATA_3;
            end
            S_W_DATA_4: begin
                if (rx_vld) begin
                    temp_data_reg <= temp_data_reg | hex_val;
                    debug_wdata <= temp_data_reg | hex_val;
                    debug_we <= 1'b1;
                    next_state <= S_IDLE;
                end else next_state <= S_W_DATA_4;
            end

            S_R_ADDR_1: begin
                if (rx_vld) begin
                    temp_addr_reg <= hex_val << 12;
                    next_state <= S_R_ADDR_2;
                end else next_state <= S_R_ADDR_1;
            end
            S_R_ADDR_2: begin
                if (rx_vld) begin
                    temp_addr_reg <= temp_addr_reg | (hex_val << 8);
                    next_state <= S_R_ADDR_3;
                end else next_state <= S_R_ADDR_2;
            end
            S_R_ADDR_3: begin
                if (rx_vld) begin
                    temp_addr_reg <= temp_addr_reg | (hex_val << 4);
                    next_state <= S_R_ADDR_4;
                end else next_state <= S_R_ADDR_3;
            end
            S_R_ADDR_4: begin
                if (rx_vld) begin
                    temp_addr_reg <= temp_addr_reg | hex_val;
                    debug_addr <= temp_addr_reg | hex_val;
                    next_state <= S_R_FETCH;
                end else next_state <= S_R_ADDR_4;
            end

            S_R_FETCH: begin
                result_display <= mem_rdata;
                next_state <= S_IDLE;
            end
            
            default: next_state <= S_IDLE;
        endcase
        current_state <= next_state;
    end
end

endmodule