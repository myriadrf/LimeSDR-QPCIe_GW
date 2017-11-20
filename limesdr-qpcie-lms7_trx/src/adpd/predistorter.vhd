-- ----------------------------------------------------------------------------	
-- FILE: 	predistorter.vhd
-- DESCRIPTION:	describe
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
entity predistorter is
	generic(sampl_width : integer := 12
	);
  port (
        --input ports 
        clk       	: in std_logic;
        reset_n   	: in std_logic;
		  xp_valid		: in std_logic;
        xpi       	: in std_logic_vector(sampl_width-1 downto 0);
        xpq       	: in std_logic_vector(sampl_width-1 downto 0);
        ypi       	: out std_logic_vector(sampl_width-1 downto 0);
        ypq       	: out std_logic_vector(sampl_width-1 downto 0);
		  yp_valid		: out std_logic;
        spi_ctrl  	: in std_logic_vector(15 downto 0)

        --output ports 
        
        );
end predistorter;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of predistorter is
--declare signals,  components here
signal ypi_s, ypq_s	: std_logic_vector(sampl_width-1 downto 0);
signal yp_valid_s 	: std_logic; 

  
begin

--ypi, ypq and yp_valid signals are delayed versions of xpi, xpq and xp_valid signals. 
--LSb are zeroed to see some difference in ypi, ypq signals 

  process(reset_n, clk)
    begin
      if reset_n='0' then
			ypi_s			<=(others=>'0');
			ypq_s			<=(others=>'0');
			yp_valid_s	<='0';
 	    elsif (clk'event and clk = '1') then
			if xp_valid='1' then 
				ypi_s<= xpi(sampl_width-1 downto 0);
				ypq_s<= xpq(sampl_width-1 downto 0);
			else 
				ypi_s<=ypi_s;
				ypq_s<=ypq_s;
			end if;
			yp_valid_s<=xp_valid;
 	    end if;
    end process;
	
	
	ypi<=ypi_s;
	ypq<=ypq_s;
	yp_valid<=yp_valid_s;	
	 
  
end arch;   




