module Top(
    output [7:0]            led,
    input [3:0]            sw
);
assign led[7:3] = 5'b0;
adder2bit adder2bit(
    .a(sw[3:2]),
    .b(sw[1:0]),
    .out(led[1:0]),
    .Cout(led[2])
);
endmodule