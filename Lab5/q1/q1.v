module Regfile (
    input                       clk,          // 时钟信号
    input           [4:0]       ra1,          // 读端口 1 地址
    input           [4:0]       ra2,          // 读端口 2 地址
    input           [4:0]       wa,           // 写端口地址
    input                       we,           // 写使能信号
    input           [31:0]      din,          // 写数据
    output  reg     [31:0]      dout1,        // 读端口 1 数据输出
    output  reg     [31:0]      dout2         // 读端口 2 数据输出
);

reg [31:0] reg_file [31:0]; // 32 个 32 位寄存器，规模为 32×32 bits

initial begin
    reg_file[0] = 0;//给0号寄存器置零
end

always @(*) begin
    if(we == 0) begin//没有写信号时直接读
         // 读端口 1
        dout1 = reg_file[ra1];
        // 读端口 2
        dout2 = reg_file[ra2];
    end
    else begin
        if(ra1 == wa)
            dout1 = din;
        else
            dout1 = reg_file[ra1];
        if(ra2 == wa)
            dout2 = din;
        else
            dout2 = reg_file[ra2];
    end//写优先
end

// 写端口
always @(posedge clk) begin
    if (we) begin
        if(wa != 0)
            reg_file[wa] <= din;//禁止写入0寄存器
        else
            reg_file[wa] <= din;
    end
    else
        reg_file[wa] <= reg_file[wa];
end

endmodule