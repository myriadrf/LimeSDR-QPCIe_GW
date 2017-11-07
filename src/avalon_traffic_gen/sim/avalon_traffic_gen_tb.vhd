-- ----------------------------------------------------------------------------
-- FILE:          avalon_traffic_gen_avl_use_be_avl_use_burstbegin_tb.vhd
-- DESCRIPTION:   
-- DATE:          Feb 13, 2014
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity avalon_traffic_gen_tb is
end avalon_traffic_gen_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of avalon_traffic_gen_tb is
   constant clk0_period    : time := 10 ns;
   constant clk1_period    : time := 10 ns; 
   --signals
   signal clk0,clk1        : std_logic;
   signal reset_n          : std_logic; 
   signal avl_addr         : std_logic_vector(25 downto 0);
   signal avl_size         : std_logic_vector(1 downto 0);
   signal avl_wdata        : std_logic_vector(63 downto 0);
   signal avl_be           : std_logic_vector(3 downto 0);
   signal avl_ready        : std_logic;
   
   signal write_addr       : std_logic_vector(25 downto 0);
   signal write_burstcount : std_logic_vector(1 downto 0) := "10";
   signal wdata            : std_logic_vector(63 downto 0) :=(others=>'0');
   signal be               : std_logic_vector(3 downto 0);
   signal read_addr        : std_logic_vector(25 downto 0);
   signal read_burstcount  : std_logic_vector(1 downto 0);

   
   
   
   
COMPONENT avalon_traffic_gen
	GENERIC ( 
      DEVICE_FAMILY        : STRING; 
      ADDR_WIDTH           : integer; 
      BURSTCOUNT_WIDTH     : integer; 
      DATA_WIDTH           : integer;
      BE_WIDTH             : integer; 
      BUFFER_SIZE          : integer; 
      RANDOM_BYTE_ENABLE   : integer 
      );
	PORT
	(
		clk                  :	 IN STD_LOGIC;
		reset_n              :	 IN STD_LOGIC;
		avl_ready            :	 IN STD_LOGIC;
		avl_write_req        :	 OUT STD_LOGIC;
		avl_read_req         :	 OUT STD_LOGIC;
		avl_burstbegin       :	 OUT STD_LOGIC;
		avl_addr             :	 OUT STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
		avl_size             :	 OUT STD_LOGIC_VECTOR(BURSTCOUNT_WIDTH-1 DOWNTO 0);
		avl_wdata            :	 OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		avl_be               :	 OUT STD_LOGIC_VECTOR(BE_WIDTH-1 DOWNTO 0);
		do_write             :	 IN STD_LOGIC;
		do_read              :	 IN STD_LOGIC;
		write_addr           :	 IN STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
		write_burstcount     :	 IN STD_LOGIC_VECTOR(BURSTCOUNT_WIDTH-1 DOWNTO 0);
		wdata                :	 IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		be                   :	 IN STD_LOGIC_VECTOR(BE_WIDTH-1 DOWNTO 0);
		read_addr            :	 IN STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
		read_burstcount      :	 IN STD_LOGIC_VECTOR(BURSTCOUNT_WIDTH-1 DOWNTO 0);
		ready                :	 OUT STD_LOGIC;
		wdata_req            :	 OUT STD_LOGIC
	);
END COMPONENT;
  
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
      avl_ready <= '0'; wait until rising_edge(clk0);
      for i in 0 to 2 loop
         avl_ready <= '1';
         wait until rising_edge(clk0);
      end loop;
   end process;
   
   
   
      -- design under test  
      
      dut0 : avalon_traffic_gen
      generic map(
         DEVICE_FAMILY        => "Cyclone V GX",
         ADDR_WIDTH           => 26,
         BURSTCOUNT_WIDTH	   => 2,
         DATA_WIDTH		      => 64,
         BE_WIDTH			      => 4,
         BUFFER_SIZE		      => 64,
         RANDOM_BYTE_ENABLE   => 0        
         )
      port map(
         clk                  => clk0,
         reset_n              => reset_n,
         avl_ready            => avl_ready,
         avl_write_req        => open,
         avl_read_req         => open,
         avl_burstbegin       => open,
         avl_addr             => avl_addr,
         avl_size             => avl_size,
         avl_wdata            => avl_wdata,
         avl_be               => avl_be,
         do_write             => '1',
         do_read              => '0',
         write_addr           => write_addr,
         write_burstcount     => write_burstcount,
         wdata                => wdata,
         be                   => be,
         read_addr            => read_addr,
         read_burstcount      => read_burstcount,
         ready                => open,
         wdata_req            => open        
         );
      

end tb_behave;

