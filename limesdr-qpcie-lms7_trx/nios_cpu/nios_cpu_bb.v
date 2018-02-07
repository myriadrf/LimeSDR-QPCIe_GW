
module nios_cpu (
	clk_clk,
	dac_spi1_MISO,
	dac_spi1_MOSI,
	dac_spi1_SCLK,
	dac_spi1_SS_n,
	exfifo_if_d_export,
	exfifo_if_rd_export,
	exfifo_if_rdempty_export,
	exfifo_of_d_export,
	exfifo_of_wr_export,
	exfifo_of_wrfull_export,
	exfifo_rst_export,
	fpga_spi0_MISO,
	fpga_spi0_MOSI,
	fpga_spi0_SCLK,
	fpga_spi0_SS_n,
	gpi0_export,
	gpio0_export,
	pll_lock_external_connection_export,
	pll_recfg_from_pll_0_reconfig_from_pll,
	pll_recfg_from_pll_1_reconfig_from_pll,
	pll_recfg_from_pll_2_reconfig_from_pll,
	pll_recfg_from_pll_3_reconfig_from_pll,
	pll_recfg_from_pll_4_reconfig_from_pll,
	pll_recfg_from_pll_5_reconfig_from_pll,
	pll_recfg_to_pll_0_reconfig_to_pll,
	pll_recfg_to_pll_1_reconfig_to_pll,
	pll_recfg_to_pll_2_reconfig_to_pll,
	pll_recfg_to_pll_3_reconfig_to_pll,
	pll_recfg_to_pll_4_reconfig_to_pll,
	pll_recfg_to_pll_5_reconfig_to_pll,
	pll_rst_export,
	pllcfg_cmd_export,
	pllcfg_err_external_connection_export,
	pllcfg_spi_MISO,
	pllcfg_spi_MOSI,
	pllcfg_spi_SCLK,
	pllcfg_spi_SS_n,
	pllcfg_stat_export,
	scl_export,
	sda_export,
	smpl_cmp_en_external_connection_export,
	smpl_cmp_status_external_connection_export);	

	input		clk_clk;
	input		dac_spi1_MISO;
	output		dac_spi1_MOSI;
	output		dac_spi1_SCLK;
	output		dac_spi1_SS_n;
	input	[31:0]	exfifo_if_d_export;
	output		exfifo_if_rd_export;
	input		exfifo_if_rdempty_export;
	output	[31:0]	exfifo_of_d_export;
	output		exfifo_of_wr_export;
	input		exfifo_of_wrfull_export;
	output		exfifo_rst_export;
	input		fpga_spi0_MISO;
	output		fpga_spi0_MOSI;
	output		fpga_spi0_SCLK;
	output	[7:0]	fpga_spi0_SS_n;
	input	[7:0]	gpi0_export;
	output	[7:0]	gpio0_export;
	input	[7:0]	pll_lock_external_connection_export;
	input	[63:0]	pll_recfg_from_pll_0_reconfig_from_pll;
	input	[63:0]	pll_recfg_from_pll_1_reconfig_from_pll;
	input	[63:0]	pll_recfg_from_pll_2_reconfig_from_pll;
	input	[63:0]	pll_recfg_from_pll_3_reconfig_from_pll;
	input	[63:0]	pll_recfg_from_pll_4_reconfig_from_pll;
	input	[63:0]	pll_recfg_from_pll_5_reconfig_from_pll;
	output	[63:0]	pll_recfg_to_pll_0_reconfig_to_pll;
	output	[63:0]	pll_recfg_to_pll_1_reconfig_to_pll;
	output	[63:0]	pll_recfg_to_pll_2_reconfig_to_pll;
	output	[63:0]	pll_recfg_to_pll_3_reconfig_to_pll;
	output	[63:0]	pll_recfg_to_pll_4_reconfig_to_pll;
	output	[63:0]	pll_recfg_to_pll_5_reconfig_to_pll;
	output	[31:0]	pll_rst_export;
	input	[3:0]	pllcfg_cmd_export;
	output	[7:0]	pllcfg_err_external_connection_export;
	input		pllcfg_spi_MISO;
	output		pllcfg_spi_MOSI;
	output		pllcfg_spi_SCLK;
	output		pllcfg_spi_SS_n;
	output	[7:0]	pllcfg_stat_export;
	inout		scl_export;
	inout		sda_export;
	output	[1:0]	smpl_cmp_en_external_connection_export;
	input	[1:0]	smpl_cmp_status_external_connection_export;
endmodule