module Counter #(
    parameter   MAX_VALUE = 8'd100
)(
    input                   clk,
    input                   rst,
    output                  out
);

reg [26:0] counter;
always @(posedge clk) begin
    if (rst)
        counter <= 0;
    else begin
        if (counter >= MAX_VALUE)
            counter <= 0;
        else
            counter <= counter + 26'b1;
    end
end
assign out = (counter == MAX_VALUE);
endmodule