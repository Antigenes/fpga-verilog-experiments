module Segment(
    input                       clk,
    input                       rst,
    input       [31:0]          output_data,
    output reg  [ 4:0]          seg_data,
    output reg  [ 2:0]          seg_an
);

reg [31:0] counter;
reg [2:0] seg_id;

always @(posedge clk) begin
    if(rst)
        counter <= 32'b0;
    else begin
        counter <= counter + 32'b1;
        if(counter >= 32'd250000) begin
            counter <= 32'b0;
            if(seg_id == 3'b111)
                seg_id <= 3'b0;
            else
                seg_id <= seg_id + 3'b1;
        end
    end
end

always @(*) begin
    seg_data = 0;
    seg_an = seg_id;
    case(seg_an)
        3'b000: seg_data = output_data[3:0];
        3'b001: seg_data = output_data[7:4];
        3'b010: seg_data = output_data[11:8];
        3'b011: seg_data = output_data[15:12];
        3'b100: seg_data = output_data[19:16];
        3'b101: seg_data = output_data[23:20];
        3'b110: seg_data = output_data[27:24];
        3'b111: seg_data = output_data[31:28];
    endcase
end

endmodule