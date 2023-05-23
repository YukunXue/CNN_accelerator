`timescale 1ps/1ps


module tb_top(
);


logic clk;
logic rst_n;

initial begin
	clk = 1'b0;
	forever #0.5 clk = ~clk;
end

initial begin
	rst_n = 1'b1;
	vld_i = 1'b0;
	#4 rst_n = ~rst_n;
		vld_i = 1'b1;

end


initial
begin            
    $dumpfile("../build/tb_top.vcd");       
    $dumpvars(0, tb_top);    
end

localparam DAT_W = 8;
localparam PIC_W = 48;
localparam PIC_H = 48;
localparam PIC_C = 3;

localparam K_SIZE = 3;
localparam K_C = 3;


logic  [PIC_W*DAT_W-1:0]  image0 [0:PIC_H-1]; 
logic  [PIC_W*DAT_W-1:0]  image1 [0:PIC_H-1]; 
logic  [PIC_W*DAT_W-1:0]  image2 [0:PIC_H-1]; 

logic  [K_SIZE*DAT_W-1:0] weight[0:K_SIZE*K_C-1];


initial
begin
  $readmemh("../data/image0", image0);
  $readmemh("../data/image1", image1);
  $readmemh("../data/image2", image2);
  $readmemh("../data/weight", weight);
end

initial
begin
  #10000 $finish;
end

logic [K_SIZE * K_SIZE * DAT_W * K_C] w_in ;

always @(posedge clk) begin
	if(rst_n)begin
		w_in <= 'd0;
	end
	else if( k < 6'd46) begin
		w_in <= {
			weight[0], weight[1], weight[2],
			weight[3], weight[4], weight[5],
			weight[6], weight[7], weight[8]
		};
	end		
end

logic 		vld_i;
logic [1:0] ctrl;


logic [PIC_W*DAT_W-1:0] shiftReg00;
logic [PIC_W*DAT_W-1:0] shiftReg01;
logic [PIC_W*DAT_W-1:0] shiftReg02;

logic [PIC_W*DAT_W-1:0] shiftReg10;
logic [PIC_W*DAT_W-1:0] shiftReg11;
logic [PIC_W*DAT_W-1:0] shiftReg12;

logic [PIC_W*DAT_W-1:0] shiftReg20;
logic [PIC_W*DAT_W-1:0] shiftReg21;
logic [PIC_W*DAT_W-1:0] shiftReg22;

logic [5:0] k;

always @(posedge clk) begin
	if(rst_n) begin
		k <= 6'd1;
	end
	else if( k == 6'd47)begin
		k <= 'd1;
	end
	else begin
		k <= k + 6'd1;
	end
end

always @(posedge clk) begin
	if(rst_n)begin
		shiftReg00 <= image0[0];
		shiftReg01 <= image0[1];
		shiftReg02 <= image0[2];
	end
	else if( k < 6'd47) begin
		shiftReg00 <= image0[k-1];
		shiftReg01 <= image0[k];
		shiftReg02 <= image0[k+1];
	end		
end

always @(posedge clk) begin
	if(rst_n)begin
		shiftReg10 <= image1[0];
		shiftReg11 <= image1[1];
		shiftReg12 <= image1[2];
	end
	else if( k < 6'd47) begin
		shiftReg10 <= image1[k-1];
		shiftReg11 <= image1[k];
		shiftReg12 <= image1[k+1];
	end	
end

always @(posedge clk) begin
	if(rst_n)begin
		shiftReg20 <= image2[0];
		shiftReg21 <= image2[1];
		shiftReg22 <= image2[2];
	end
	else if( k < 6'd47) begin
		shiftReg20 <= image2[k-1];
		shiftReg21 <= image2[k];
		shiftReg22 <= image2[k+1];		
	end
end


logic [7:0] i;

logic [46*9*8 - 1 : 0] x0_in;
logic [46*9*8 - 1 : 0] x1_in;
logic [46*9*8 - 1 : 0] x2_in;


//assign x0_in ={ shiftReg00[3*8 -1:0], shiftReg01[2:0], shiftReg01[2:0], 
//				shiftReg00[4*8 -1:1*8], shiftReg01[3:1], shiftReg01[3:1], 
//				shiftReg00[5*8 -1:2*8], shiftReg01[4:2], shiftReg01[4:2], 
//				shiftReg00[6*8 -1:3*8], shiftReg01[5:3], shiftReg01[5:3], 
//				shiftReg00[7*8 -1:4*8], shiftReg01[14:12], shiftReg01[14:12], 
//				shiftReg00[8:15], shiftReg01[17:15], shiftReg01[17:15], 
//				shiftReg00[9:18], shiftReg01[20:18], shiftReg01[20:18], 
//				shiftReg00[10:21], shiftReg01[23:21], shiftReg01[23:21], 
//				shiftReg00[11:0], shiftReg01[2:0], shiftReg01[2:0], 
//				shiftReg00[12:0], shiftReg01[2:0], shiftReg01[2:0], 
//				shiftReg00[13:0], shiftReg01[2:0], shiftReg01[2:0], 
//				shiftReg00[14:0], shiftReg01[2:0], shiftReg01[2:0],
//				};

always @(*) begin
	x0_in = 'd0;
	x1_in = 'd0;
	x2_in = 'd0;
	for (i = 0; i < 46; i = i+1) begin
		x0_in[9*8*i +: 9*8] = {shiftReg00[8*i +: 3*8], shiftReg01[8*i +: 3*8], shiftReg02[8*i +: 3*8]};
		x1_in[9*8*i +: 9*8] = {shiftReg10[8*i +: 3*8], shiftReg11[8*i +: 3*8], shiftReg12[8*i +: 3*8]};
		x2_in[9*8*i +: 9*8] = {shiftReg20[8*i +: 3*8], shiftReg21[8*i +: 3*8], shiftReg22[8*i +: 3*8]};
	end
end


logic done;
logic vld_o;
logic [46*2*8-1:0] res_o1;
logic [46*2*8-1:0] res_o2;
logic [46*2*8-1:0] res_o3;


top u_top(
	.clk   (clk),
	.rst_n (rst_n),
	
	.vld_i (vld_i),

	.w     (w_in),
	.x0    (x0_in),
	.x1    (x1_in),
	.x2    (x2_in),

	.res_o_1(res_o1),
	.res_o_2(res_o2),
	.res_o_3(res_o3),

	.done  (done),
	.vld_o (vld_o)
);

integer dut_diff1;
integer dut_diff2;
integer dut_diff3;


initial begin
	dut_diff1 = $fopen("../data/dut_diff_o1","w");
	dut_diff2 = $fopen("../data/dut_diff_o2","w");
	dut_diff3 = $fopen("../data/dut_diff_o3","w");
end

always @(posedge clk) begin
	if(vld_o) begin
		$fwrite(dut_diff1, "%x \n", res_o1);
		$fwrite(dut_diff2, "%x \n", res_o2);
		$fwrite(dut_diff3, "%x \n", res_o3);
	end
	else if(done) begin
		$fclose(dut_diff1);
		$fclose(dut_diff2);
		$fclose(dut_diff3);
	end
end

endmodule