-- ----------------------------------------------------------------------------	
-- FILE: 	lms7_trx_pcie_top.vhd
-- DESCRIPTION:	TOP module
-- DATE:	May 24, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity lms7_trx_pcie_top is
   port (
      --global reset signal
      global_reset   : in std_logic; --connect to pin tied to GND
      
      --Switches, LED,      
      FPGA_SW        : in std_logic_vector(3 downto 0);
      FPGA_LED       : out std_logic_vector(3 downto 0);
      
      --Temp sensor
      LM75_OS        : in std_logic;
      
      --Fan control
      FAN_CTRL       : out std_logic;
      
      --PMOD_A
      PMOD_A_PIN1    : inout : std_logic;
      PMOD_A_PIN2    : inout : std_logic;
      PMOD_A_PIN3    : inout : std_logic;
      PMOD_A_PIN4    : inout : std_logic;
      PMOD_A_PIN7    : inout : std_logic;
      PMOD_A_PIN8    : inout : std_logic;
      PMOD_A_PIN9    : inout : std_logic;
      
      --PMOD_B
      PMOD_B_PIN1    : inout : std_logic;
      PMOD_B_PIN2    : inout : std_logic;
      PMOD_B_PIN3    : inout : std_logic;
      PMOD_B_PIN4    : inout : std_logic;
      PMOD_B_PIN7    : inout : std_logic;
      PMOD_B_PIN8    : inout : std_logic;
      PMOD_B_PIN9    : inout : std_logic;
      
      --LMS7#1
      LMS1_MCLK1           : in std_logic;
      LMS1_FCLK1           : out std_logic;
      LMS1_DIQ1_D          : out std_logic_vector(11 downto 0);
      LMS1_ENABLE_IQSEL1   : out std_logic;
      
      LMS1_MCLK2           : in std_logic;
      LMS1_FCLK2           : out std_logic;
      LMS1_DIQ2_D          : in std_logic_vector(11 downto 0);
      LMS1_ENABLE_IQSEL2   : in std_logic;
      
      LMS1_RESET           : out std_logic;
      LMS1_RXEN            : out std_logic;
      LMS1_TXEN            : out std_logic;
      LMS1_TXNRX1          : out std_logic;
      LMS1_TXNRX2          : out std_logic;
      LMS1_CORE_LDO_EN     : out std_logic;
      
      --LMS7#2
      LMS2_MCLK1           : in std_logic;
      LMS2_FCLK1           : out std_logic;
      LMS2_DIQ1_D          : out std_logic_vector(11 downto 0);
      LMS2_ENABLE_IQSEL1   : out std_logic;
      
      LMS2_MCLK2           : in std_logic;
      LMS2_FCLK2           : out std_logic;
      LMS2_DIQ2_D          : in std_logic_vector(11 downto 0);
      LMS2_ENABLE_IQSEL2   : in std_logic;
      
      LMS2_RESET           : out std_logic;
      LMS2_RXEN            : out std_logic;
      LMS2_TXEN            : out std_logic;
      LMS2_TXNRX1          : out std_logic;
      LMS2_TXNRX2          : out std_logic;
      LMS2_CORE_LDO_EN     : out std_logic;

      --ADC
      ADC_CLK              : out std_logic;
      ADC_CLKOUT           : in std_logic;
      FPGA_ADC_RESET       : out std_logic;
      ADC_DA               : in std_logic_vector(6 downto 0);
      ADC_DB               : in std_logic_vector(6 downto 0);
      
      --DAC
      DAC_CLK_WRT          : out std_logic;
      DAC1_MODE            : out std_logic;
      DAC1_SLEEP           : out std_logic;
      DAC1_DA              : out std_logic_vector(13 downto 0);
      DAC1_DB              : out std_logic_vector(13 downto 0);
      
      DAC2_MODE            : out std_logic;
      DAC2_SLEEP           : out std_logic;
      DAC2_DA              : out std_logic_vector(13 downto 0);
      DAC2_DB              : out std_logic_vector(13 downto 0);
      



      




        );
end lms7_trx_pcie_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of lms7_trx_pcie_top is
--declare signals,  components here
signal my_sig_name : std_logic_vector (7 downto 0); 

  
begin


 process(reset_n, clk)
    begin
      if reset_n='0' then
        --reset  
      elsif (clk'event and clk = '1') then
 	      --in process
 	    end if;
    end process;
  
end arch;   





