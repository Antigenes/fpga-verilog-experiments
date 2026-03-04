module Flash (
    input                   clk,
    input                   btn,
    output reg [7:0]        led  
);
wire cnt;
reg rev = 0;
Counter #(27'd50000000) counter(
    .clk(clk),
    .rst(btn),
    .out(cnt)
);
always @(posedge clk ) begin
    if(cnt) begin
        rev <= ~rev;
        if(rev)
            led <= 8'b11111111;
        else 
            led <= 8'b0;
    end      
end
endmodule