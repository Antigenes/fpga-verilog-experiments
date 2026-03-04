module MAX3 (
    input       [7:0]         num1, num2, num3,
    output reg  [7:0]         max
);
always @(*) begin
    if (num1 > num2) 
        if (num1 > num3)
            max = num1;
        else
            max = num3;
    else
        if (num2 > num3)
            max = num2;
        else
            max = num3;
end
endmodule