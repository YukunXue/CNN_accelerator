
`timescale 1ps/1ps


module pe (
	input clk,
	input rst_n,
	
	input        vld_i,
	input [8*9 -1 :0] x,
	input [8*9 -1 :0] w,

	output [2*8-1 :0] res, 
	output            vld_o
);
	wire [7:0] x00;
	wire [7:0] x01;
	wire [7:0] x02;
	wire [7:0] x10;
	wire [7:0] x11;
	wire [7:0] x12;
	wire [7:0] x20;
	wire [7:0] x21;
	wire [7:0] x22;

	assign x00 = x[8*8 +: 8];
	assign x01 = x[8*7 +: 8];
	assign x02 = x[8*6 +: 8];
	assign x10 = x[8*5 +: 8];
	assign x11 = x[8*4 +: 8];
	assign x12 = x[8*3 +: 8];
	assign x20 = x[8*2 +: 8];
	assign x21 = x[8*1 +: 8];
	assign x22 = x[8*0 +: 8];

	wire [7:0] w00 = w[8*8 +: 8];
	wire [7:0] w01 = w[8*7 +: 8];
	wire [7:0] w02 = w[8*6 +: 8];
	wire [7:0] w10 = w[8*5 +: 8];
	wire [7:0] w11 = w[8*4 +: 8];
	wire [7:0] w12 = w[8*3 +: 8];
	wire [7:0] w20 = w[8*2 +: 8];
	wire [7:0] w21 = w[8*1 +: 8];
	wire [7:0] w22 = w[8*0 +: 8];

	wire [2*8-1 : 0] mul_res1 = w00 * x00 + w01 * x01 + w02 * x02;
	wire [2*8-1 : 0] mul_res2 = w10 * x10 + w11 * x11 + w12 * x12;
	wire [2*8-1 : 0] mul_res3 = w20 * x20 + w21 * x21 + w22 * x22;

	reg vld_o_r;

	wire [2*8-1 : 0] sum = (rst_n)? 'd0 :  mul_res1 + mul_res2 +mul_res3;
	reg  [2*8-1 : 0] sum_res;


	always @(posedge clk) begin
		if(rst_n)begin
			vld_o_r <= 1'b0;
		end
		else if( vld_i)begin
			vld_o_r <= 1'b1;
		end
	end

	always @(posedge clk) begin
		if(rst_n)begin
			sum_res <= 'd0;
		end
		else if(vld_i)begin
			sum_res <= sum;
		end
	end

	assign vld_o = vld_o_r;
	assign res = sum;

endmodule