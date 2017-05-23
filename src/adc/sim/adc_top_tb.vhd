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
   
   signal data_cnt_ch_a       : unsigned(13 downto 0);
   signal data_cnt_vect_ch_a  : std_logic_vector(13 downto 0);
   signal adc_data_even_ch_a  : std_logic_vector(6 downto 0);
   signal adc_data_odd_ch_a   : std_logic_vector(6 downto 0);

   signal adc_data_ddr_ch_a   : std_logic_vector(6 downto 0);
   
   
   signal data_cnt_ch_b       : unsigned(13 downto 0);
   signal data_cnt_vect_ch_b  : std_logic_vector(13 downto 0);
   signal adc_data_even_ch_b  : std_logic_vector(6 downto 0);
   signal adc_data_odd_ch_b   : std_logic_vector(6 downto 0);

   signal adc_data_ddr_ch_b   : std_logic_vector(6 downto 0);
   
   

   
   
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
         data_cnt_ch_a <= (others=>'0');
      elsif (clk0'event AND clk0='0') then 
         data_cnt_ch_a <= data_cnt_ch_a+2;
      end if;
   end process;
   
   
   data_cnt_vect_ch_a <= std_logic_vector(data_cnt_ch_a);
   
   --even bits
   adc_data_even_ch_a <=   data_cnt_vect_ch_a(12) & 
                           data_cnt_vect_ch_a(10) & 
                           data_cnt_vect_ch_a(8) &
                           data_cnt_vect_ch_a(6) &
                           data_cnt_vect_ch_a(4) &
                           data_cnt_vect_ch_a(2) &
                           data_cnt_vect_ch_a(0);
   --odd bits               
   adc_data_odd_ch_a <=    data_cnt_vect_ch_a(13) & 
                           data_cnt_vect_ch_a(11) & 
                           data_cnt_vect_ch_a(9) &
                           data_cnt_vect_ch_a(7) &
                           data_cnt_vect_ch_a(5) &
                           data_cnt_vect_ch_a(3) &
                           data_cnt_vect_ch_a(1);
                  
   adc_data_ddr_ch_a <= adc_data_odd_ch_a when clk0 = '1' else adc_data_even_ch_a;
   
   
   
   process(clk0, reset_n)
   begin
      if reset_n = '0' then 
         data_cnt_ch_b <= "00000000000001";
      elsif (clk0'event AND clk0='0') then 
         data_cnt_ch_b <= data_cnt_ch_b+2;
      end if;
   end process;
   
   
   data_cnt_vect_ch_b <= std_logic_vector(data_cnt_ch_b);
   
   --even bits
   adc_data_even_ch_b <=   data_cnt_vect_ch_b(12) & 
                           data_cnt_vect_ch_b(10) & 
                           data_cnt_vect_ch_b(8) &
                           data_cnt_vect_ch_b(6) &
                           data_cnt_vect_ch_b(4) &
                           data_cnt_vect_ch_b(2) &
                           data_cnt_vect_ch_b(0);
   --odd bits               
   adc_data_odd_ch_b <=    data_cnt_vect_ch_b(13) & 
                           data_cnt_vect_ch_b(11) & 
                           data_cnt_vect_ch_b(9) &
                           data_cnt_vect_ch_b(7) &
                           data_cnt_vect_ch_b(5) &
                           data_cnt_vect_ch_b(3) &
                           data_cnt_vect_ch_b(1);
                  
   adc_data_ddr_ch_b <= adc_data_odd_ch_b when clk0 = '1' else adc_data_even_ch_b;
   
   
   
   adc_top_inst0 : entity work.adc_top
   generic map( 
      dev_family           => "Cyclone V",
      data_width           =>  7,
      smpls_to_capture     =>  4
      )
   port map(

      clk               => clk1,
      reset_n           => reset_n,
      en                => '1', 
      ch_a              => adc_data_ddr_ch_a,
      ch_b              => adc_data_ddr_ch_b,

      data_ch_a         => open,
      data_ch_b         => open,

      data_ch_ab        => open,
      data_ch_ab_valid  => open

        );

   
   
   
   

   end tb_behave;
  
  


  
