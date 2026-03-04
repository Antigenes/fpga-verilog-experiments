module csa(
    input  [31:0] a,
    input  [31:0] b, 
    input  [31:0] c,
    output [31:0] sum1,  // 和向量
    output [31:0] sum2   // 进位向量（左移1位）
);
    assign sum1 = a ^ b ^ c;          // 三位异或，计算当前位的和
    assign sum2 = (a & b | b & c | a & c) << 1;  // 多数表决，计算进位
endmodule