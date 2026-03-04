module multiple5(
    input           [7:0]          num,
    output   reg                   ismultiple5
);
wire [1:0] y0,y1;
wire z0,z1;
adder2bit adder0(
    .a(num[1:0]),
    .b(num[5:4]),
    .out(y0),
    .Cout(z0)
);
adder2bit adder1(
    .a(num[3:2]),
    .b(num[7:6]),
    .out(y1),
    .Cout(z1)
);
wire [3:0] x0,x1,x2,x3,x4;//引入符号位
assign x0 = {1'b0,z0,y0};
assign x1 = {1'b0,z1,y1};
assign x2 = ~x1 + 1;
wire z2;
wire [1:0] t0,t1;
adder2bit adder2(
    .a(~x1[1:0]),
    .b(2'b01),
    .out(t0),
    .Cout(z2)
);
adder2bit adder3(
    .a(~x1[3:2]),
    .b({0,z2}),
    .out(t1),
    .Cout()
);
assign x3 = {t1,t0};//补码

wire [1:0] p0,p1,p2;
wire k0,k1;
adder2bit adder4(
    .a(x3[1:0]),
    .b(x0[1:0]),
    .out(p0),
    .Cout(k0)
);
adder2bit adder5(
    .a(x3[3:2]),
    .b(x0[3:2]),
    .out(p1),
    .Cout(k1)
);
adder2bit adder6(
    .a(p1),
    .b({0,k0}),
    .out(p2),
    .Cout()
);//三个二位加法器构成4位半加器
assign x4 = {p2,p0};

always @(*) begin
    if(x4 == 4'b0000 || x4 == 4'b1011 || x4 == 4'b0101)
        ismultiple5 = 1;
    else
        ismultiple5 = 0;
end
endmodule