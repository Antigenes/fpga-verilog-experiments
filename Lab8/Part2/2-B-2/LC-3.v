module core(
    input clk,
    input rst,
    input en,
    input [15:0] mem_rdata,//内存读出的数据
    output reg [15:0] mem_addr,//访问的地址     
    output reg mem_write,
    output reg [15:0] mem_wdata,//内存写入的数据
    output reg [15:0] R0, 
    output reg [15:0] R1, 
    output reg [15:0] R2, 
    output reg [15:0] R3, 
    output reg [15:0] R4, 
    output reg [15:0] R5, 
    output reg [15:0] R6, 
    output reg [15:0] R7, 
    output reg [15:0] PC_out,
    output reg [15:0] IR_out,
    output reg [2:0]  NZP_out
);

reg [15:0] PC;
reg [15:0] IR;
reg [15:0] R[0:7];//通用寄存器
reg [15:0] ADDR;//计算得到的地址
reg [2:0] NZP;
reg mem_access;//是否需要访问内存
reg [15:0] result;//新增：用于锁存ALU结果

always @(*) begin
    PC_out = PC;
    IR_out = IR;
    NZP_out = NZP;
    R0 = R[0]; R1 = R[1]; R2 = R[2]; R3 = R[3];
    R4 = R[4]; R5 = R[5]; R6 = R[6]; R7 = R[7];
end


//状态机
localparam IDLE = 3'd0;//闲置状态
localparam FETCH = 3'd1;
localparam DECODE = 3'd2;
localparam EVAL_ADDR = 3'd3;
localparam FETCH_OP = 3'd4;
localparam EXECUTE = 3'd5;
localparam STORE = 3'd6;

reg [2:0] current_state,next_state;

//将寄存器初始化移到时序复位块中
always @(posedge clk or posedge rst) begin
    if(rst) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

//组合电路确定状态跳转
always @(*) begin
    case(current_state)
        IDLE: begin
            if(en)
                next_state = FETCH;
            else
                next_state = IDLE;
        end
        FETCH:            
            next_state = DECODE;
        DECODE: begin
            if(mem_access)           
                next_state = EVAL_ADDR;
            else
                next_state = EXECUTE;
        end
        EVAL_ADDR: 
            next_state = FETCH_OP;
        FETCH_OP: begin   
            next_state = EXECUTE;
        end
        EXECUTE:          
            next_state = STORE;
        STORE:     
            next_state = IDLE;
        default:          
            next_state = IDLE;
    endcase
end

//DECODE判断是否需要内存访问
always @(*) begin
    mem_access = 0;
    //BR、JMP、JSR、RET、LEA不需要内存操作数
    case(IR[15:12])
        4'b0010: begin//LD
            mem_access = 1'b1;
        end
        4'b0011: begin//ST
            mem_access = 1'b1;
        end
        4'b0110: begin//LDR
            mem_access = 1'b1;
        end
        4'b0111: begin//STR
            mem_access = 1'b1;
        end
        default:
            mem_access = 1'b0;
    endcase
end

//控制信号        
reg ir_load;        
reg alu_op;         
reg regfile_write;   
reg addr_calc;
reg branch;//分支
reg jump;//跳转
reg lea_op;//LEA
reg br;


always @(*) begin
    //初始值
    ir_load = 1'b0;
    alu_op = 1'b0;
    regfile_write = 1'b0;
    addr_calc = 1'b0;
    branch = 1'b0;
    jump = 1'b0;
    lea_op = 1'b0;
    mem_write = 1'b0;

    case(current_state)
        FETCH: begin
            ir_load = 1'b1;
        end
        
        DECODE: begin

        end
        
        EVAL_ADDR: begin
            addr_calc = 1'b1;
        end
        
        FETCH_OP: begin

        end
        
        EXECUTE: begin
            case(IR[15:12])
                4'b0001: 
                    alu_op = 1'b1;//ADD
                4'b0101:
                    alu_op = 1'b1;//AND
                4'b1001:
                    alu_op = 1'b1;//NOT
                4'b1110: 
                    lea_op = 1'b1;//LEA
                4'b0000: 
                    branch = 1'b1;//BR
                4'b1100: 
                    jump = 1'b1;//JMP
                default:;
            endcase
        end
        
        STORE: begin
            //写回寄存器文件（除ST/STR/JSR外）
            if(IR[15:12] != 4'b0011 && IR[15:12] != 4'b0111 && IR[15:12] != 4'b0100 && IR[15:12] != 4'b0000) begin
                regfile_write = 1'b1;
            end
            
            //写入内存
            if (IR[15:12] == 4'b0011 || IR[15:12] == 4'b0111) begin
                mem_write = 1'b1;
            end
        end
        
        default: ;
    endcase
