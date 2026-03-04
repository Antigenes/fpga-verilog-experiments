`timescale 1ns / 1ps

module tb_findmode;

    reg         clk;
    reg         rst;
    reg         next;
    reg [7:0]   number;
    wire [7:0]  out;

    FindMode uut (
        .clk(clk),
        .rst(rst),
        .next(next),
        .number(number),
        .out(out)
    );

    always begin
        clk = 0;
        #10;
        clk = 1;
        #10;
    end

    initial begin
        rst = 1;
        next = 0;
        number = 0;

        @(posedge clk);
        @(posedge clk);
        rst = 0;

        @(posedge clk);
        next = 1;
        number = 10;
        @(posedge clk);
        next = 0;

        @(posedge clk);
        next = 1;
        number = 20;
        @(posedge clk);
        next = 0;

        @(posedge clk);
        next = 1;
        number = 30;
        @(posedge clk);
        next = 0;

        @(posedge clk);
        next = 1;
        number = 10;
        @(posedge clk);
        next = 0;

        @(posedge clk);
        next = 1;
        number = 10;
        @(posedge clk);
        next = 0;

        @(posedge clk);
        next = 1;
        number = 20;
        @(posedge clk);
        next = 0;

        @(posedge clk);
        next = 1;
        number = 30;
        @(posedge clk);
        next = 0;

        @(posedge clk);
        next = 1;
        number = 30;
        @(posedge clk);
        next = 0;

        @(posedge clk);
        next = 1;
        number = 30;
        @(posedge clk);
        next = 0;

        @(posedge clk);
        next = 1;
        number = 10;
        @(posedge clk);
        next = 0;

        @(posedge clk);
        next = 1;
        number = 10;
        @(posedge clk);
        next = 0;
        
        @(posedge clk);
        next = 1;
        number = 10;
        @(posedge clk);
        next = 0;

        #100;
        $finish;
    end

endmodule