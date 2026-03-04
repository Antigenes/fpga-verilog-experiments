module Top(
    output [7:0]            led,
    input [7:0]            sw
);
multiple5 multi5(
    .num(sw),
    .ismultiple5(led[0])
);
assign led[7:1] = 7'b0;
endmodule