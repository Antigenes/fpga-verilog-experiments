module MUL #(
    parameter                               WIDTH = 32
) (
    input                                       clk,
    input                                       rst,
    input                                       start,
    input                                       mul_signed,
    input                   [WIDTH-1 : 0]       a,
    input                   [WIDTH-1 : 0]       b,
    output      reg         [2*WIDTH-1:0]       res,
    output      reg                             finish
);
reg [WIDTH-1 : 0]     multiplicand;       // 被乘数寄存器
reg [2*WIDTH : 0]     product;            // 乘积寄存器
reg [WIDTH - 1:0]     count;
wire                  sign;  
wire [WIDTH-1 : 0]    c;
wire [WIDTH-1 : 0]    d;
localparam IDLE = 2'b00;            // 空闲状态。这个周期寄存器保持原值不变。当 start 为 1 时跳转到 INIT。
localparam INIT = 2'b01;            // 初始化。下个周期跳转到 CALC
localparam CALC = 2'b10;            // 计算中。计算完成时跳转到 DONE
localparam DONE = 2'b11;            // 计算完成。下个周期跳转到 IDLE
reg [1:0] current_state,next_state;

//状态转换
always @(*) begin
    case(current_state)
        IDLE:   
            next_state = start ? INIT : IDLE;
        INIT:   
            next_state = CALC;
        CALC:   
            next_state = (count == WIDTH - 1) ? DONE : CALC;
        DONE:   
            next_state = IDLE;
        default: 
            next_state = IDLE;
    endcase
end

always @(posedge clk ) begin
    if (rst) begin
        current_state <= IDLE;
        finish <= 0;
    end
    else begin
        current_state <= next_state; 
        finish <= (current_state == DONE);
    end
end

assign sign = mul_signed ? (a[WIDTH-1] ^ b[WIDTH-1]) : 0;
assign c = (mul_signed && a[WIDTH-1]) ? (~a + 1) : a;
assign d = (mul_signed && b[WIDTH-1]) ? (~b + 1) : b;
//计算
always @(posedge clk ) begin
    if(rst) begin
        product <= 0;
        multiplicand <= 0;
        count <= 0;
        res <= 0;
    end
    else begin
        case(current_state)
            IDLE: begin
                count <= 0;
            end
            INIT: begin
                count <= 0;
                multiplicand <= c;
                product <= {{(WIDTH+1){1'b0}},d};
            end
            CALC: begin
                if (product[0])
                    product <= {product[2*WIDTH:WIDTH] + multiplicand,product[WIDTH-1:0]} >> 1;
                else
                    product <= product >> 1;
                count <= count + 1;
            end
            DONE: begin
                if(sign == 0)
                    res <= product;
                else
                    res <= ~product[2*WIDTH - 1:0] + 1;
            end
        endcase
    end
end
endmodule