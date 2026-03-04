module uart_rx(
    input clk,
    input rst,
    input rx,//串口接收
    output reg [7:0] data,//接收到的8位数据
    output reg valid//数据有效信号
);

parameter CLKS_PER_BIT = 10417; 
parameter START_BIT_SAMPLE_POS = CLKS_PER_BIT / 2;

localparam IDLE         = 3'd0;//空闲状态，等待起始位
localparam START_BIT    = 3'd1; 
localparam DATA_BITS    = 3'd2; 
localparam STOP_BIT     = 3'd3; 

reg [2:0] current_state, next_state;
reg [13:0] bit_cnt;//位计数器
reg [3:0] data_bit_idx;//索引
reg [7:0] rx_shift_reg;//接收移位寄存器

//同步输入rx信号
reg rx_sync0, rx_sync1;
always @(posedge clk) begin
    rx_sync0 <= rx;
    rx_sync1 <= rx_sync0;
end

//状态机
always @(posedge clk or posedge rst) begin
    if (rst) begin
        current_state <= IDLE;
        bit_cnt <= 0;
        data_bit_idx <= 0;
        rx_shift_reg <= 0;
        valid <= 0;
        data <= 0;
    end else begin
        valid <= 0;

        case (current_state)
            IDLE: begin
                if (rx_sync1 == 1'b0) begin 
                    current_state <= START_BIT;
                    bit_cnt <= 0;
                end else begin
                    current_state <= IDLE;
                end
            end

            START_BIT: begin
                if (bit_cnt == START_BIT_SAMPLE_POS) begin 
                    if (rx_sync1 == 1'b0) begin
                        current_state <= DATA_BITS;
                        bit_cnt <= 0; 
                        data_bit_idx <= 0;
                    end else begin 
                        current_state <= IDLE;
                    end
                end else begin
                    bit_cnt <= bit_cnt + 1;
                end
            end

            DATA_BITS: begin
                if (bit_cnt == CLKS_PER_BIT - 1) begin 
                    bit_cnt <= 0;
                    rx_shift_reg[data_bit_idx] <= rx_sync1; 
                    if (data_bit_idx == 7) begin
                        current_state <= STOP_BIT;
                        data_bit_idx <= 0;
                    end else begin
                        data_bit_idx <= data_bit_idx + 1;
                        current_state <= DATA_BITS;
                    end
                end else begin
                    bit_cnt <= bit_cnt + 1;
                end
            end

            STOP_BIT: begin
                if (bit_cnt == CLKS_PER_BIT - 1) begin
                    bit_cnt <= 0;
                    current_state <= IDLE;
                    valid <= 1;//接收完成，数据有效
                    data <= rx_shift_reg;//输出接收到的数据
                end else begin
                    bit_cnt <= bit_cnt + 1;
                end
            end

            default: current_state <= IDLE;
        endcase
    end
end

endmodule