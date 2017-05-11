#To avoid warnings with truncated timing values
set_time_format -unit ns -decimal_places 4 
#=======================Timing parameters===================================
#CLK100_FPGA
	#Clock period 100MHz
set CLK100_FPGA_prd			10.0

#CLK_LMK_FPGA_IN
	#Clock period 30.72MHz
set CLK_LMK_FPGA_IN_prd		32.552083

#CLK125_FPGA_TOP
	#Clock period 125MHz
set CLK125_FPGA_TOP_prd		8.0

#CLK125_FPGA_BOT
	#Clock period 125MHz
set CLK125_FPGA_BOT_prd		8.0

#FX3_SPI_SCLK
	#Clock period 10MHz
set FX3_SPI_SCLK_prd			100.0

#PCIE_REFCLK
	#Clock period 100MHz
set PCIE_REFCLK_prd			10.0

#NIOS PLLCFG_SCLK
	#Clock period 10MHz
set NIOS_PLLCFG_SCLK_prd	100.0

#NIOS PLLCFG_SCLK
	#Clock period 5MHz
set NIOS_DACSPI1_SCLK_prd	200.0

set NIOS_PLLCFG_SCLK_div 	[expr {int($NIOS_PLLCFG_SCLK_prd / $CLK100_FPGA_prd)}]
set NIOS_DACSPI1_SCLK_div 	[expr {int($NIOS_DACSPI1_SCLK_prd / $CLK100_FPGA_prd)}]

#=======================Base clocks=====================================
#FPGA pll, 100MHz
create_clock -period $CLK100_FPGA_prd 		-name CLK100_FPGA 		[get_ports CLK100_FPGA]
#LMK clk, 30.72MHz
create_clock -period $CLK_LMK_FPGA_IN_prd	-name CLK_LMK_FPGA_IN	[get_ports CLK_LMK_FPGA_IN]
#FX3 spi clock
create_clock -period $FX3_SPI_SCLK_prd 	-name FX3_SPI_SCLK 		[get_ports FX3_SPI_SCLK]
#RAM clk
create_clock -period $CLK125_FPGA_TOP_prd	-name CLK125_FPGA_BOT	[get_ports CLK125_FPGA_BOT]
create_clock -period $CLK125_FPGA_BOT_prd	-name CLK125_FPGA_TOP	[get_ports CLK125_FPGA_TOP]
#PCIE
create_clock -period $PCIE_REFCLK_prd 		-name PCIE_REFCLK 		[get_ports PCIE_REFCLK]

#======================Virtual clocks============================================

#======================Generated clocks==========================================
#FPGA pll
	#FPGA PLL VCO
create_generated_clock -name FPGA_PLL_VCO \
-source [get_pins {inst34|fpga_pll_inst|altera_pll_i|cyclonev_pll|fpll_0|fpll|refclkin}] \
-divide_by 6 -multiply_by 125 \
[get_pins {inst34|fpga_pll_inst|altera_pll_i|cyclonev_pll|fpll_0|fpll|vcoph[0]}]
	#FPGA PLL C0 (Clock output for ADC)
create_generated_clock -name FPGA_PLL_C0 \
-source [get_pins {inst34|fpga_pll_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|vco0ph[0]}] \
-divide_by 4 -multiply_by 1 \
[get_pins {inst34|fpga_pll_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}]
	#FPGA PLL C1 (Clock for DAC)
create_generated_clock -name FPGA_PLL_C1 \
-source [get_pins {inst34|fpga_pll_inst|altera_pll_i|cyclonev_pll|counter[1].output_counter|vco0ph[0]}] \
-divide_by 4 -multiply_by 1 \
[get_pins {inst34|fpga_pll_inst|altera_pll_i|cyclonev_pll|counter[1].output_counter|divclk}]

#Clock outputs generated with FPGA PLL
	#For ADC
