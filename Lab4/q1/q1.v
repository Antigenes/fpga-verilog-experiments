module encode(
    input [3:0]         I,
    output reg [1:0]    Y,
    output reg          en
);
always @(*) begin
    if(I != 4'b0000)
        en = 1;
    else
        en = 0;
    casez (I)
        4'b1zzz: Y = 2'b11;
        4'b01zz: Y = 2'b10;
        4'b001z: Y = 2'b01;
        4'b0001: Y = 2'b00;
        default: Y = 2'b00;
    endcase
end
endmodule