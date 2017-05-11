################################################################################
#Time settings
################################################################################
set_time_format -unit ns -decimal_places 3

################################################################################
#Timing parameters
################################################################################
#LMS7002
	#LMS_MCLK2 period
set LMS1_MCLK1_period  		6.25
set LMS1_MCLK2_period		6.25
	#Setup and hold times from datasheet
set LMS1_LMS7_Tsu				1.0
set LMS1_LMS7_Th				0.2

#Tsu and Th based delays
set LMS7_IN_MAX_DELAY [expr -$LMS1_LMS7_Tsu]
set LMS7_IN_MIN_DELAY [expr $LMS1_LMS7_Th - $LMS1_MCLK2_period/2]

#Tco based
#set LMS7_IN_MAX_DELAY [expr $LMS7_Tco_max]
#set LMS7_IN_MIN_DELAY [expr $LMS7_Tco_min]

################################################################################
#Base clocks
################################################################################

create_clock -period $LMS1_MCLK1_period 			-name LMS1_MCLK1			[get_ports LMS1_MCLK1] 

create_clock -period $LMS1_MCLK2_period 			-name LMS1_MCLK2 			[get_ports LMS1_MCLK2]

################################################################################
#Virtual clocks
################################################################################
create_clock -name LMS1_MCLK2_VIRT		-period $LMS1_MCLK2_period

################################################################################
#Generated clocks
################################################################################
#LMS1 TXPLL
create_generated_clock -name LMS1_TXPLL_VCO \
-source [get_pins {inst67|tx_pll_inst|altera_pll_i|cyclonev_pll|fpll_0|fpll|refclkin}] \
-divide_by 2 -multiply_by 4 \
[get_pins {inst67|tx_pll_inst|altera_pll_i|cyclonev_pll|fpll_0|fpll|vcoph[0]}]

create_generated_clock -name LMS1_TXPLL_C0 \
-source [get_pins {inst67|tx_pll_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|vco0ph[0]}] \
-divide_by 2 -multiply_by 1 \
[get_pins {inst67|tx_pll_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}]

create_generated_clock -name LMS1_TXPLL_C1 \
-source [get_pins {inst67|tx_pll_inst|altera_pll_i|cyclonev_pll|counter[1].output_counter|vco0ph[0]}] \
-divide_by 2 -multiply_by 1 -phase 90 \
[get_pins {inst67|tx_pll_inst|altera_pll_i|cyclonev_pll|counter[1].output_counter|divclk}]

#LMS1_FCLK1 clock output pin 
create_generated_clock -name LMS1_FCLK1 \
								-source [get_pins {inst67|tx_pll_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] \
								[get_ports LMS1_FCLK1]

#LMS1 RXPLL
create_generated_clock -name LMS1_RXPLL_VCO \
-source [get_pins {inst|rx_pll_inst|altera_pll_i|cyclonev_pll|fpll_0|fpll|refclkin}] \
-divide_by 2 -multiply_by 4 \
[get_pins {inst|rx_pll_inst|altera_pll_i|cyclonev_pll|fpll_0|fpll|vcoph[0]}]

create_generated_clock -name LMS1_RXPLL_C0 \
-source [get_pins {inst|rx_pll_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|vco0ph[0]}] \
-divide_by 2 -multiply_by 1 \
[get_pins {inst|rx_pll_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}]

create_generated_clock -name LMS1_RXPLL_C1 \
-source [get_pins {inst|rx_pll_inst|altera_pll_i|cyclonev_pll|counter[1].output_counter|vco0ph[0]}] \
-divide_by 2 -multiply_by 1 -phase 90 \
[get_pins {inst|rx_pll_inst|altera_pll_i|cyclonev_pll|counter[1].output_counter|divclk}]

#LMS1_FCLK2 clock output pin 
create_generated_clock -name LMS1_FCLK2 \
								-source [get_pins {inst|rx_pll_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}] \
								[get_ports LMS1_FCLK2]
								
################################################################################
#Input constraints
################################################################################
#LMS1
set_input_delay	-max $LMS7_IN_MAX_DELAY \
						-clock [get_clocks LMS1_MCLK2_VIRT] [get_ports {LMS1_DIQ2_D[*] LMS1_ENABLE_IQSEL2}]
						
set_input_delay	-min $LMS7_IN_MIN_DELAY \
						-clock [get_clocks LMS1_MCLK2_VIRT] [get_ports {LMS1_DIQ2_D[*] LMS1_ENABLE_IQSEL2}]
						
set_input_delay	-max $LMS7_IN_MAX_DELAY \
						-clock [get_clocks LMS1_MCLK2_VIRT] \
						-clock_fall [get_ports {LMS1_DIQ2_D[*] LMS1_ENABLE_IQSEL2}] -add_delay
												
set_input_delay	-min $LMS7_IN_MIN_DELAY \
						-clock [get_clocks LMS1_MCLK2_VIRT] \
						-clock_fall [get_ports {LMS1_DIQ2_D[*] LMS1_ENABLE_IQSEL2}] -add_delay
						
################################################################################
#Output constraints
################################################################################
#LMS1						
set_output_delay	-max $LMS1_LMS7_Tsu \
						-clock [get_clocks LMS1_FCLK1] [get_ports {LMS1_DIQ1_D[*] LMS1_ENABLE_IQSEL1}]
						
set_output_delay	-min -$LMS1_LMS7_Th \
						-clock [get_clocks LMS1_FCLK1] [get_ports {LMS1_DIQ1_D[*] LMS1_ENABLE_IQSEL1}]						
						
set_output_delay	-max $LMS1_LMS7_Tsu \
						-clock [get_clocks LMS1_FCLK1] \
						-clock_fall [get_ports {LMS1_DIQ1_D[*] LMS1_ENABLE_IQSEL1}] -add_delay
											
set_output_delay	-min -$LMS1_LMS7_Th \
						-clock [get_clocks LMS1_FCLK1] \
						-clock_fall [get_ports {LMS1_DIQ1_D[*] LMS1_ENABLE_IQSEL1}] -add_delay	
	
################################################################################
#Exceptions
################################################################################	
################################################################################
#Exceptions
################################################################################
#Cut path between rising to falling and falling to rising edges
set_false_path -setup -rise_from [get_clocks LMS1_MCLK2_VIRT] -fall_to \
[get_clocks LMS1_RXPLL_C1]

set_false_path -setup -fall_from [get_clocks LMS1_MCLK2_VIRT] -rise_to \
[get_clocks LMS1_RXPLL_C1]

set_false_path -hold -rise_from [get_clocks LMS1_MCLK2_VIRT] -rise_to \
[get_clocks LMS1_RXPLL_C1]

set_false_path -hold -fall_from [get_clocks LMS1_MCLK2_VIRT] -fall_to \
[get_clocks LMS1_RXPLL_C1]

#Clock groups					
#Clock groups are set in top .sdc file
											
#False Path between PLL output and clock output ports LMS2_FCLK1 an LMS2_FCLK2
set_false_path -to [get_ports LMS1_FCLK*]	

