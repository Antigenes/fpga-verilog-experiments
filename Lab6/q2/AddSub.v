module AddSub (
    input                   [31 : 0]        a, b,
    output                  [31 : 0]        s,
    output                                  co
);

Adder adder (
    .a(a), 
    .b(~b),
    .ci(1'b1),
    .s(s),
    .co(co)
);

endmodule