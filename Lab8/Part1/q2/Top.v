module Top(
    input                   [ 0 : 0]        clk,
    input                   [ 0 : 0]        btn,

    input                   [ 7 : 0]        sw,

    output                  [ 3 : 0]        seg_data,
    output                  [ 2 : 0]        seg_an,

    output                  [ 0 : 0]        uart_dout
);

wire [ 0 : 0]   rst = sw[7];
wire [ 7 : 0]   dout_data;
reg  [31 : 0]   output_data;

reg btn_r1, btn_r2, btn_r3;
always @(posedge clk) begin
    if (rst) begin
        btn_r1 <= 1'b0;
        btn_r2 <= 1'b0;
        btn_r3 <= 1'b0;
    end else begin
        btn_r1 <= btn;
        btn_r2 <= btn_r1;
        btn_r3 <= btn_r2;
    end
end
wire dout_vld = btn_r2 & ~btn_r3;

Send send (
    .clk            (clk), 
    .rst            (rst),
    .dout           (uart_dout),
    .dout_vld       (dout_vld),
    .dout_data      (dout_data)
);

Segment segment (
    .clk            (clk),
    .rst            (rst),
    .output_data    (output_data),
    .output_valid   (8'H03),
    .seg_data       (seg_data),
    .seg_an         (seg_an)
);

always @(posedge clk) begin
    if (rst)
        output_data <= 0;
    else
        output_data <= {25'B0, sw[6:0]};
end

assign dout_data = output_data[7:0];
endmodule