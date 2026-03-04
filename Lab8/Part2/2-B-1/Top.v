module top(
    input wire clk,
    input wire [7:0] sw,    
    input wire btn,    
    output wire [2:0] an,    
    output wire [4:0] seg     
);

reg btn_sync0, btn_sync1;
wire en_step;

always @(posedge clk) begin
    if(sw[7]) begin
        btn_sync0 <= 0;     
        btn_sync1 <= 0; 
    end
    else begin
        btn_sync0 <= btn;     
        btn_sync1 <= btn_sync0;  
    end
end

assign en_step = btn_sync0 && (~btn_sync1); 

wire [15:0] mem_rdata,mem_addr,mem_wdata;
wire [15:0] R0,R1,R2,R3,R4,R5,R6,R7,PC_out,IR_out;
wire [2:0] NZP_out;
wire mem_write;

core core(
    .clk(clk),
    .rst(sw[7]),         
    .en(en_step),         
    .mem_rdata(mem_rdata),
    .mem_addr(mem_addr),
    .mem_write(mem_write),
    .mem_wdata(mem_wdata),
    .R0(R0), .R1(R1), .R2(R2), .R3(R3),
    .R4(R4), .R5(R5), .R6(R6), .R7(R7),
    .PC_out(PC_out),
    .IR_out(IR_out),
    .NZP_out(NZP_out)
);

dist_mem_gen_0 memory(
    .a(mem_addr),
    .d(mem_wdata),
    .clk(clk),
    .we(mem_write),
    .spo(mem_rdata) 
);

reg [15:0] display_data;
always @(*) begin
    case(sw[3:0])
        4'b0000: display_data = R0;
        4'b0001: display_data = R1;
        4'b0010: display_data = R2;
        4'b0011: display_data = R3;
        4'b0100: display_data = R4;
        4'b0101: display_data = R5;
        4'b0110: display_data = R6;
        4'b0111: display_data = R7;
        4'b1000: display_data = PC_out;
        4'b1001: display_data = IR_out;
        4'b1010: display_data = {13'b0, NZP_out}; 
        default: display_data = 16'h0000;
    endcase
end

Segment segment(
    .clk(clk),
    .rst(sw[7]),
    .output_data({display_data, 16'b0}),
    .seg_data(seg),
    .seg_an(an)
);

endmodule
