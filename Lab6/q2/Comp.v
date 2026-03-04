module Comp (
    input                   [31 : 0]        a, b,
    output                                  ul,sl
);

wire out;
wire [31:0] s;
wire ovf;
AddSub addsub(
    .a(a),
    .b(b),
    .s(s),
    .co(out)
);

assign ovf = (a[31] & ~b[31] & ~s[31]) | (~a[31] & b[31] & s[31]);
assign sl = s[31] ^ ovf;
assign ul = ~out;

endmodule