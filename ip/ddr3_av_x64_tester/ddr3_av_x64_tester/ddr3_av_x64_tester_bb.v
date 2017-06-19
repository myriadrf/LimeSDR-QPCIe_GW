
module ddr3_av_x64_tester (
	avl_ready,
	avl_addr,
	avl_size,
	avl_wdata,
	avl_rdata,
	avl_write_req,
	avl_read_req,
	avl_rdata_valid,
	avl_be,
	avl_burstbegin,
	clk,
	reset_n,
	pnf_per_bit,
	pnf_per_bit_persist,
	pass,
	fail,
	test_complete);	

	input		avl_ready;
	output	[25:0]	avl_addr;
	output	[1:0]	avl_size;
	output	[63:0]	avl_wdata;
	input	[63:0]	avl_rdata;
	output		avl_write_req;
	output		avl_read_req;
	input		avl_rdata_valid;
	output	[7:0]	avl_be;
	output		avl_burstbegin;
	input		clk;
	input		reset_n;
	output	[63:0]	pnf_per_bit;
	output	[63:0]	pnf_per_bit_persist;
	output		pass;
	output		fail;
	output		test_complete;
endmodule
