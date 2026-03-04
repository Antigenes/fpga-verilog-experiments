// mul7_tb.v
`timescale 1ns/1ps

module mul7_tb;

reg clk;
reg rst;
reg [31:0] src;
reg src_valid;
wire ready;
wire res;
wire res_valid;

MUL7 mul7 (
    .clk(clk),
    .rst(rst),
    .src(src),
    .src_valid(src_valid),
    .ready(ready),
    .res(res),
    .res_valid(res_valid)
);

// 时钟生成
always #1 clk = ~clk; 

// 测试过程
initial begin
    clk = 0;
    rst = 1;
    src = 0;
    src_valid = 0;
    
    #20 rst = 0;  // 释放复位

    // 测试用例1: 7 (应被7整除)
    src = 32'd7;
    src_valid = 1;
    #10 src_valid = 0;
    #100; // 等待32拍+结果

    // 测试用例2: 8 (不能被7整除)
    src = 32'd8;
    src_valid = 1;
    #10 src_valid = 0;
    #100;

    // 测试用例3: 0 (能被7整除)
    src = 32'd0;
    src_valid = 1;
    #10 src_valid = 0;
    #100;

    // 测试用例4: 64137 (不能被7整除)
    src = 32'HFA89;
    src_valid = 1;
    #10 src_valid = 0;
    #100;

    // 测试用例5: 411004 (不能被7整除)
    src = 32'HA1BC;
    src_valid = 1;
    #10 src_valid = 0;
    #100;

    // 测试用例6: 57897 (能被7整除)
    src = 32'HE229;
    src_valid = 1;
    #10 src_valid = 0;
    #100;

    // 测试用例7: 13342 (能被7整除)
    src = 32'H341E;
    src_valid = 1;
    #10 src_valid = 0;
    #100;

    $display("Simulation finished.");
    $finish;
end

endmodule