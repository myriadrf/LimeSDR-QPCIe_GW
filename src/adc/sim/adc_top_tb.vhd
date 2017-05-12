-- ----------------------------------------------------------------------------	
-- FILE: 	adc_top_tb.vhd
-- DESCRIPTION:	
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity adc_top_tb is
end adc_top_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of adc_top_tb is
   constant clk0_period    : time := 10 ns;
   constant clk1_period    : time := 10 ns; 
   --signals
   signal clk0,clk1        : std_logic;
   signal reset_n          : std_logic;
   
   signal data_cnt         : unsigned(13 downto 0);
   signal data_cnt_vect    : std_logic_vector(13 downto 0);
   signal adc_data_even    : std_logic_vector(6 downto 0);
   signal adc_data_odd     : std_logic_vector(6 downto 0);

   signal adc_data_ddr     : std_logic_vector(6 downto 0);
   
   

   
   
begin 
  
      clock0: process is
   begin
      clk0 <= '0'; wait for clk0_period/2;
      clk0 <= '1'; wait for clk0_period/2;
   end process clock0;

      clock: process is
   begin
      clk1 <= '1' after clk1_period/4; wait for clk1_period/2;
      clk1 <= '0' after clk1_period/4; wait for clk1_period/2;
   end process clock;
   
      res: process is
   begin
      reset_n <= '0'; wait for 20 ns;
      reset_n <= '1'; wait;
   end process res;
   
   
process(clk0, reset_n)
   begin
      if reset_n = '0' then 
         data_cnt <= (others=>'0');
      elsif (clk0'event AND clk0='0') then 
         data_cnt <= data_cnt+1;
      end if;
   end process;
   
   
   data_cnt_vect <= std_logic_vector(data_cnt);
   
   --even bits
   adc_data_even <=  data_cnt_vect(12) & 
                  data_cnt_vect(10) & 
                  data_cnt_vect(8) &
                  data_cnt_vect(6) &
                  data_cnt_vect(4) &
                  data_cnt_vect(2) &
                  data_cnt_vect(0);
   --odd bits               
   adc_data_odd <=  data_cnt_vect(13) & 
                  data_cnt_vect(11) & 
                  data_cnt_vect(9) &
                  data_cnt_vect(7) &
                  data_cnt_vect(5) &
                  data_cnt_vect(3) &
                  data_cnt_vect(1);
                  
   adc_data_ddr <= adc_data_odd when clk0 = '1' else adc_data_even;
   
   
   
   adc_top_inst0 : entity work.adc_top
   generic map( 
      dev_family           => "Cyclone V",
      data_width           =>  7,
      smpls_to_capture     =>  4
      )
   port map(

      clk               => clk1,
      reset_n           => reset_n,
      ch_a              => adc_data_ddr,
      ch_b              => adc_data_ddr,

      data_ch_a         => open,
      data_ch_b         => open,

      data_ch_ab        => open,
      data_ch_ab_valid  => open

        );

   
   
   
   

   end tb_behave;
  
  


  
