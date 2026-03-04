module Top(
    input        clk,
    input [2:0]  a,          
    input [2:0]  b,         
    input        rst,        
    input        start,
    output [3:0] d,  
    output [2:0] an 
);


wire [7:0] res;



MUL #(.WIDTH(4)) u_mul (
    .clk    (clk),
    .rst    (sw_7),
    .start  (start),
    .a      ({1'b0,a}),
    .b      ({1'b0,b}),
    .res    (res),        
    .finish ()      
);

Segment seg(
    .clk(clk),
    .rst(sw_7),
    .output_data({24'b0,res}),
    .seg_data(d),
    .seg_an(an)
);

endmodule