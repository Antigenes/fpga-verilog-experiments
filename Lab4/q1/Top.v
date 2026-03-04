module Top(
    output [7:0]            led,
    input [3:0]            sw
);
assign led[6:2] = 5'b0;
encode encode(
    .I(sw[3:0]),
    .Y(led[1:0]),
    .en(led[7])
);
endmodule