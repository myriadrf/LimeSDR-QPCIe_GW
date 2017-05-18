-- ----------------------------------------------------------------------------	
-- FILE: 	fifo_bulk_read_tb.vhd
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
entity fifo_bulk_read_tb is
end fifo_bulk_read_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of fifo_bulk_read_tb is
   constant clk0_period   : time := 10 ns;
   constant clk1_period   : time := 10 ns; 
   --signals
	signal clk0,clk1		: std_logic;
	signal reset_n       : std_logic; 
   
   --dut0
   signal dut0_wrreq    : std_logic;
   signal dut0_data     : std_logic_vector(15 downto 0);
   signal dut0_rdusedw  : std_logic_vector(11 downto 0);
   
   --dut1
   signal dut1_rdreq    : std_logic;
   signal dut1_bulk_size: std_logic_vector(15 downto 0) := x"000F";
   signal dut1_bulk_rdy : std_logic;
   
   
begin 
  
      clock0: process is
	begin
		clk0 <= '0'; wait for clk0_period/2;
		clk0 <= '1'; wait for clk0_period/2;
	end process clock0;

   	clock: process is
	begin
		clk1 <= '0'; wait for clk1_period/2;
		clk1 <= '1'; wait for clk1_period/2;
	end process clock;
	
		res: process is
	begin
		reset_n <= '0'; wait for 20 ns;
		reset_n <= '1'; wait;
	end process res;
   
   
   process is
	begin
		dut1_bulk_rdy <= '0'; wait for 2000 ns;
		dut1_bulk_rdy <= '1'; wait for 5000 ns;
	end process;
   
     
   process(clk0, reset_n)
   begin
      if reset_n = '0' then 
         dut0_wrreq <= '0';
         dut0_data <= (others=>'0');
      elsif (clk0'event AND clk0='1') then 
         dut0_wrreq <= '1';
         if dut0_wrreq = '1' then 
            dut0_data <= std_logic_vector(unsigned(dut0_data)+1);
         else 
            dut0_data <= dut0_data;
         end if;
      end if;
   end process;
   
   
   
   
 
fifo_inst_dut0 : entity work.fifo_inst
  generic map(
         dev_family	    => "Cyclone IV E",
         wrwidth         => 16,
         wrusedw_witdth  => 13, --12=2048 words 
         rdwidth         => 32,
         rdusedw_width   => 12,
         show_ahead      => "OFF"
  ) 
  port map(
      --input ports 
      reset_n       => reset_n,
      wrclk         => clk0,
      wrreq         => dut0_wrreq,
      data          => dut0_data,
      wrfull        => open,
		wrempty		  => open,
      wrusedw       => open,
      rdclk 	     => clk0,
      rdreq         => dut1_rdreq,
      q             => open,
      rdempty       => open,
      rdusedw       => dut0_rdusedw          
        );
        
        
fifo_bulk_read_inst1 : entity work.fifo_bulk_read
   generic map(
      fifo_rd_size   => 12
   )
   port map(

      clk            => clk0,
      reset_n        => reset_n,
      bulk_size      => dut1_bulk_size,
      bulk_buff_rdy  => dut1_bulk_rdy,
      fifo_rdusedw   => dut0_rdusedw,
      fifo_rdreq     => dut1_rdreq

        );
        
        


	end tb_behave;
  
  


  
