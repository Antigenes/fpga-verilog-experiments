module CSA16_32(
    input                   [31:  0]       a1,
    input                   [31:  0]       a2,
    input                   [31:  0]       a3,
    input                   [31:  0]       a4,
    input                   [31:  0]       a5,
    input                   [31:  0]       a6,
    input                   [31:  0]       a7,
    input                   [31:  0]       a8,
    input                   [31:  0]       a9,
    input                   [31:  0]       a10,
    input                   [31:  0]       a11,
    input                   [31:  0]       a12,
    input                   [31:  0]       a13,
    input                   [31:  0]       a14,
    input                   [31:  0]       a15,
    input                   [31:  0]       a16,
    output                  [31:  0]       sum
);
reg [31:0] b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,c1,c2,c3,c4,c5,c6,d1,d2,d3,d4,e1,e2,e3,e4,f1,f2,f3,g1,g2;

//level1
csa CSA1(
    .a(a1),
    .b(a2),
    .c(a3),
    .sum1(b1),
    .sum2(b2)
);
csa CSA2(
    .a(a4),
    .b(a5),
    .c(a6),
    .sum1(b3),
    .sum2(b4)
);
csa CSA3(
    .a(a7),
    .b(a8),
    .c(a9),
    .sum1(b5),
    .sum2(b6)
);
csa CSA4(
    .a(a10),
    .b(a11),
    .c(a12),
    .sum1(b7),
    .sum2(b8)
);
csa CSA5(
    .a(a13),
    .b(a14),
    .c(a15),
    .sum1(b9),
    .sum2(b10)
);

//level2
csa CSA6(
    .a(b1),
    .b(b2),
    .c(b3),
    .sum1(c1),
    .sum2(c2)
);
csa CSA7(
    .a(b4),
    .b(b5),
    .c(b6),
    .sum1(c3),
    .sum2(c4)
);
csa CSA8(
    .a(b7),
    .b(b8),
    .c(b9),
    .sum1(c5),
    .sum2(c6)
);

//level3
csa CSA9(
    .a(c1),
    .b(c2),
    .c(c3),
    .sum1(d1),
    .sum2(d2)
);
csa CSA10(
    .a(c4),
    .b(c5),
    .c(c6),
    .sum1(d3),
    .sum2(d4)
);

//level4
csa CSA11(
    .a(d1),
    .b(d2),
    .c(d3),
    .sum1(e1),
    .sum2(e2)
);
csa CSA12(
    .a(d4),
    .b(b10),
    .c(a16),
    .sum1(e3),
    .sum2(e4)
);

//level5
csa CSA13(
    .a(e1),
    .b(e2),
    .c(e3),
    .sum1(f1),
    .sum2(f2)
);

//level6
csa CSA14(
    .a(f1),
    .b(f2),
    .c(e4),
    .sum1(g1),
    .sum2(g2)
);

//final
Adder adder(
    .a(g1),
    .b(g2),
    .ci(1'b0),
    .s(sum),
    .co()
);
endmodule