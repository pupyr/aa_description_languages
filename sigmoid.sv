`timescale 1ns/1ns

module sigmoid(
    input  logic [`OP_SIZE-1:0] x,
    output logic [`OP_SIZE-1:0] y
);

localparam MT4 = `OP_SIZE-14;
localparam DOUBLE_SIZE = (`OP_SIZE)*2;
localparam SINGLE_SIZE = `OP_SIZE;
localparam HALF_SIZE = (`OP_SIZE)>>1;
localparam HALF = {{HALF_SIZE{1'b0}},1'b1,{(HALF_SIZE-1){1'b0}}};
localparam HALF_NEG = {{HALF_SIZE{1'b1}},1'b0,{(HALF_SIZE-1){1'b1}}};

logic neg, more_then_4;
assign neg = x[`OP_SIZE-1];
assign more_then_4 = neg ? !(&x[`OP_SIZE-1:MT4])
                         :   |x[`OP_SIZE-1:MT4];

logic [DOUBLE_SIZE-1:0] z, x_signed;
logic [SINGLE_SIZE-1:0] x_func;
assign x_signed = {{SINGLE_SIZE{neg}}, x};
assign x_func = SINGLE_SIZE'({{2{neg}},x_signed[DOUBLE_SIZE-1:2]}) + 
                    (neg ? SINGLE_SIZE'(1<<HALF_SIZE) : {{HALF_SIZE{1'b1}},{HALF_SIZE{1'b0}}});
assign z = { {SINGLE_SIZE{1'(!neg)}} ,SINGLE_SIZE'(x_func)};

logic [DOUBLE_SIZE-1:0] z_sqr, z_shift;
assign z_sqr = z*z;
assign z_shift = z_sqr>>(HALF_SIZE+1);

assign y = more_then_4 ? neg ? HALF_NEG : HALF
                       : neg ? SINGLE_SIZE'(z_shift)+HALF_NEG
                             : SINGLE_SIZE'(HALF<<1)-SINGLE_SIZE'(z_shift)+HALF_NEG;

endmodule