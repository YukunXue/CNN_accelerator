`timescale 1ps/1ps

module top(

	input clk,
	input rst_n,

	input 		vld_i,
	//input [1:0] ctrl,
	input [72*3 - 1 : 0] w,
	input [72*46 - 1 : 0] x0,
	input [72*46 - 1 : 0] x1,
	input [72*46 - 1 : 0] x2,

	output [46*2*8-1:0] res_o_1,
	output [46*2*8-1:0] res_o_2,
	output [46*2*8-1:0] res_o_3,
	output done,
	output vld_o
);

	wire [8*9-1 : 0] w1 = w[72 *0 +: 72];
	wire [8*9-1 : 0] w2 = w[72 *1 +: 72];
	wire [8*9-1 : 0] w3 = w[72 *2 +: 72];

	reg [2*8-1 :0] res1 [0:45];
	reg [2*8-1 :0] res2 [0:45];
	reg [2*8-1 :0] res3 [0:45];

	wire vld_o1;
	wire vld_o2;
	wire vld_o3;

	generate
		genvar i;
		for(i = 0; i < 46; i++) begin: pe1_block
			pe u_pei(
				.clk	( clk  ),
				.rst_n	( rst_n),
				.vld_i  ( vld_i),
				.x      ( x0[9*8*i +: 72]),
				.w      ( w3),
				.res    ( res1[i]),
				.vld_o  (vld_o1)
			);
		end
	endgenerate

	generate
		genvar j;
		for(j = 0; j < 46; j++) begin: pe2_block
			pe u_pej(
				.clk	( clk  ),
				.rst_n	( rst_n),
				.vld_i  ( vld_i),
				.x      ( x1[9*8*j +: 72]),
				.w      ( w2),
				.res    ( res2[j]),
				.vld_o  (vld_o2)
			);
		end
	endgenerate


	generate
		genvar k;
		for(k = 0; k < 46; k++) begin: pe3_block
			pe u_pek(
				.clk	( clk  ),
				.rst_n	( rst_n),
				.vld_i  ( vld_i),
				.x      ( x2[9*8*k +: 72]),
				.w      ( w1),
				.res    ( res3[k]),
				.vld_o  (vld_o3)
			);
		end
	endgenerate

	reg [2*8*3-1 : 0] out_res;

	always @(posedge clk) begin
		if(rst_n)begin
			out_res <= 'd0; 
		end
		else begin
			if(vld_o)begin
				out_res <= {res1[1], res2[1], res3[1]};
			end
		end
	end


	reg [5:0] count;
	reg done_flag;

	always @(posedge clk) begin
		if(rst_n) begin
			count <= 6'd1;
			done_flag <= 'd0;
		end
		else if( count == 6'd47 && vld_i)begin
			count <= 'd1;
			done_flag <= 'd1;
		end
		else if(vld_i) begin
			count <= count + 6'd1;
			done_flag <= 'd0;
		end
	end

	reg [46*2*8-1:0] x0_res;
	reg [46*2*8-1:0] x1_res;
	reg [46*2*8-1:0] x2_res;


	reg [7:0] m;

	always @(*) begin
		x0_res = 'd0;
		x1_res = 'd0;
		x2_res = 'd0;
		for (m = 0; m < 46; m = m+1) begin
			x0_res[2*8*m +: 2*8] = res1[m];
			x1_res[2*8*m +: 2*8] = res2[m];
			x2_res[2*8*m +: 2*8] = res3[m];
		end
	end

	assign res_o_1 = x0_res;
	assign res_o_2 = x1_res;
	assign res_o_3 = x2_res;

	assign done = done_flag;
	assign vld_o =(~done_flag)? vld_o1 & vld_o2 & vld_o3 : 'd0;
endmodule