create_generated_clock 	-name ADC_CLK \
								-source [get_pins {inst13|ALTDDIO_OUT_component|auto_generated|ddio_outa[0]|dataout}] [get_ports ADC_CLK]
	#For DAC
create_generated_clock 	-name DAC_CLK_WRT \
								-invert \
								-source [get_pins {inst33|ALTDDIO_OUT_component|auto_generated|ddio_outa[0]|dataout}] [get_ports DAC_CLK_WRT]


#NIOS II generated clocks 
create_generated_clock 	-name NIOS_PLLCFG_SCLK \
								-divide_by $NIOS_PLLCFG_SCLK_div \
								-source [get_ports {CLK100_FPGA}] \
[get_registers {nios_cpu_top:inst175|nios_cpu:u0|nios_cpu_PLLCFG_SPI:pllcfg_spi|SCLK_reg}]

create_generated_clock 	-name NIOS_DACSPI1_SCLK \
								-divide_by $NIOS_DACSPI1_SCLK_div \
								-source [get_ports {CLK100_FPGA}] \
[get_registers {nios_cpu_top:inst175|nios_cpu:u0|nios_cpu_dac_spi1:dac_spi1|SCLK_reg}]

#Read periphery constraints files
read_sdc LMS1_timing.sdc
read_sdc LMS2_timing.sdc
read_sdc ADS4246_timing.sdc
read_sdc DAC5672_timing.sdc

#====================Other clock constraints====================================
# clock uncertainty is already derived in other sdc files
#derive_clock_uncertainty
derive_pll_clocks
#====================Input constraints====================================

#====================Ootput constraints====================================



# Set asynchronous design clocks.											
set_clock_groups -asynchronous 	-group {PCIE_REFCLK} \
											-group {inst46|inst1_xillybus|pcie|pcie_reconfig|pcie|altpcie_av_hip_ast_hwtcl|altpcie_av_hip_128bit_atom|g_cavhip.arriav_hd_altpe2_hip_top|coreclkout} \
											-group {inst39|DDR3_avmm_2x32_ctrl_inst3|ddr3_av_2x32_inst4|ddr3_av_2x32_inst|pll0|pll_afi_half_clk} \
											-group {inst39|DDR3_avmm_2x32_ctrl_inst3|ddr3_av_2x32_inst4|ddr3_av_2x32_inst|pll0|pll5~PLL_OUTPUT_COUNTER|divclk} \
											-group {FX3_SPI_SCLK} \
											-group {CLK_LMK_FPGA_IN} \
											-group {altera_reserved_tck} \
											-group {CLK100_FPGA} \
											-group {CLK125_FPGA_BOT} \
											-group {CLK125_FPGA_TOP} \
											-group {LMS1_MCLK1} \
											-group {LMS1_TXPLL_VCO} \
											-group {LMS1_TXPLL_C0} \
											-group {LMS1_TXPLL_C1} \
											-group {LMS1_MCLK2} \
											-group {LMS1_RXPLL_VCO} \
											-group {LMS1_RXPLL_C0} \
											-group {LMS1_RXPLL_C1} \
											-group {LMS2_MCLK1} \
											-group {LMS2_TXPLL_C0} \
											-group {LMS2_TXPLL_C1} \
											-group {LMS2_MCLK2} \
											-group {LMS2_RXPLL_VCO} \
											-group {LMS2_RXPLL_C0} \
											-group {LMS2_RXPLL_C1} \
											-group {NIOS_PLLCFG_SCLK} \
											-group {NIOS_DACSPI1_SCLK} \
											-group {ADC_CLKOUT} \
											-group {FPGA_PLL_VCO} \
											-group {FPGA_PLL_C0}	\
											-group {FPGA_PLL_C1}
											
set_false_path -from [get_clocks {FPGA_PLL_C1}] -to [get_clocks {ADC_CLKOUT}]
set_false_path -from [get_clocks {NIOS_DACSPI1_SCLK}] -to [get_clocks {ADC_CLKOUT}]
											
#============================Timing Exceptions====================================

