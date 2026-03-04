module top(
    input wire clk,
    input wire [7:0] sw,    
    input wire btn,
    input wire uart_rx,//串口接收
    output wire uart_tx,//串口发送
    output wire [2:0] an,    
    output wire [4:0] seg     
);

wire rst = sw[7];

wire [7:0] rx_byte;
wire rx_vld;

uart_rx uart_rx1(
    .clk(clk),
    .rst(rst),
    .rx(uart_rx),
    .data(rx_byte),
    .valid(rx_vld)
);

//发送显示
assign uart_tx = uart_rx;

wire [15:0] debug_mem_addr;
wire [15:0] debug_mem_wdata;
wire debug_mem_we;
wire core_run;//控制core运行
wire [15:0] uart_read_result;//r命令读取到的结果

//内存的原始读取数据
wire [15:0] mem_rdata_from_ram;

cmd cmd(
    .clk(clk),
    .rst(rst),
    .rx_data(rx_byte),
    .rx_vld(rx_vld),
    .mem_rdata(mem_rdata_from_ram),//从内存直接读取的数据
    .debug_addr(debug_mem_addr),
    .debug_wdata(debug_mem_wdata),
    .debug_we(debug_mem_we),
    .core_en(core_run),
    .result_display(uart_read_result)
);


wire [15:0] core_mem_addr;
wire [15:0] core_mem_wdata;
wire core_mem_write;
wire [15:0] core_mem_rdata;//core接收的内存读取数据

wire [15:0] ram_addr;
wire [15:0] ram_wdata;
wire ram_we;

assign ram_addr = (core_run) ? core_mem_addr : debug_mem_addr;
assign ram_wdata = (core_run) ? core_mem_wdata : debug_mem_wdata;
assign ram_we = (core_run) ? core_mem_write : debug_mem_we;

dist_mem_gen_0 memory(
    .a(ram_addr),
    .d(ram_wdata),
    .clk(clk),
    .we(ram_we),
    .spo(mem_rdata_from_ram)//内存的输出数据
);

assign core_mem_rdata = mem_rdata_from_ram;

wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7, PC_out, IR_out;
wire [2:0] NZP_out;

core u_core(
    .clk(clk),
    .rst(rst),         
    .en(core_run), 
    .mem_rdata(core_mem_rdata),
    .mem_addr(core_mem_addr),
    .mem_write(core_mem_write),
    .mem_wdata(core_mem_wdata),
    .R0(R0), .R1(R1), .R2(R2), .R3(R3),
    .R4(R4), .R5(R5), .R6(R6), .R7(R7),
    .PC_out(PC_out),
    .IR_out(IR_out),
    .NZP_out(NZP_out)
);

reg [15:0] display;//存储要显示在数码管低四位的数据
always @(*) begin
    case(sw[3:0])
        4'b0000: display = R0;
        4'b0001: display = R1;
        4'b0010: display = R2;
        4'b0011: display = R3;
        4'b0100: display = R4;
        4'b0101: display = R5;
        4'b0110: display = R6;
        4'b0111: display = R7;
        4'b1000: display = PC_out;
        4'b1001: display = IR_out;
        4'b1010: display = {13'b0,NZP_out}; 
        default: display = 16'h0000;
    endcase
end

Segment segment(
    .clk(clk),
    .rst(rst),
    //display放在低16位
    .output_data({display,uart_read_result}), 
    .seg_data(seg),
    .seg_an(an)
);

endmodule