end

//更新寄存器

//PC更新
always @(posedge clk or posedge rst) begin
    if(rst)
        PC <= 16'h0000;
    else if(current_state == FETCH)
        PC <= PC + 1;
    else begin
        if(branch) begin
            //BR指令处理
            br <= 0;
            case (IR[11:9])
                3'b000://BR
                    PC <= PC + {{7{IR[8]}},IR[8:0]};//PC相对寻址
                3'b001: begin
                    if(NZP[0])//BRp
                        PC <= PC + {{7{IR[8]}},IR[8:0]};
                end
                3'b010: begin
                    if(NZP[1])//BRz
                        PC <= PC + {{7{IR[8]}},IR[8:0]};
                end
                3'b011: begin
                    if(NZP[1] | NZP[0])//BRzp
                        PC <= PC + {{7{IR[8]}},IR[8:0]};
                end
                3'b100: begin
                    if(NZP[2])//BRn
                        PC <= PC + {{7{IR[8]}},IR[8:0]};
                end
                3'b101: begin
                    if(NZP[2] | NZP[0])//BRnp
                        PC <= PC + {{7{IR[8]}},IR[8:0]};
                end
                3'b110: begin
                    if(NZP[2] | NZP[1])//BRnz
                        PC <= PC + {{7{IR[8]}},IR[8:0]};
                end
                3'b111: begin
                    PC <= PC + {{7{IR[8]}},IR[8:0]};//BRnzp
                end
            endcase
        end

        else if(jump) begin
            //JMP
            PC <= R[IR[8:6]];
        end

        else if(IR[15:12] == 4'b0100) begin//JSR
            if(IR[11]) begin
                PC <= PC + {{5{IR[10]}}, IR[10:0]};
            end 
            else begin
                PC <= R[IR[8:6]];
            end
        end
    end
end

//IR载入
always @(posedge clk or posedge rst) begin
    if(rst)
        IR <= 16'h0000;
    else if(ir_load)
        IR <= mem_rdata;
end

//ADDR计算
wire [15:0] pc_offset9 = {{7{IR[8]}}, IR[8:0]};
wire [15:0] pc_offset11 = {{5{IR[10]}}, IR[10:0]}; 
wire [15:0] base_offset6 = {{10{IR[5]}}, IR[5:0]}; 

//提取地址计算为组合逻辑，以便在EVAL_ADDR状态立刻送出地址
reg [15:0] addr_comb; 
always @(*) begin
    addr_comb = 16'h0000;
    case (IR[15:12])
        4'b0010: addr_comb = PC + pc_offset9;//LD
        4'b0011: addr_comb = PC + pc_offset9;//ST
        4'b0110: addr_comb = R[IR[8:6]] + base_offset6;//LDR
        4'b0111: addr_comb = R[IR[8:6]] + base_offset6;//STR
        default: addr_comb = 16'h0000;
    endcase
end

//ADDR寄存器锁存组合逻辑的结果
always @(posedge clk or posedge rst) begin
    if(rst)
        ADDR <= 16'h0000;
    else if(addr_calc)
        ADDR <= addr_comb;
end

//内存操作数暂存
reg [15:0] mem_operand;
always @(posedge clk) begin
    if(current_state == FETCH_OP) begin
        case (IR[15:12])
            4'b0010:
                mem_operand <= mem_rdata;//LD
            4'b0110: 
                mem_operand <= mem_rdata;//LDR
            default: ;
        endcase
    end
end

//ALU和数据通路
reg [15:0] alu_out;
reg [15:0] operand_a, operand_b;

//ALU输入
always @(*) begin
    operand_a = R[IR[8:6]];//SR1=IR[8:6]
    operand_b = 16'h0000;
    
    case (IR[15:12])
        4'b0001: begin//ADD
            if(IR[5])//立即数
                operand_b = {{11{IR[4]}}, IR[4:0]};
            else
                operand_b = R[IR[2:0]];
        end
        4'b0101: begin//AND
            if(IR[5])//立即数
                operand_b = {{11{IR[4]}}, IR[4:0]};
            else
                operand_b = R[IR[2:0]];
        end
        4'b1001: begin//NOT
            operand_b = ~operand_a;
            operand_a = 16'h0000;
        end
        4'b0100: begin//JSR
            operand_a = PC;//返回地址=当前PC
            operand_b = 16'h0000;
        end
        default: ;
    endcase
end

//ALU运算
always @(*) begin
    alu_out = 16'h0000;
    if(alu_op) begin
        case (IR[15:12])
            4'b0001: alu_out = operand_a + operand_b;//ADD
            4'b0101: alu_out = operand_a & operand_b;//AND
            4'b1001: alu_out = operand_b;//NOT
            default: alu_out = 16'h0000;
        endcase
    end
    else if(lea_op) begin
        alu_out = PC + pc_offset11;//LEA,DR=PC+sext(IR[10:0])
    end
    else if(IR[15:12] == 4'b0010) begin//LD
        alu_out = mem_operand;
    end
    else if(IR[15:12] == 4'b0110) begin//LDR
        alu_out = mem_operand;
    end
    else if(IR[15:12] == 4'b0100) begin//JSR
        alu_out = operand_a;
    end
    else begin
        alu_out = 16'h0000;
    end
end

//锁存ALU结果
always @(posedge clk or posedge rst) begin
    if(rst)
        result <= 16'h0000;
    else if(current_state == EXECUTE) begin
        result <= alu_out;
    end
end

//寄存器写回、NZP更新
integer k;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        for(k=0; k<8; k=k+1) R[k] <= 16'h0000;
        NZP <= 3'b000;
    end
    else begin
        if(regfile_write) begin
            R[IR[11:9]] <= result;
            //更新NZP
            if(IR[15:12] == 4'b0001 || IR[15:12] == 4'b0101 || IR[15:12] == 4'b1001 || IR[15:12] == 4'b0010 || IR[15:12] == 4'b0110 || IR[15:12] == 4'b1110) begin
                if(result == 16'h0000)
                    NZP <= 3'b010;//Z
                else if(result[15])
                    NZP <= 3'b100;//N
                else
                    NZP <= 3'b001;//P
            end
        end
        if(current_state == STORE && IR[15:12] == 4'b0100) begin
            R[7] <= result;
        end
    end
end

//内存地址和写数据
always @(*) begin
    case (current_state)
        //IDLE状态提前输出PC，确保FETCH时内存数据已就绪
        IDLE:
            mem_addr = PC; 

        FETCH: 
            mem_addr = PC;
        
        //EVAL_ADDR状态直接输出组合逻辑地址，确保FETCH_OP时数据已就绪
        EVAL_ADDR:
            mem_addr = addr_comb; 
        
        FETCH_OP: 
            mem_addr = ADDR;//此时ADDR寄存器已更新，保持地址
            
        STORE:
            mem_addr = ADDR;
        
        default: 
            mem_addr = PC;
    endcase

    //写数据
    case (IR[15:12])
        4'b0011: 
            mem_wdata = R[IR[11:9]];//ST
        4'b0111: 
            mem_wdata = R[IR[11:9]];//STR
        default: 
            mem_wdata = 16'h0000;
    endcase
end

endmodule