# ----------------------------------------------------------------------------
# FILE: 	Clock_groups.vhd
# DESCRIPTION:	Clock group assigments for TimeQuest
# DATE:	June 2, 2017
# AUTHOR(s):	Lime Microsystems
# REVISIONS:
# ----------------------------------------------------------------------------
# NOTES:
# This file must be last in .sdc file list
# ----------------------------------------------------------------------------

# Set asynchronous design clocks.											
set_clock_groups -asynchronous 	-group {PCIE_REFCLK} \
											-group {inst46|inst1_xillybus|pcie|pcie_reconfig|pcie|altpcie_av_hip_ast_hwtcl|altpcie_av_hip_128bit_atom|g_cavhip.arriav_hd_altpe2_hip_top|coreclkout} \
											-group {FX3_SPI_SCLK} \
											-group {CLK_LMK_FPGA_IN} \
                                 -group {FPGA_PLL_VCOPH} \
											-group {FPGA_PLL_C0}	\
											-group {FPGA_PLL_C1} \
											-group {altera_reserved_tck} \
											-group {CLK100_FPGA} \
											-group {CLK125_FPGA_BOT} \
											-group {CLK125_FPGA_TOP} \
											-group {LMS1_MCLK1} \
                                 -group {LMS1_MCLK1_GLOBAL} \
											-group {LMS1_TXPLL_VCOPH} \
											-group {LMS1_TXPLL_C0} \
											-group {LMS1_TXPLL_C1} \
											-group {LMS1_MCLK2} \
                                 -group {LMS1_MCLK2_GLOBAL} \
											-group {LMS1_RXPLL_VCOPH} \
											-group {LMS1_RXPLL_C0} \
											-group {LMS1_RXPLL_C1} \
											-group {LMS2_MCLK1} \
                                 -group {LMS2_MCLK1_GLOBAL} \
											-group {LMS2_TXPLL_C0} \
											-group {LMS2_TXPLL_C1} \
											-group {LMS2_MCLK2} \
                                 -group {LMS2_MCLK2_GLOBAL} \
											-group {LMS2_RXPLL_VCOPH} \
											-group {LMS2_RXPLL_C0} \
											-group {LMS2_RXPLL_C1} \
											-group {NIOS_PLLCFG_SCLK} \
											-group {NIOS_DACSPI1_SCLK} \
                                 -group {NIOS_FPGASPI0_SCLK} \
											-group {ADC_CLKOUT}
                                 
set_false_path -from [get_clocks *xillybus*\|*core*] \
               -to [get_clocks *DDR3_avmm_2x32_ctrl*\|*pll_afi_half_clk*]
               
               
set_false_path -from [get_clocks *DDR3_avmm_2x32_ctrl*\|*pll_afi_half_clk*] \
               -to [get_clocks LMS2_TXPLL_C1]
               
set_false_path -from [get_clocks *DDR3_avmm_2x32_ctrl*\|*pll_afi_half_clk*] \
               -to [get_clocks LMS1_TXPLL_C1]
                            
set_false_path -from [get_clocks *DDR3_avmm_2x32_ctrl*\|*pll_afi_half_clk*] \
               -to [get_clocks FPGA_PLL_C1]
               
#set_false_path -from {inst20|ext_mem_inst2|ddr3_av_2x32_inst|pll0|pll5~PLL_OUTPUT_COUNTER|divclk} \
#               -to {FPGA_PLL_C1}
               
              

               
               
               