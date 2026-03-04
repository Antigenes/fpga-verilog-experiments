module ALU_tb();

    reg  [31:0] src0, src1;
    reg  [12:0] sel;
    wire [31:0] res;

    ALU alu (
        .src0(src0),
        .src1(src1),
        .sel(sel),
        .res(res)
    );

    task print_result;
        input [31:0] a, b;
        input [12:0] op_sel;
        begin
            $display("Time %0t: src0=0x%08h, src1=0x%08h, sel=0x%03h => res=0x%08h", $time, a, b, op_sel, res);
        end
    endtask

    initial begin
        $dumpfile("ALU.vcd");
        $dumpvars(0, ALU_tb);

        src0 = 32'h0000_0005; src1 = 32'h0000_0003; sel = 12'h001;
        #10; print_result(src0, src1, sel);

        src0 = 32'h0000_0005; src1 = 32'h0000_0003; sel = 12'h002;
        #10; print_result(src0, src1, sel);

        src0 = 32'hF0F0_F0F0; src1 = 32'h0F0F_0F0F; sel = 12'h010;
        #10; print_result(src0, src1, sel);

        src0 = 32'hF0F0_F0F0; src1 = 32'h0F0F_0F0F; sel = 12'h020;
        #10; print_result(src0, src1, sel);

        src0 = 32'hFFFF_FFFF; src1 = 32'h0000_0001;
        sel = 12'h004;
        #10; print_result(src0, src1, sel);

        sel = 12'h008;
        #10; print_result(src0, src1, sel);

        src0 = 32'h0000_0001; src1 = 32'h0000_0000;
        sel = 12'h004;
        #10; print_result(src0, src1, sel);

        sel = 12'h008;
        #10; print_result(src0, src1, sel);

        src0 = 32'hFFFF_FFFF; src1 = 32'hFFFF_FFFE;
        sel = 12'h004;
        #10; print_result(src0, src1, sel);

        sel = 12'h008;
        #10; print_result(src0, src1, sel);

        src0 = 32'h0000_0000; src1 = 32'hFFFF_FFFF;
        sel = 12'h004;
        #10; print_result(src0, src1, sel);

        sel = 12'h008;
        #10; print_result(src0, src1, sel);

        src0 = 32'h7FFF_FFFF;
        src1 = 32'h8000_0000;
        sel = 12'h004;
        #10; print_result(src0, src1, sel);

        sel = 12'h008;
        #10; print_result(src0, src1, sel);

        src0 = 32'h8000_0000;
        src1 = 32'h7FFF_FFFF;
        sel = 12'h004;
        #10; print_result(src0, src1, sel);

        sel = 12'h008;
        #10; print_result(src0, src1, sel);

        $display("Simulation finished.");
        $finish;
    end

endmodule