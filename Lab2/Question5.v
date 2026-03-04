module CountOnes(
    input       [31:0]         a,
    input       [4:0]          b,
    input       [4:0]          c,
    output reg  [5:0]          out
);

integer i;
always @(*) begin
    out = 6'd0;
    for (i = b; i <= c; i = i + 1) begin
        if (a[i]) 
            out = out + 1;
    end
end
endmodule