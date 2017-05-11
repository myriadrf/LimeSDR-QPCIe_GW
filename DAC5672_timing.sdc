################################################################################
#Timing parameters for DAC5672
#Interface				: Source synchronous SDR, center aligned
#LAUNCH CLK source 	: FPGA_PLL_C1
#LATCH CLK source 	: Inverted FPGA_PLL_C1 clock with DDIO cell 
################################################################################
#DAC
set DAC_Tsu	1.0
set DAC_Th	1.0
	#Calculated expresions
set DAC_max_dly [expr $DAC_Tsu]
set DAC_min_dly [expr -$DAC_Th]
################################################################################
#Base clocks
################################################################################

#Base clocks created in top level .sdc file

################################################################################
#Virtual clocks
################################################################################

#-

################################################################################
#Generated clocks
################################################################################

#Generated clocks created in top level .sdc file

################################################################################
#Output constraints
################################################################################
set_output_delay -max $DAC_max_dly -clock [get_clocks DAC_CLK_WRT] [get_ports DAC*]
set_output_delay -min $DAC_min_dly -clock [get_clocks DAC_CLK_WRT] [get_ports DAC*] -add_delay

################################################################################
#Exceptions
################################################################################
#To cut paths for falling edge transfers in center aligned SDR interface 
set_false_path -fall_from [get_clocks FPGA_PLL_C1]

#Clock groups					
#Clock groups are set in top .sdc file