module FindMode (
    input                               clk,
    input                               rst,
    input                               next,
    input       [7:0]                   number,
    output reg  [7:0]                   out
);

reg [7:0]  count [0:255];
reg [15:0] total; 

integer i;

always @(posedge clk) begin
    if (rst) begin
        for (i = 0; i < 256; i = i + 1)
            count[i] <= 8'd0;
        total <= 16'd0;
        out <= 8'd0;
    end
    else if (next) begin
        count[number] <= count[number] + 1;
        total <= total + 1;
        if ((count[number] + 1) > (total + 1) / 2) 
            out <= number;  
    end
end

endmodule