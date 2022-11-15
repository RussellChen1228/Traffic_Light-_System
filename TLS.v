module TLS(clk, reset, Set, Stop, Jump, Gin, Yin, Rin, Gout, Yout, Rout);
input           clk;
input           reset;
input           Set;
input           Stop;
input           Jump;
input     [3:0] Gin;
input     [3:0] Yin;
input     [3:0] Rin;
output    Gout;
output    Yout;
output    Rout;

wire Recount_counter;

Control Control(
    .clk(clk),
    .rst(reset),
    .Set(Set),
    .Jump(Jump),
    .Stop(Stop),
    .Recount_counter(Recount_counter),
    .Rout(Rout),
    .Gout(Gout),
    .Yout(Yout)
);

Datapath Datapath(
    .clk(clk),
    .rst(reset),
    .Stop(Stop),
    .Set(Set),
    .Jump(Jump),
    .Gin(Gin),
    .Yin(Yin),
    .Rin(Rin),
    .RGY({Rout, Gout, Yout}),
    .Recount(Recount_counter)
);


endmodule

module Datapath(clk, rst, Set, Stop, Jump, Rin, Yin, Gin, RGY, Recount);
    input clk, rst, Set, Stop, Jump;
    input [3:0] Gin, Yin, Rin;
    input [2:0] RGY;
    output Recount;

    wire [3:0] Current_time;
    
    Compare compare(
        .clk(clk),
        .Set(Set),
        .Stop(Stop),
        .RGY(RGY),
        .Rin(Rin),
        .Yin(Yin),
        .Gin(Gin),
        .Current_time(Current_time),
        .Recount_counter(Recount)
    );

    Counter counter(
        .clk(clk),
        .rst(rst),
        .Set(Set),
        .Stop(Stop),
        .Jump(Jump),
        .Recount_counter(Recount),
        .Count_out(Current_time)
    );

endmodule

module Control (clk, rst, Set, Jump, Stop, Recount_counter, Rout, Gout, Yout);
    input clk, rst, Set, Jump, Stop, Recount_counter;
    output [3:0] Rout, Gout, Yout;

    reg[1:0] currentstate, nextstate;
    reg Rout, Gout, Yout;

    parameter [1:0] Red_Light = 0 , Green_Light = 1, Yellow_Light = 2;

    always @(posedge  clk) begin
        if(rst | Set) begin
            currentstate <= Green_Light;
        end
        else if(Jump) begin
            currentstate  <= Red_Light;
        end
        else if(Stop) begin
            currentstate <= currentstate;
        end
        else begin
            currentstate <= nextstate;
        end
    end

    always @(*) begin
        case(currentstate)
            Red_Light: begin
                if (Recount_counter)
                    nextstate = Green_Light;
                else
                    nextstate = Red_Light ;
            end
            Green_Light: begin
                if(Recount_counter)
                    nextstate = Yellow_Light;
                else 
                    nextstate = Green_Light ;
            end
            Yellow_Light: begin
                if(Recount_counter)
                    nextstate = Red_Light;
                else
                    nextstate = Yellow_Light;
            end
            default : 
                nextstate = Green_Light;
        endcase
    end

    always @(currentstate) begin
        case(currentstate)
            Red_Light:
            begin
                Rout = 1'b1;
                Gout = 1'b0;
                Yout = 1'b0;
            end
            Green_Light: 
            begin
                Rout = 1'b0;
                Gout = 1'b1;
                Yout = 1'b0;
            end
            Yellow_Light: 
            begin
                Rout = 1'b0;
                Gout = 1'b0;
                Yout = 1'b1;
            end
            default:
            begin
                Rout = 1'b0;
                Gout = 1'b0;
                Yout = 1'b0;
            end
        endcase
    end
endmodule

module Counter(clk, rst, Set, Stop, Jump, Recount_counter, Count_out);
    input clk , rst , Set, Stop, Jump, Recount_counter;
    output [3:0] Count_out;

    reg [3:0] Count_out;

    always @(posedge  clk) begin
        if(rst | Jump | Set | Recount_counter) begin
            Count_out <= 1;
        end
        else if(Stop) begin
            Count_out <= Count_out;
        end
        else begin
            Count_out <= Count_out + 1;
        end
    
    end
endmodule

module Compare(clk, Set, Stop,RGY, Rin, Yin, Gin, Current_time, Recount_counter);
    input clk, Set, Stop;
    input [2:0] RGY;
    input [3:0] Current_time;
    input [3:0] Gin, Yin, Rin;
    output Recount_counter;

    reg [3:0] R_time, Y_time, G_time;
    reg Recount_counter;

    always @(posedge clk)begin
        if (Set) begin
            R_time <= Rin;
            Y_time <= Yin;
            G_time <= Gin;
        end
        else begin
            R_time <= R_time;
            Y_time <= Y_time;
            G_time <= G_time;
        end
    end

    always @(*)begin
        case(RGY)
            3'b100: begin
                if(Current_time == R_time && Stop != 1) begin
                    Recount_counter = 1;
                end
                else begin
                    Recount_counter = 0;
                end
            end
            3'b001: begin
                if(Current_time == Y_time && Stop != 1) begin
                    Recount_counter = 1;
                end
                else begin
                    Recount_counter = 0;
                end
            end
            3'b010: begin
                if(Current_time == G_time && Stop != 1) begin
                    Recount_counter = 1;
                end
                else begin
                    Recount_counter = 0;
                end
            end
            default: begin
                Recount_counter = 1;
            end
        endcase
    end
endmodule