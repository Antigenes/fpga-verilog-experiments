module MUL7(
    input                               clk,            // 时钟信号
    input                               rst,            // 复位信号，使状态机回到初始态
    input               [31 : 0]        src,            // 输入数据
    input                               src_valid,      // 表明输入结果是否有效
    output      reg                     ready,          // 表明是否正在检测
    output      reg                     res,            // 输出结果
    output      reg                     res_valid       // 表明输出结果是否有效
);

localparam S0=3'd0;
localparam S1=3'd1;
localparam S2=3'd2;
localparam S3=3'd3;
localparam S4=3'd4;
localparam S5=3'd5;
localparam S6=3'd6;

reg [2:0] state,next_state;
reg [31:0] data;
reg [4:0] count;
wire current;
reg signal;

assign current = data[31 - count];
always @(*) begin
    case (state)
        S0: next_state = current ? S1 : S0; 
        S1: next_state = current ? S3 : S2; 
        S2: next_state = current ? S5 : S4;
        S3: next_state = current ? S0 : S6; 
        S4: next_state = current ? S2 : S1; 
        S5: next_state = current ? S4 : S3;
        S6: next_state = current ? S6 : S5;
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= S0;
        count <= 0;
        signal <= 1'b0;
        res_valid <= 1'b0;
        res <= 1'b0;
        data <= 0;
        ready <= 1;
    end 
    else begin
        if(!signal && src_valid) begin
            data <= src;
            count <= 5'd0;
            signal <= 1'b1; 
            res <= 0;
            state <= S0;      
            res_valid <= 1'b0; 
            ready <= 0; 
        end
        else begin
            if(signal) begin
                ready <= 0;
                if(count == 31) begin
                    state <= next_state;
                    count <= 0; 
                    signal <= 0; 
                    res_valid <= 1;
                    if(state == S0)
                        res <= 1;
                    else
                        res <= 0;
                end
                else begin
                    count <= count + 1;
                    state <= next_state;
                end
            end
            else begin
                ready <= 1;
                res <= (state == S0);
            end
        end
    end
end

endmodule