module adder2bit(
    input           [1:0]         a,
    input           [1:0]         b,
    output   reg    [1:0]         out,
    output   reg                  Cout
);
wire A1,A2,B1,B2;
assign A1 = a[1];
assign A2 = a[0];
assign B1 = b[1];
assign B2 = b[0];
always @(*) begin
    Cout = (A1 & B1) | (A2 & B1 & B2) | (A1 & A2 & B2);
    out[1] = (~A1 & A2 & ~B1 & B2) | (A1 & A2 & B1 & B2) | (A1 & ~B1 & ~B2) | (A1 & ~A2 & ~B1) | (~A1 & ~A2 & B1) | (~A1 & B1 & ~B2);
    out[0] = (A2 ^ B2);
end
endmodule