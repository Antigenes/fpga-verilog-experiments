module TIMER (
    input                           clk,rst,
    output              [3:0]       out,
    output              [2:0]       select
);

    reg [3:0] h;//小时
    reg [5:0] m;//分钟
    reg [5:0] s;//秒
    reg [26:0] count;
    reg [3:0] m_1;
    reg [3:0] m_0;
    reg [3:0] s_1;
    reg [3:0] s_0;

    always @(*) begin
        if(m >= 6'd50)
            m_1 = 4'd5;
        else if(m >= 6'd40)
            m_1 = 4'd4;
        else if(m >= 6'd30)
            m_1 = 4'd3;
        else if(m >= 6'd20)
            m_1 = 4'd2;
        else if(m >= 6'd10)
            m_1 = 4'd1;
        else 
            m_1 = 4'd0;
        m_0 = m - 10 * m_1;
        if(s >= 6'd50)
            s_1 = 4'd5;
        else if(s >= 6'd40)
            s_1 = 4'd4;
        else if(s >= 6'd30)
            s_1 = 4'd3;
        else if(s >= 6'd20)
            s_1 = 4'd2;
        else if(s >= 6'd10)
            s_1 = 4'd1;
        else 
            s_1 = 4'd0;
        s_0 = s - 10 * s_1;
    end

    always@ (posedge clk) begin
        if (rst) begin
            count <= 27'd1;
        end
        else begin
            if (count != 27'd100000000)
                count <= count + 27'd1;
            else
                count <= 27'd1;
        end
    end//计数器，每1scount变成1

    /*使用 Lab3 实验练习中编写的数码管显示模块*/
    Segment segment(
        .clk                (clk),
        .rst                (rst),
        .output_data        ({12'h0,h, m_1, m_0, s_1, s_0}),
        .seg_data           (out),
        .seg_an             (select)
    );

    always@ (posedge clk) begin
        if(rst) begin
            h <= 4'H9;
            m <= 6'd58;
            s <= 6'd30;
        end
        else begin
            if(count == 27'd100000000) begin
                if(s < 6'd59)
                    s <= s + 6'b1;
                else begin
                    s <= 6'b0;
                    if(m < 6'd59)
                        m <= m + 6'b1;
                    else begin
                        m <= 6'b0;
                        if(h < 4'HF)
                            h <= h + 4'H1;
                        else
                            h <= 0;
                    end
                end
                
            end
        end
    end
endmodule