#============================False paths========================================
#Clock outputs 
set_false_path -to [get_ports ADC_CLK]
set_false_path -to [get_ports DAC_CLK_WRT]


#set false paths
set_false_path -from * -to [get_ports FPGA_LED* ]
set_false_path -from * -to [get_ports PMOD_A_PIN*]
set_false_path -from [get_ports FPGA_SW*] -to *
set_false_path -from [get_ports EXT_GND*] -to *
set_false_path -from [get_ports PCIE_PERSTn]

#Currently we dont care about these slow inputs
set_false_path -from [get_ports FPGA_SPI0_MISO]
set_false_path -from [get_ports FX3_SPI_FPGA_SS]
set_false_path -from [get_ports FX3_SPI_MOSI]
set_false_path -from [get_ports LM75_OS]

#Currently we dont care about these slow outputs
set_false_path -from [get_ports FPGA_SPI0_MISO]
set_false_path -from [get_ports FX3_SPI_FPGA_SS]
set_false_path -from [get_ports FX3_SPI_MOSI]
set_false_path -from [get_ports LM75_OS]

set_false_path -to [get_ports FAN_CTRL]
set_false_path -to [get_ports FPGA_ADC_RESET]
set_false_path -to [get_ports {FPGA_SPI0*}]
set_false_path -to [get_ports FX3_SPI_MISO]
set_false_path -to [get_ports LMS1_CORE_LDO_EN]
set_false_path -to [get_ports LMS1_RESET]
set_false_path -to [get_ports LMS1_RXEN]
set_false_path -to [get_ports LMS1_TXEN]
set_false_path -to [get_ports LMS1_TXNRX1]
set_false_path -to [get_ports LMS1_TXNRX2]
set_false_path -to [get_ports LMS2_CORE_LDO_EN]
set_false_path -to [get_ports LMS2_RESET]
set_false_path -to [get_ports LMS2_RXEN]
set_false_path -to [get_ports LMS2_TXEN]
set_false_path -to [get_ports LMS2_TXNRX1]
set_false_path -to [get_ports LMS2_TXNRX2]

#Between sych registers
set_false_path -from [get_registers {stream_switch:inst41|dest_sel_syncreg[1]}]

set_false_path -from [get_registers {data_cap_buffer:inst27|wclk2_reset_n_sync[1]}]
set_false_path -from [get_registers {rx_path:inst10|rx_pct_data_v2:inst3|en_reg1}]
set_false_path -from [get_registers {LTE_tx_path:inst38|synchronizer:inst28|signal_d1}]
set_false_path -from [get_registers {rx_path:inst12|rx_pct_data_v2:inst3|en_reg1}]
set_false_path -from [get_registers {wfm_player_x2_top:inst39|inst3_reset_n}]






# False Paths on JTAG (for SignalTap)
if {[get_collection_size [get_ports -nowarn {altera_reserved*}]] > 0} {
	if {[get_collection_size [get_clocks -nowarn {altera_reserved_tck}]] == 0} {
		create_clock -period "10 MHz" -name altera_reserved_tck [get_ports altera_reserved_tck]
	}
	set_false_path -from [get_ports {altera_reserved_tdi}]
	set_false_path -from [get_ports {altera_reserved_tms}]
	set_false_path -to [get_ports {altera_reserved_tdo}]
	# Specify the JTAG clock in a group
	set_clock_groups -asynchronous -group altera_reserved_tck
}

#False paths between DCFIFO used in design
#For paths crossing from the write into the read domain, (between the delayed_wrptr_g and rs_dgwp registers)
set_false_path -from [get_registers {*dcfifo*delayed_wrptr_g[*]}] -to [get_registers {*dcfifo*rs_dgwp*}]
# For paths crossing from the read into the write domain (between the rdptr_g and ws_dgrp registers)
set_false_path -from [get_registers {*dcfifo*rdptr_g[*]}] -to [get_registers {*dcfifo*ws_dgrp*}]


