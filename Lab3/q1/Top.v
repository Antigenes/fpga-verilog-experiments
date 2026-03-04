module Top (
    input   [7:0]                       sw,
    output  [7:0]                       led
);
assign led[3] = sw[0];
assign led[2] = sw[1];
assign led[1] = sw[2];
assign led[0] = sw[3];
assign led[7] = sw[4];
assign led[6] = sw[5];
assign led[5] = sw[6];
assign led[4] = sw[7];
endmodule