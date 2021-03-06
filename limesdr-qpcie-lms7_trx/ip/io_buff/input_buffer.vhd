-- megafunction wizard: %ALTIOBUF%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: altiobuf_in 

-- ============================================================
-- File Name: input_buffer.vhd
-- Megafunction Name(s):
-- 			altiobuf_in
--
-- Simulation Library Files(s):
-- 			
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 16.1.1 Build 200 11/30/2016 SJ Lite Edition
-- ************************************************************


--Copyright (C) 2016  Intel Corporation. All rights reserved.
--Your use of Intel Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Intel Program License 
--Subscription Agreement, the Intel Quartus Prime License Agreement,
--the Intel MegaCore Function License Agreement, or other 
--applicable license agreement, including, without limitation, 
--that your use is for the sole purpose of programming logic 
--devices manufactured by Intel and sold by Intel or its 
--authorized distributors.  Please refer to the applicable 
--agreement for further details.


--altiobuf_in CBX_AUTO_BLACKBOX="ALL" DEVICE_FAMILY="Cyclone V" ENABLE_BUS_HOLD="FALSE" NUMBER_OF_CHANNELS=13 USE_DIFFERENTIAL_MODE="FALSE" USE_DYNAMIC_TERMINATION_CONTROL="FALSE" datain dataout
--VERSION_BEGIN 16.1 cbx_altiobuf_in 2016:11:30:18:10:07:SJ cbx_mgl 2016:11:30:18:11:28:SJ cbx_stratixiii 2016:11:30:18:10:07:SJ cbx_stratixv 2016:11:30:18:10:07:SJ  VERSION_END

 LIBRARY cyclonev;
 USE cyclonev.all;

--synthesis_resources = cyclonev_io_ibuf 13 
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;

 ENTITY  input_buffer_iobuf_in_i2i IS 
	 PORT 
	 ( 
		 datain	:	IN  STD_LOGIC_VECTOR (12 DOWNTO 0);
		 dataout	:	OUT  STD_LOGIC_VECTOR (12 DOWNTO 0)
	 ); 
 END input_buffer_iobuf_in_i2i;

 ARCHITECTURE RTL OF input_buffer_iobuf_in_i2i IS

	 SIGNAL  wire_ibufa_i	:	STD_LOGIC_VECTOR (12 DOWNTO 0);
	 SIGNAL  wire_ibufa_o	:	STD_LOGIC_VECTOR (12 DOWNTO 0);
	 COMPONENT  cyclonev_io_ibuf
	 GENERIC 
	 (
		bus_hold	:	STRING := "false";
		differential_mode	:	STRING := "false";
		simulate_z_as	:	STRING := "z";
		lpm_type	:	STRING := "cyclonev_io_ibuf"
	 );
	 PORT
	 ( 
		dynamicterminationcontrol	:	IN STD_LOGIC := '0';
		i	:	IN STD_LOGIC := '0';
		ibar	:	IN STD_LOGIC := '0';
		o	:	OUT STD_LOGIC
	 ); 
	 END COMPONENT;
 BEGIN

	dataout <= wire_ibufa_o;
	wire_ibufa_i <= datain;
	loop0 : FOR i IN 0 TO 12 GENERATE 
	  ibufa :  cyclonev_io_ibuf
	  GENERIC MAP (
		bus_hold => "false",
		differential_mode => "false"
	  )
	  PORT MAP ( 
		i => wire_ibufa_i(i),
		o => wire_ibufa_o(i)
	  );
	END GENERATE loop0;

 END RTL; --input_buffer_iobuf_in_i2i
--VALID FILE


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY input_buffer IS
	PORT
	(
		datain		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
		dataout		: OUT STD_LOGIC_VECTOR (12 DOWNTO 0)
	);
END input_buffer;


ARCHITECTURE RTL OF input_buffer IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (12 DOWNTO 0);



	COMPONENT input_buffer_iobuf_in_i2i
	PORT (
			datain	: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
			dataout	: OUT STD_LOGIC_VECTOR (12 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	dataout    <= sub_wire0(12 DOWNTO 0);

	input_buffer_iobuf_in_i2i_component : input_buffer_iobuf_in_i2i
	PORT MAP (
		datain => datain,
		dataout => sub_wire0
	);



END RTL;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone V"
-- Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Cyclone V"
-- Retrieval info: CONSTANT: enable_bus_hold STRING "FALSE"
-- Retrieval info: CONSTANT: number_of_channels NUMERIC "13"
-- Retrieval info: CONSTANT: use_differential_mode STRING "FALSE"
-- Retrieval info: CONSTANT: use_dynamic_termination_control STRING "FALSE"
-- Retrieval info: USED_PORT: datain 0 0 13 0 INPUT NODEFVAL "datain[12..0]"
-- Retrieval info: USED_PORT: dataout 0 0 13 0 OUTPUT NODEFVAL "dataout[12..0]"
-- Retrieval info: CONNECT: @datain 0 0 13 0 datain 0 0 13 0
-- Retrieval info: CONNECT: dataout 0 0 13 0 @dataout 0 0 13 0
-- Retrieval info: GEN_FILE: TYPE_NORMAL input_buffer.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL input_buffer.inc FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL input_buffer.cmp TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL input_buffer.bsf TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL input_buffer_inst.vhd FALSE
