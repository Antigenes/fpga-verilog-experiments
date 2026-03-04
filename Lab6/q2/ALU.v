module ALU(
    input                   [31 : 0]        src0, src1,
    input                   [12 : 0]        sel,
    output    reg           [31 : 0]        res
);
// Write your code here
wire [31:0] adder_out;
wire [31:0] sub_out;
wire slt_out;
wire sltu_out;

Adder adder(
    .a(src0),
    .b(src1),
    .ci(1'B0),
    .s(adder_out),
    .co()
);

AddSub sub(
    .a(src0),
    .b(src1),
    .s(sub_out),
    .co()
);

Comp comp(
    .a(src0),
    .b(src1),
    .ul(sltu_out),
    .sl(slt_out)
);

always @(*) begin
    if(sel == 12'h001) begin
        res = adder_out;
    end
    else if(sel == 12'h002) begin
        res = sub_out;
    end
    else if(sel == 12'h004) begin
        res = {31'b0,slt_out};
    end
    else if(sel == 12'h008) begin
        res = {31'b0,sltu_out};
    end
    else if(sel == 12'h010) begin
        res = src0 & src1;
    end
    else if(sel == 12'h020) begin
        res = src0 | src1;
    end
    else if(sel == 12'h040) begin
        res = ~(src0 | src1);
    end
    else if(sel == 12'h080) begin
        res = src0 ^ src1;
    end
    else if(sel == 12'h100) begin
        res = src0 << src1[4:0];
    end
    else if(sel == 12'h200) begin
        res = src0 >> src1[4:0];
    end
    else if(sel == 12'h400) begin
        res = $signed(src0) >>> src1[4:0];
    end
    else if(sel == 12'h800) begin
        res = src1;
    end
    else
        res = 32'b0;
end
endmodule