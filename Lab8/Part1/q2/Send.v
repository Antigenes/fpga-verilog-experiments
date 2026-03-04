module Send(
    input                   [ 0 : 0]        clk, 
    input                   [ 0 : 0]        rst,

    output      reg         [ 0 : 0]        dout,

    input                   [ 0 : 0]        dout_vld,
    input                   [ 7 : 0]        dout_data
);

// Counter and parameters
localparam FullT        = 10416;
localparam TOTAL_BITS   = 9;
reg [ 15 : 0] div_cnt;           // 分频计数器，范围 0 ~ 10416
reg [ 4 : 0] dout_cnt;          // 位计数器，范围 0 ~ 9

// Main FSM
localparam WAIT     = 0;
localparam SEND     = 1;
reg current_state, next_state;
always @(posedge clk) begin
    if (rst)
        current_state <= WAIT;
    else
        current_state <= next_state;
end

always @(*) begin
    next_state = current_state;
    case (current_state)
        WAIT:begin
            if(dout_vld)
                next_state = SEND;
            else
                next_state = WAIT;
        end
        SEND:begin
            if(dout_cnt == TOTAL_BITS && div_cnt == FullT)
                next_state = WAIT;
            else
                next_state = SEND;
        end
        default:next_state = WAIT;
    endcase
end

// Counter
always @(posedge clk) begin
    if (rst)
        div_cnt <= 0;
    else if (current_state == SEND) begin
        if(div_cnt < FullT)
            div_cnt <= div_cnt + 1;
        else
            div_cnt <= 0;
    end
    else
        div_cnt <= 0;
end

always @(posedge clk) begin
    if (rst)
        dout_cnt <= 4'H0;
    else if (current_state == SEND) begin
        if(dout_cnt <= TOTAL_BITS) begin
            if(div_cnt == FullT)
                dout_cnt <= dout_cnt + 1;
            else
                dout_cnt <= dout_cnt;
        end
        else
            dout_cnt <= 0;
    end
    else
        dout_cnt <= 4'H0;
end

reg [7 : 0] temp_data;      // 用于保留待发送数据，这样就不怕 dout_data 的变化了
always @(posedge clk) begin
    if (rst)
        temp_data <= 8'H0;
    else if (current_state == WAIT && dout_vld)
        temp_data <= dout_data;
end

always @(posedge clk) begin
    if (rst)
        dout <= 1'B1;
    else begin
        if(current_state == WAIT)
            dout <= 1'b1;
        else
            case(dout_cnt)
            0:dout <= 0;
            1:dout <= temp_data[0];
            2:dout <= temp_data[1];
            3:dout <= temp_data[2];
            4:dout <= temp_data[3];
            5:dout <= temp_data[4];
            6:dout <= temp_data[5];
            7:dout <= temp_data[6];
            8:dout <= temp_data[7];
            9:dout <= 1;
            endcase
    end
end
endmodule