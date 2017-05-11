
-- ----------------------------------------------------------------------------	
-- FILE: 	bit_pack.vhd
-- DESCRIPTION:	packs data from 12 or 14 bit samples to 16 bit data
-- DATE:	Nov 15, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity comprlaration
-- ----------------------------------------------------------------------------
entity bit_pack is

  port (
        --input ports 
        clk             	: in std_logic;
        reset_n         	: in std_logic;
        data48_in         	: in std_logic_vector(47 downto 0);
        data48_in_valid   	: in std_logic;
		  data56_in         	: in std_logic_vector(55 downto 0);
        data56_in_valid   	: in std_logic;
		  data64_in         	: in std_logic_vector(63 downto 0);
        data64_in_valid   	: in std_logic;
        sample_width    	: in std_logic_vector(1 downto 0); --"10"-12bit, "01"-14bit, "00"-16bit;
        --output ports 
        data_out        	: out std_logic_vector(63 downto 0);
        data_out_valid  	: out std_logic       
        );
end bit_pack;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of bit_pack is
--Declare signals,  components here

--inst0 signals
signal inst0_data64_out			: std_logic_vector(63 downto 0);
signal inst0_data_out_valid	: std_logic;

--inst1 signals
signal inst1_data64_out			: std_logic_vector(63 downto 0);
signal inst1_data_out_valid	: std_logic;

signal data_out_mux				: std_logic_vector(63 downto 0);
signal data_out_valid_mux		: std_logic;

signal data_out_reg				: std_logic_vector(63 downto 0);
signal data_out_valid_reg		: std_logic;


component pack_48_to_64 is
  port (
      --input ports 
      clk       		: in std_logic;
      reset_n   		: in std_logic;
		data_in_wrreq	: in std_logic;
		data48_in		: in std_logic_vector(47 downto 0);
		data64_out		: out std_logic_vector(63 downto 0);
		data_out_valid	: out std_logic       
        );
end component;


component pack_56_to_64 is
  port (
      --input ports 
      clk       		: in std_logic;
      reset_n   		: in std_logic;
		data_in_wrreq	: in std_logic;
		data56_in		: in std_logic_vector(55 downto 0);
		data64_out		: out std_logic_vector(63 downto 0);
		data_out_valid	: out std_logic       
        );
end component;
  
begin

inst0 : pack_48_to_64 
port map (
	   clk       		=> clk,
      reset_n   		=> reset_n,
		data_in_wrreq	=> data48_in_valid,
		data48_in		=> data48_in,
		data64_out		=> inst0_data64_out,
		data_out_valid	=> inst0_data_out_valid
);

inst1 : pack_56_to_64 
port map (
	   clk       		=> clk,
      reset_n   		=> reset_n,
		data_in_wrreq	=> data56_in_valid,
		data56_in		=> data56_in,
		data64_out		=> inst1_data64_out,
		data_out_valid	=> inst1_data_out_valid
);

data_out_mux <=inst0_data64_out when sample_width="10" else 
				inst1_data64_out when sample_width="01" else 
				data64_in;

data_out_valid_mux <=	inst0_data_out_valid when sample_width="10" else 
				inst1_data_out_valid when sample_width="01" else 
				data64_in_valid;
				
process(reset_n, clk) is
begin 
	if reset_n='0' then 
		data_out_reg<=(others=>'0');
		data_out_valid_reg<='0';
	elsif (clk'event and clk='1') then 
		data_out_reg<=data_out_mux;
		data_out_valid_reg<=data_out_valid_mux;
	end if;
end process;

data_out<=data_out_reg;
data_out_valid<=data_out_valid_reg;


end arch;   



