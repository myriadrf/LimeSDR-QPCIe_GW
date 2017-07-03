	component pcie_reconfig is
		port (
			config_tl_hpg_ctrler             : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- hpg_ctrler
			config_tl_tl_cfg_ctl             : out std_logic_vector(31 downto 0);                    -- tl_cfg_ctl
			config_tl_cpl_err                : in  std_logic_vector(6 downto 0)  := (others => 'X'); -- cpl_err
			config_tl_tl_cfg_add             : out std_logic_vector(3 downto 0);                     -- tl_cfg_add
			config_tl_tl_cfg_ctl_wr          : out std_logic;                                        -- tl_cfg_ctl_wr
			config_tl_tl_cfg_sts_wr          : out std_logic;                                        -- tl_cfg_sts_wr
			config_tl_tl_cfg_sts             : out std_logic_vector(52 downto 0);                    -- tl_cfg_sts
			config_tl_cpl_pending            : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- cpl_pending
			coreclkout_hip_clk               : out std_logic;                                        -- clk
			hip_ctrl_test_in                 : in  std_logic_vector(31 downto 0) := (others => 'X'); -- test_in
			hip_ctrl_simu_mode_pipe          : in  std_logic                     := 'X';             -- simu_mode_pipe
			hip_pipe_sim_pipe_pclk_in        : in  std_logic                     := 'X';             -- sim_pipe_pclk_in
			hip_pipe_sim_pipe_rate           : out std_logic_vector(1 downto 0);                     -- sim_pipe_rate
			hip_pipe_sim_ltssmstate          : out std_logic_vector(4 downto 0);                     -- sim_ltssmstate
			hip_pipe_eidleinfersel0          : out std_logic_vector(2 downto 0);                     -- eidleinfersel0
			hip_pipe_eidleinfersel1          : out std_logic_vector(2 downto 0);                     -- eidleinfersel1
			hip_pipe_eidleinfersel2          : out std_logic_vector(2 downto 0);                     -- eidleinfersel2
			hip_pipe_eidleinfersel3          : out std_logic_vector(2 downto 0);                     -- eidleinfersel3
			hip_pipe_powerdown0              : out std_logic_vector(1 downto 0);                     -- powerdown0
			hip_pipe_powerdown1              : out std_logic_vector(1 downto 0);                     -- powerdown1
			hip_pipe_powerdown2              : out std_logic_vector(1 downto 0);                     -- powerdown2
			hip_pipe_powerdown3              : out std_logic_vector(1 downto 0);                     -- powerdown3
			hip_pipe_rxpolarity0             : out std_logic;                                        -- rxpolarity0
			hip_pipe_rxpolarity1             : out std_logic;                                        -- rxpolarity1
			hip_pipe_rxpolarity2             : out std_logic;                                        -- rxpolarity2
			hip_pipe_rxpolarity3             : out std_logic;                                        -- rxpolarity3
			hip_pipe_txcompl0                : out std_logic;                                        -- txcompl0
			hip_pipe_txcompl1                : out std_logic;                                        -- txcompl1
			hip_pipe_txcompl2                : out std_logic;                                        -- txcompl2
			hip_pipe_txcompl3                : out std_logic;                                        -- txcompl3
			hip_pipe_txdata0                 : out std_logic_vector(7 downto 0);                     -- txdata0
			hip_pipe_txdata1                 : out std_logic_vector(7 downto 0);                     -- txdata1
			hip_pipe_txdata2                 : out std_logic_vector(7 downto 0);                     -- txdata2
			hip_pipe_txdata3                 : out std_logic_vector(7 downto 0);                     -- txdata3
			hip_pipe_txdatak0                : out std_logic;                                        -- txdatak0
			hip_pipe_txdatak1                : out std_logic;                                        -- txdatak1
			hip_pipe_txdatak2                : out std_logic;                                        -- txdatak2
			hip_pipe_txdatak3                : out std_logic;                                        -- txdatak3
			hip_pipe_txdetectrx0             : out std_logic;                                        -- txdetectrx0
			hip_pipe_txdetectrx1             : out std_logic;                                        -- txdetectrx1
			hip_pipe_txdetectrx2             : out std_logic;                                        -- txdetectrx2
			hip_pipe_txdetectrx3             : out std_logic;                                        -- txdetectrx3
			hip_pipe_txelecidle0             : out std_logic;                                        -- txelecidle0
			hip_pipe_txelecidle1             : out std_logic;                                        -- txelecidle1
			hip_pipe_txelecidle2             : out std_logic;                                        -- txelecidle2
			hip_pipe_txelecidle3             : out std_logic;                                        -- txelecidle3
			hip_pipe_txswing0                : out std_logic;                                        -- txswing0
			hip_pipe_txswing1                : out std_logic;                                        -- txswing1
			hip_pipe_txswing2                : out std_logic;                                        -- txswing2
			hip_pipe_txswing3                : out std_logic;                                        -- txswing3
			hip_pipe_txmargin0               : out std_logic_vector(2 downto 0);                     -- txmargin0
			hip_pipe_txmargin1               : out std_logic_vector(2 downto 0);                     -- txmargin1
			hip_pipe_txmargin2               : out std_logic_vector(2 downto 0);                     -- txmargin2
			hip_pipe_txmargin3               : out std_logic_vector(2 downto 0);                     -- txmargin3
			hip_pipe_txdeemph0               : out std_logic;                                        -- txdeemph0
			hip_pipe_txdeemph1               : out std_logic;                                        -- txdeemph1
			hip_pipe_txdeemph2               : out std_logic;                                        -- txdeemph2
			hip_pipe_txdeemph3               : out std_logic;                                        -- txdeemph3
			hip_pipe_phystatus0              : in  std_logic                     := 'X';             -- phystatus0
			hip_pipe_phystatus1              : in  std_logic                     := 'X';             -- phystatus1
			hip_pipe_phystatus2              : in  std_logic                     := 'X';             -- phystatus2
			hip_pipe_phystatus3              : in  std_logic                     := 'X';             -- phystatus3
			hip_pipe_rxdata0                 : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata0
			hip_pipe_rxdata1                 : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata1
			hip_pipe_rxdata2                 : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata2
			hip_pipe_rxdata3                 : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata3
			hip_pipe_rxdatak0                : in  std_logic                     := 'X';             -- rxdatak0
			hip_pipe_rxdatak1                : in  std_logic                     := 'X';             -- rxdatak1
			hip_pipe_rxdatak2                : in  std_logic                     := 'X';             -- rxdatak2
			hip_pipe_rxdatak3                : in  std_logic                     := 'X';             -- rxdatak3
			hip_pipe_rxelecidle0             : in  std_logic                     := 'X';             -- rxelecidle0
			hip_pipe_rxelecidle1             : in  std_logic                     := 'X';             -- rxelecidle1
			hip_pipe_rxelecidle2             : in  std_logic                     := 'X';             -- rxelecidle2
			hip_pipe_rxelecidle3             : in  std_logic                     := 'X';             -- rxelecidle3
			hip_pipe_rxstatus0               : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus0
			hip_pipe_rxstatus1               : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus1
			hip_pipe_rxstatus2               : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus2
			hip_pipe_rxstatus3               : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus3
			hip_pipe_rxvalid0                : in  std_logic                     := 'X';             -- rxvalid0
			hip_pipe_rxvalid1                : in  std_logic                     := 'X';             -- rxvalid1
			hip_pipe_rxvalid2                : in  std_logic                     := 'X';             -- rxvalid2
			hip_pipe_rxvalid3                : in  std_logic                     := 'X';             -- rxvalid3
			hip_rst_reset_status             : out std_logic;                                        -- reset_status
			hip_rst_serdes_pll_locked        : out std_logic;                                        -- serdes_pll_locked
			hip_rst_pld_clk_inuse            : out std_logic;                                        -- pld_clk_inuse
			hip_rst_pld_core_ready           : in  std_logic                     := 'X';             -- pld_core_ready
			hip_rst_testin_zero              : out std_logic;                                        -- testin_zero
			hip_serial_rx_in0                : in  std_logic                     := 'X';             -- rx_in0
			hip_serial_rx_in1                : in  std_logic                     := 'X';             -- rx_in1
			hip_serial_rx_in2                : in  std_logic                     := 'X';             -- rx_in2
			hip_serial_rx_in3                : in  std_logic                     := 'X';             -- rx_in3
			hip_serial_tx_out0               : out std_logic;                                        -- tx_out0
			hip_serial_tx_out1               : out std_logic;                                        -- tx_out1
			hip_serial_tx_out2               : out std_logic;                                        -- tx_out2
			hip_serial_tx_out3               : out std_logic;                                        -- tx_out3
			hip_status_derr_cor_ext_rcv      : out std_logic;                                        -- derr_cor_ext_rcv
			hip_status_derr_cor_ext_rpl      : out std_logic;                                        -- derr_cor_ext_rpl
			hip_status_derr_rpl              : out std_logic;                                        -- derr_rpl
			hip_status_dlup_exit             : out std_logic;                                        -- dlup_exit
			hip_status_ltssmstate            : out std_logic_vector(4 downto 0);                     -- ltssmstate
			hip_status_ev128ns               : out std_logic;                                        -- ev128ns
			hip_status_ev1us                 : out std_logic;                                        -- ev1us
			hip_status_hotrst_exit           : out std_logic;                                        -- hotrst_exit
			hip_status_int_status            : out std_logic_vector(3 downto 0);                     -- int_status
			hip_status_l2_exit               : out std_logic;                                        -- l2_exit
			hip_status_lane_act              : out std_logic_vector(3 downto 0);                     -- lane_act
			hip_status_ko_cpl_spc_header     : out std_logic_vector(7 downto 0);                     -- ko_cpl_spc_header
			hip_status_ko_cpl_spc_data       : out std_logic_vector(11 downto 0);                    -- ko_cpl_spc_data
			hip_status_drv_derr_cor_ext_rcv  : in  std_logic                     := 'X';             -- derr_cor_ext_rcv
			hip_status_drv_derr_cor_ext_rpl  : in  std_logic                     := 'X';             -- derr_cor_ext_rpl
			hip_status_drv_derr_rpl          : in  std_logic                     := 'X';             -- derr_rpl
			hip_status_drv_dlup_exit         : in  std_logic                     := 'X';             -- dlup_exit
			hip_status_drv_ev128ns           : in  std_logic                     := 'X';             -- ev128ns
			hip_status_drv_ev1us             : in  std_logic                     := 'X';             -- ev1us
			hip_status_drv_hotrst_exit       : in  std_logic                     := 'X';             -- hotrst_exit
			hip_status_drv_int_status        : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- int_status
			hip_status_drv_l2_exit           : in  std_logic                     := 'X';             -- l2_exit
			hip_status_drv_lane_act          : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- lane_act
			hip_status_drv_ltssmstate        : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- ltssmstate
			hip_status_drv_ko_cpl_spc_header : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- ko_cpl_spc_header
			hip_status_drv_ko_cpl_spc_data   : in  std_logic_vector(11 downto 0) := (others => 'X'); -- ko_cpl_spc_data
			int_msi_app_msi_num              : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- app_msi_num
			int_msi_app_msi_req              : in  std_logic                     := 'X';             -- app_msi_req
			int_msi_app_msi_tc               : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- app_msi_tc
			int_msi_app_msi_ack              : out std_logic;                                        -- app_msi_ack
			int_msi_app_int_sts              : in  std_logic                     := 'X';             -- app_int_sts
			lmi_lmi_addr                     : in  std_logic_vector(11 downto 0) := (others => 'X'); -- lmi_addr
			lmi_lmi_din                      : in  std_logic_vector(31 downto 0) := (others => 'X'); -- lmi_din
			lmi_lmi_rden                     : in  std_logic                     := 'X';             -- lmi_rden
			lmi_lmi_wren                     : in  std_logic                     := 'X';             -- lmi_wren
			lmi_lmi_ack                      : out std_logic;                                        -- lmi_ack
			lmi_lmi_dout                     : out std_logic_vector(31 downto 0);                    -- lmi_dout
			npor_npor                        : in  std_logic                     := 'X';             -- npor
			npor_pin_perst                   : in  std_logic                     := 'X';             -- pin_perst
			pld_clk_clk                      : in  std_logic                     := 'X';             -- clk
			pld_clk_1_clk                    : in  std_logic                     := 'X';             -- clk
			power_mngt_pm_auxpwr             : in  std_logic                     := 'X';             -- pm_auxpwr
			power_mngt_pm_data               : in  std_logic_vector(9 downto 0)  := (others => 'X'); -- pm_data
			power_mngt_pme_to_cr             : in  std_logic                     := 'X';             -- pme_to_cr
			power_mngt_pm_event              : in  std_logic                     := 'X';             -- pm_event
			power_mngt_pme_to_sr             : out std_logic;                                        -- pme_to_sr
			reconfig_clk_clk                 : in  std_logic                     := 'X';             -- clk
			reconfig_reset_reset_n           : in  std_logic                     := 'X';             -- reset_n
			refclk_clk                       : in  std_logic                     := 'X';             -- clk
			rx_bar_be_rx_st_bar              : out std_logic_vector(7 downto 0);                     -- rx_st_bar
			rx_bar_be_rx_st_mask             : in  std_logic                     := 'X';             -- rx_st_mask
			rx_st_valid                      : out std_logic;                                        -- valid
			rx_st_startofpacket              : out std_logic;                                        -- startofpacket
			rx_st_endofpacket                : out std_logic;                                        -- endofpacket
			rx_st_ready                      : in  std_logic                     := 'X';             -- ready
			rx_st_error                      : out std_logic;                                        -- error
			rx_st_data                       : out std_logic_vector(63 downto 0);                    -- data
			tx_cred_tx_cred_datafccp         : out std_logic_vector(11 downto 0);                    -- tx_cred_datafccp
			tx_cred_tx_cred_datafcnp         : out std_logic_vector(11 downto 0);                    -- tx_cred_datafcnp
			tx_cred_tx_cred_datafcp          : out std_logic_vector(11 downto 0);                    -- tx_cred_datafcp
			tx_cred_tx_cred_fchipcons        : out std_logic_vector(5 downto 0);                     -- tx_cred_fchipcons
			tx_cred_tx_cred_fcinfinite       : out std_logic_vector(5 downto 0);                     -- tx_cred_fcinfinite
			tx_cred_tx_cred_hdrfccp          : out std_logic_vector(7 downto 0);                     -- tx_cred_hdrfccp
			tx_cred_tx_cred_hdrfcnp          : out std_logic_vector(7 downto 0);                     -- tx_cred_hdrfcnp
			tx_cred_tx_cred_hdrfcp           : out std_logic_vector(7 downto 0);                     -- tx_cred_hdrfcp
			tx_fifo_fifo_empty               : out std_logic;                                        -- fifo_empty
			tx_st_valid                      : in  std_logic                     := 'X';             -- valid
			tx_st_startofpacket              : in  std_logic                     := 'X';             -- startofpacket
			tx_st_endofpacket                : in  std_logic                     := 'X';             -- endofpacket
			tx_st_ready                      : out std_logic;                                        -- ready
			tx_st_error                      : in  std_logic                     := 'X';             -- error
			tx_st_data                       : in  std_logic_vector(63 downto 0) := (others => 'X')  -- data
		);
	end component pcie_reconfig;

	u0 : component pcie_reconfig
		port map (
			config_tl_hpg_ctrler             => CONNECTED_TO_config_tl_hpg_ctrler,             --      config_tl.hpg_ctrler
			config_tl_tl_cfg_ctl             => CONNECTED_TO_config_tl_tl_cfg_ctl,             --               .tl_cfg_ctl
			config_tl_cpl_err                => CONNECTED_TO_config_tl_cpl_err,                --               .cpl_err
			config_tl_tl_cfg_add             => CONNECTED_TO_config_tl_tl_cfg_add,             --               .tl_cfg_add
			config_tl_tl_cfg_ctl_wr          => CONNECTED_TO_config_tl_tl_cfg_ctl_wr,          --               .tl_cfg_ctl_wr
			config_tl_tl_cfg_sts_wr          => CONNECTED_TO_config_tl_tl_cfg_sts_wr,          --               .tl_cfg_sts_wr
			config_tl_tl_cfg_sts             => CONNECTED_TO_config_tl_tl_cfg_sts,             --               .tl_cfg_sts
			config_tl_cpl_pending            => CONNECTED_TO_config_tl_cpl_pending,            --               .cpl_pending
			coreclkout_hip_clk               => CONNECTED_TO_coreclkout_hip_clk,               -- coreclkout_hip.clk
			hip_ctrl_test_in                 => CONNECTED_TO_hip_ctrl_test_in,                 --       hip_ctrl.test_in
			hip_ctrl_simu_mode_pipe          => CONNECTED_TO_hip_ctrl_simu_mode_pipe,          --               .simu_mode_pipe
			hip_pipe_sim_pipe_pclk_in        => CONNECTED_TO_hip_pipe_sim_pipe_pclk_in,        --       hip_pipe.sim_pipe_pclk_in
			hip_pipe_sim_pipe_rate           => CONNECTED_TO_hip_pipe_sim_pipe_rate,           --               .sim_pipe_rate
			hip_pipe_sim_ltssmstate          => CONNECTED_TO_hip_pipe_sim_ltssmstate,          --               .sim_ltssmstate
			hip_pipe_eidleinfersel0          => CONNECTED_TO_hip_pipe_eidleinfersel0,          --               .eidleinfersel0
			hip_pipe_eidleinfersel1          => CONNECTED_TO_hip_pipe_eidleinfersel1,          --               .eidleinfersel1
			hip_pipe_eidleinfersel2          => CONNECTED_TO_hip_pipe_eidleinfersel2,          --               .eidleinfersel2
			hip_pipe_eidleinfersel3          => CONNECTED_TO_hip_pipe_eidleinfersel3,          --               .eidleinfersel3
			hip_pipe_powerdown0              => CONNECTED_TO_hip_pipe_powerdown0,              --               .powerdown0
			hip_pipe_powerdown1              => CONNECTED_TO_hip_pipe_powerdown1,              --               .powerdown1
			hip_pipe_powerdown2              => CONNECTED_TO_hip_pipe_powerdown2,              --               .powerdown2
			hip_pipe_powerdown3              => CONNECTED_TO_hip_pipe_powerdown3,              --               .powerdown3
			hip_pipe_rxpolarity0             => CONNECTED_TO_hip_pipe_rxpolarity0,             --               .rxpolarity0
			hip_pipe_rxpolarity1             => CONNECTED_TO_hip_pipe_rxpolarity1,             --               .rxpolarity1
			hip_pipe_rxpolarity2             => CONNECTED_TO_hip_pipe_rxpolarity2,             --               .rxpolarity2
			hip_pipe_rxpolarity3             => CONNECTED_TO_hip_pipe_rxpolarity3,             --               .rxpolarity3
			hip_pipe_txcompl0                => CONNECTED_TO_hip_pipe_txcompl0,                --               .txcompl0
			hip_pipe_txcompl1                => CONNECTED_TO_hip_pipe_txcompl1,                --               .txcompl1
			hip_pipe_txcompl2                => CONNECTED_TO_hip_pipe_txcompl2,                --               .txcompl2
			hip_pipe_txcompl3                => CONNECTED_TO_hip_pipe_txcompl3,                --               .txcompl3
			hip_pipe_txdata0                 => CONNECTED_TO_hip_pipe_txdata0,                 --               .txdata0
			hip_pipe_txdata1                 => CONNECTED_TO_hip_pipe_txdata1,                 --               .txdata1
			hip_pipe_txdata2                 => CONNECTED_TO_hip_pipe_txdata2,                 --               .txdata2
			hip_pipe_txdata3                 => CONNECTED_TO_hip_pipe_txdata3,                 --               .txdata3
			hip_pipe_txdatak0                => CONNECTED_TO_hip_pipe_txdatak0,                --               .txdatak0
			hip_pipe_txdatak1                => CONNECTED_TO_hip_pipe_txdatak1,                --               .txdatak1
			hip_pipe_txdatak2                => CONNECTED_TO_hip_pipe_txdatak2,                --               .txdatak2
			hip_pipe_txdatak3                => CONNECTED_TO_hip_pipe_txdatak3,                --               .txdatak3
			hip_pipe_txdetectrx0             => CONNECTED_TO_hip_pipe_txdetectrx0,             --               .txdetectrx0
			hip_pipe_txdetectrx1             => CONNECTED_TO_hip_pipe_txdetectrx1,             --               .txdetectrx1
			hip_pipe_txdetectrx2             => CONNECTED_TO_hip_pipe_txdetectrx2,             --               .txdetectrx2
			hip_pipe_txdetectrx3             => CONNECTED_TO_hip_pipe_txdetectrx3,             --               .txdetectrx3
			hip_pipe_txelecidle0             => CONNECTED_TO_hip_pipe_txelecidle0,             --               .txelecidle0
			hip_pipe_txelecidle1             => CONNECTED_TO_hip_pipe_txelecidle1,             --               .txelecidle1
			hip_pipe_txelecidle2             => CONNECTED_TO_hip_pipe_txelecidle2,             --               .txelecidle2
			hip_pipe_txelecidle3             => CONNECTED_TO_hip_pipe_txelecidle3,             --               .txelecidle3
			hip_pipe_txswing0                => CONNECTED_TO_hip_pipe_txswing0,                --               .txswing0
			hip_pipe_txswing1                => CONNECTED_TO_hip_pipe_txswing1,                --               .txswing1
			hip_pipe_txswing2                => CONNECTED_TO_hip_pipe_txswing2,                --               .txswing2
			hip_pipe_txswing3                => CONNECTED_TO_hip_pipe_txswing3,                --               .txswing3
			hip_pipe_txmargin0               => CONNECTED_TO_hip_pipe_txmargin0,               --               .txmargin0
			hip_pipe_txmargin1               => CONNECTED_TO_hip_pipe_txmargin1,               --               .txmargin1
			hip_pipe_txmargin2               => CONNECTED_TO_hip_pipe_txmargin2,               --               .txmargin2
			hip_pipe_txmargin3               => CONNECTED_TO_hip_pipe_txmargin3,               --               .txmargin3
			hip_pipe_txdeemph0               => CONNECTED_TO_hip_pipe_txdeemph0,               --               .txdeemph0
			hip_pipe_txdeemph1               => CONNECTED_TO_hip_pipe_txdeemph1,               --               .txdeemph1
			hip_pipe_txdeemph2               => CONNECTED_TO_hip_pipe_txdeemph2,               --               .txdeemph2
			hip_pipe_txdeemph3               => CONNECTED_TO_hip_pipe_txdeemph3,               --               .txdeemph3
			hip_pipe_phystatus0              => CONNECTED_TO_hip_pipe_phystatus0,              --               .phystatus0
			hip_pipe_phystatus1              => CONNECTED_TO_hip_pipe_phystatus1,              --               .phystatus1
			hip_pipe_phystatus2              => CONNECTED_TO_hip_pipe_phystatus2,              --               .phystatus2
			hip_pipe_phystatus3              => CONNECTED_TO_hip_pipe_phystatus3,              --               .phystatus3
			hip_pipe_rxdata0                 => CONNECTED_TO_hip_pipe_rxdata0,                 --               .rxdata0
			hip_pipe_rxdata1                 => CONNECTED_TO_hip_pipe_rxdata1,                 --               .rxdata1
			hip_pipe_rxdata2                 => CONNECTED_TO_hip_pipe_rxdata2,                 --               .rxdata2
			hip_pipe_rxdata3                 => CONNECTED_TO_hip_pipe_rxdata3,                 --               .rxdata3
			hip_pipe_rxdatak0                => CONNECTED_TO_hip_pipe_rxdatak0,                --               .rxdatak0
			hip_pipe_rxdatak1                => CONNECTED_TO_hip_pipe_rxdatak1,                --               .rxdatak1
			hip_pipe_rxdatak2                => CONNECTED_TO_hip_pipe_rxdatak2,                --               .rxdatak2
			hip_pipe_rxdatak3                => CONNECTED_TO_hip_pipe_rxdatak3,                --               .rxdatak3
			hip_pipe_rxelecidle0             => CONNECTED_TO_hip_pipe_rxelecidle0,             --               .rxelecidle0
			hip_pipe_rxelecidle1             => CONNECTED_TO_hip_pipe_rxelecidle1,             --               .rxelecidle1
			hip_pipe_rxelecidle2             => CONNECTED_TO_hip_pipe_rxelecidle2,             --               .rxelecidle2
			hip_pipe_rxelecidle3             => CONNECTED_TO_hip_pipe_rxelecidle3,             --               .rxelecidle3
			hip_pipe_rxstatus0               => CONNECTED_TO_hip_pipe_rxstatus0,               --               .rxstatus0
			hip_pipe_rxstatus1               => CONNECTED_TO_hip_pipe_rxstatus1,               --               .rxstatus1
			hip_pipe_rxstatus2               => CONNECTED_TO_hip_pipe_rxstatus2,               --               .rxstatus2
			hip_pipe_rxstatus3               => CONNECTED_TO_hip_pipe_rxstatus3,               --               .rxstatus3
			hip_pipe_rxvalid0                => CONNECTED_TO_hip_pipe_rxvalid0,                --               .rxvalid0
			hip_pipe_rxvalid1                => CONNECTED_TO_hip_pipe_rxvalid1,                --               .rxvalid1
			hip_pipe_rxvalid2                => CONNECTED_TO_hip_pipe_rxvalid2,                --               .rxvalid2
			hip_pipe_rxvalid3                => CONNECTED_TO_hip_pipe_rxvalid3,                --               .rxvalid3
			hip_rst_reset_status             => CONNECTED_TO_hip_rst_reset_status,             --        hip_rst.reset_status
			hip_rst_serdes_pll_locked        => CONNECTED_TO_hip_rst_serdes_pll_locked,        --               .serdes_pll_locked
			hip_rst_pld_clk_inuse            => CONNECTED_TO_hip_rst_pld_clk_inuse,            --               .pld_clk_inuse
			hip_rst_pld_core_ready           => CONNECTED_TO_hip_rst_pld_core_ready,           --               .pld_core_ready
			hip_rst_testin_zero              => CONNECTED_TO_hip_rst_testin_zero,              --               .testin_zero
			hip_serial_rx_in0                => CONNECTED_TO_hip_serial_rx_in0,                --     hip_serial.rx_in0
			hip_serial_rx_in1                => CONNECTED_TO_hip_serial_rx_in1,                --               .rx_in1
			hip_serial_rx_in2                => CONNECTED_TO_hip_serial_rx_in2,                --               .rx_in2
			hip_serial_rx_in3                => CONNECTED_TO_hip_serial_rx_in3,                --               .rx_in3
			hip_serial_tx_out0               => CONNECTED_TO_hip_serial_tx_out0,               --               .tx_out0
			hip_serial_tx_out1               => CONNECTED_TO_hip_serial_tx_out1,               --               .tx_out1
			hip_serial_tx_out2               => CONNECTED_TO_hip_serial_tx_out2,               --               .tx_out2
			hip_serial_tx_out3               => CONNECTED_TO_hip_serial_tx_out3,               --               .tx_out3
			hip_status_derr_cor_ext_rcv      => CONNECTED_TO_hip_status_derr_cor_ext_rcv,      --     hip_status.derr_cor_ext_rcv
			hip_status_derr_cor_ext_rpl      => CONNECTED_TO_hip_status_derr_cor_ext_rpl,      --               .derr_cor_ext_rpl
			hip_status_derr_rpl              => CONNECTED_TO_hip_status_derr_rpl,              --               .derr_rpl
			hip_status_dlup_exit             => CONNECTED_TO_hip_status_dlup_exit,             --               .dlup_exit
			hip_status_ltssmstate            => CONNECTED_TO_hip_status_ltssmstate,            --               .ltssmstate
			hip_status_ev128ns               => CONNECTED_TO_hip_status_ev128ns,               --               .ev128ns
			hip_status_ev1us                 => CONNECTED_TO_hip_status_ev1us,                 --               .ev1us
			hip_status_hotrst_exit           => CONNECTED_TO_hip_status_hotrst_exit,           --               .hotrst_exit
			hip_status_int_status            => CONNECTED_TO_hip_status_int_status,            --               .int_status
			hip_status_l2_exit               => CONNECTED_TO_hip_status_l2_exit,               --               .l2_exit
			hip_status_lane_act              => CONNECTED_TO_hip_status_lane_act,              --               .lane_act
			hip_status_ko_cpl_spc_header     => CONNECTED_TO_hip_status_ko_cpl_spc_header,     --               .ko_cpl_spc_header
			hip_status_ko_cpl_spc_data       => CONNECTED_TO_hip_status_ko_cpl_spc_data,       --               .ko_cpl_spc_data
			hip_status_drv_derr_cor_ext_rcv  => CONNECTED_TO_hip_status_drv_derr_cor_ext_rcv,  -- hip_status_drv.derr_cor_ext_rcv
			hip_status_drv_derr_cor_ext_rpl  => CONNECTED_TO_hip_status_drv_derr_cor_ext_rpl,  --               .derr_cor_ext_rpl
			hip_status_drv_derr_rpl          => CONNECTED_TO_hip_status_drv_derr_rpl,          --               .derr_rpl
			hip_status_drv_dlup_exit         => CONNECTED_TO_hip_status_drv_dlup_exit,         --               .dlup_exit
			hip_status_drv_ev128ns           => CONNECTED_TO_hip_status_drv_ev128ns,           --               .ev128ns
			hip_status_drv_ev1us             => CONNECTED_TO_hip_status_drv_ev1us,             --               .ev1us
			hip_status_drv_hotrst_exit       => CONNECTED_TO_hip_status_drv_hotrst_exit,       --               .hotrst_exit
			hip_status_drv_int_status        => CONNECTED_TO_hip_status_drv_int_status,        --               .int_status
			hip_status_drv_l2_exit           => CONNECTED_TO_hip_status_drv_l2_exit,           --               .l2_exit
			hip_status_drv_lane_act          => CONNECTED_TO_hip_status_drv_lane_act,          --               .lane_act
			hip_status_drv_ltssmstate        => CONNECTED_TO_hip_status_drv_ltssmstate,        --               .ltssmstate
			hip_status_drv_ko_cpl_spc_header => CONNECTED_TO_hip_status_drv_ko_cpl_spc_header, --               .ko_cpl_spc_header
			hip_status_drv_ko_cpl_spc_data   => CONNECTED_TO_hip_status_drv_ko_cpl_spc_data,   --               .ko_cpl_spc_data
			int_msi_app_msi_num              => CONNECTED_TO_int_msi_app_msi_num,              --        int_msi.app_msi_num
			int_msi_app_msi_req              => CONNECTED_TO_int_msi_app_msi_req,              --               .app_msi_req
			int_msi_app_msi_tc               => CONNECTED_TO_int_msi_app_msi_tc,               --               .app_msi_tc
			int_msi_app_msi_ack              => CONNECTED_TO_int_msi_app_msi_ack,              --               .app_msi_ack
			int_msi_app_int_sts              => CONNECTED_TO_int_msi_app_int_sts,              --               .app_int_sts
			lmi_lmi_addr                     => CONNECTED_TO_lmi_lmi_addr,                     --            lmi.lmi_addr
			lmi_lmi_din                      => CONNECTED_TO_lmi_lmi_din,                      --               .lmi_din
			lmi_lmi_rden                     => CONNECTED_TO_lmi_lmi_rden,                     --               .lmi_rden
			lmi_lmi_wren                     => CONNECTED_TO_lmi_lmi_wren,                     --               .lmi_wren
			lmi_lmi_ack                      => CONNECTED_TO_lmi_lmi_ack,                      --               .lmi_ack
			lmi_lmi_dout                     => CONNECTED_TO_lmi_lmi_dout,                     --               .lmi_dout
			npor_npor                        => CONNECTED_TO_npor_npor,                        --           npor.npor
			npor_pin_perst                   => CONNECTED_TO_npor_pin_perst,                   --               .pin_perst
			pld_clk_clk                      => CONNECTED_TO_pld_clk_clk,                      --        pld_clk.clk
			pld_clk_1_clk                    => CONNECTED_TO_pld_clk_1_clk,                    --      pld_clk_1.clk
			power_mngt_pm_auxpwr             => CONNECTED_TO_power_mngt_pm_auxpwr,             --     power_mngt.pm_auxpwr
			power_mngt_pm_data               => CONNECTED_TO_power_mngt_pm_data,               --               .pm_data
			power_mngt_pme_to_cr             => CONNECTED_TO_power_mngt_pme_to_cr,             --               .pme_to_cr
			power_mngt_pm_event              => CONNECTED_TO_power_mngt_pm_event,              --               .pm_event
			power_mngt_pme_to_sr             => CONNECTED_TO_power_mngt_pme_to_sr,             --               .pme_to_sr
			reconfig_clk_clk                 => CONNECTED_TO_reconfig_clk_clk,                 --   reconfig_clk.clk
			reconfig_reset_reset_n           => CONNECTED_TO_reconfig_reset_reset_n,           -- reconfig_reset.reset_n
			refclk_clk                       => CONNECTED_TO_refclk_clk,                       --         refclk.clk
			rx_bar_be_rx_st_bar              => CONNECTED_TO_rx_bar_be_rx_st_bar,              --      rx_bar_be.rx_st_bar
			rx_bar_be_rx_st_mask             => CONNECTED_TO_rx_bar_be_rx_st_mask,             --               .rx_st_mask
			rx_st_valid                      => CONNECTED_TO_rx_st_valid,                      --          rx_st.valid
			rx_st_startofpacket              => CONNECTED_TO_rx_st_startofpacket,              --               .startofpacket
			rx_st_endofpacket                => CONNECTED_TO_rx_st_endofpacket,                --               .endofpacket
			rx_st_ready                      => CONNECTED_TO_rx_st_ready,                      --               .ready
			rx_st_error                      => CONNECTED_TO_rx_st_error,                      --               .error
			rx_st_data                       => CONNECTED_TO_rx_st_data,                       --               .data
			tx_cred_tx_cred_datafccp         => CONNECTED_TO_tx_cred_tx_cred_datafccp,         --        tx_cred.tx_cred_datafccp
			tx_cred_tx_cred_datafcnp         => CONNECTED_TO_tx_cred_tx_cred_datafcnp,         --               .tx_cred_datafcnp
			tx_cred_tx_cred_datafcp          => CONNECTED_TO_tx_cred_tx_cred_datafcp,          --               .tx_cred_datafcp
			tx_cred_tx_cred_fchipcons        => CONNECTED_TO_tx_cred_tx_cred_fchipcons,        --               .tx_cred_fchipcons
			tx_cred_tx_cred_fcinfinite       => CONNECTED_TO_tx_cred_tx_cred_fcinfinite,       --               .tx_cred_fcinfinite
			tx_cred_tx_cred_hdrfccp          => CONNECTED_TO_tx_cred_tx_cred_hdrfccp,          --               .tx_cred_hdrfccp
			tx_cred_tx_cred_hdrfcnp          => CONNECTED_TO_tx_cred_tx_cred_hdrfcnp,          --               .tx_cred_hdrfcnp
			tx_cred_tx_cred_hdrfcp           => CONNECTED_TO_tx_cred_tx_cred_hdrfcp,           --               .tx_cred_hdrfcp
			tx_fifo_fifo_empty               => CONNECTED_TO_tx_fifo_fifo_empty,               --        tx_fifo.fifo_empty
			tx_st_valid                      => CONNECTED_TO_tx_st_valid,                      --          tx_st.valid
			tx_st_startofpacket              => CONNECTED_TO_tx_st_startofpacket,              --               .startofpacket
			tx_st_endofpacket                => CONNECTED_TO_tx_st_endofpacket,                --               .endofpacket
			tx_st_ready                      => CONNECTED_TO_tx_st_ready,                      --               .ready
			tx_st_error                      => CONNECTED_TO_tx_st_error,                      --               .error
			tx_st_data                       => CONNECTED_TO_tx_st_data                        --               .data
		);

