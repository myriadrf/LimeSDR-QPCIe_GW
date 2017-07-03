
module pcie_reconfig (
	config_tl_hpg_ctrler,
	config_tl_tl_cfg_ctl,
	config_tl_cpl_err,
	config_tl_tl_cfg_add,
	config_tl_tl_cfg_ctl_wr,
	config_tl_tl_cfg_sts_wr,
	config_tl_tl_cfg_sts,
	config_tl_cpl_pending,
	coreclkout_hip_clk,
	hip_ctrl_test_in,
	hip_ctrl_simu_mode_pipe,
	hip_pipe_sim_pipe_pclk_in,
	hip_pipe_sim_pipe_rate,
	hip_pipe_sim_ltssmstate,
	hip_pipe_eidleinfersel0,
	hip_pipe_eidleinfersel1,
	hip_pipe_eidleinfersel2,
	hip_pipe_eidleinfersel3,
	hip_pipe_powerdown0,
	hip_pipe_powerdown1,
	hip_pipe_powerdown2,
	hip_pipe_powerdown3,
	hip_pipe_rxpolarity0,
	hip_pipe_rxpolarity1,
	hip_pipe_rxpolarity2,
	hip_pipe_rxpolarity3,
	hip_pipe_txcompl0,
	hip_pipe_txcompl1,
	hip_pipe_txcompl2,
	hip_pipe_txcompl3,
	hip_pipe_txdata0,
	hip_pipe_txdata1,
	hip_pipe_txdata2,
	hip_pipe_txdata3,
	hip_pipe_txdatak0,
	hip_pipe_txdatak1,
	hip_pipe_txdatak2,
	hip_pipe_txdatak3,
	hip_pipe_txdetectrx0,
	hip_pipe_txdetectrx1,
	hip_pipe_txdetectrx2,
	hip_pipe_txdetectrx3,
	hip_pipe_txelecidle0,
	hip_pipe_txelecidle1,
	hip_pipe_txelecidle2,
	hip_pipe_txelecidle3,
	hip_pipe_txswing0,
	hip_pipe_txswing1,
	hip_pipe_txswing2,
	hip_pipe_txswing3,
	hip_pipe_txmargin0,
	hip_pipe_txmargin1,
	hip_pipe_txmargin2,
	hip_pipe_txmargin3,
	hip_pipe_txdeemph0,
	hip_pipe_txdeemph1,
	hip_pipe_txdeemph2,
	hip_pipe_txdeemph3,
	hip_pipe_phystatus0,
	hip_pipe_phystatus1,
	hip_pipe_phystatus2,
	hip_pipe_phystatus3,
	hip_pipe_rxdata0,
	hip_pipe_rxdata1,
	hip_pipe_rxdata2,
	hip_pipe_rxdata3,
	hip_pipe_rxdatak0,
	hip_pipe_rxdatak1,
	hip_pipe_rxdatak2,
	hip_pipe_rxdatak3,
	hip_pipe_rxelecidle0,
	hip_pipe_rxelecidle1,
	hip_pipe_rxelecidle2,
	hip_pipe_rxelecidle3,
	hip_pipe_rxstatus0,
	hip_pipe_rxstatus1,
	hip_pipe_rxstatus2,
	hip_pipe_rxstatus3,
	hip_pipe_rxvalid0,
	hip_pipe_rxvalid1,
	hip_pipe_rxvalid2,
	hip_pipe_rxvalid3,
	hip_rst_reset_status,
	hip_rst_serdes_pll_locked,
	hip_rst_pld_clk_inuse,
	hip_rst_pld_core_ready,
	hip_rst_testin_zero,
	hip_serial_rx_in0,
	hip_serial_rx_in1,
	hip_serial_rx_in2,
	hip_serial_rx_in3,
	hip_serial_tx_out0,
	hip_serial_tx_out1,
	hip_serial_tx_out2,
	hip_serial_tx_out3,
	hip_status_derr_cor_ext_rcv,
	hip_status_derr_cor_ext_rpl,
	hip_status_derr_rpl,
	hip_status_dlup_exit,
	hip_status_ltssmstate,
	hip_status_ev128ns,
	hip_status_ev1us,
	hip_status_hotrst_exit,
	hip_status_int_status,
	hip_status_l2_exit,
	hip_status_lane_act,
	hip_status_ko_cpl_spc_header,
	hip_status_ko_cpl_spc_data,
	hip_status_drv_derr_cor_ext_rcv,
	hip_status_drv_derr_cor_ext_rpl,
	hip_status_drv_derr_rpl,
	hip_status_drv_dlup_exit,
	hip_status_drv_ev128ns,
	hip_status_drv_ev1us,
	hip_status_drv_hotrst_exit,
	hip_status_drv_int_status,
	hip_status_drv_l2_exit,
	hip_status_drv_lane_act,
	hip_status_drv_ltssmstate,
	hip_status_drv_ko_cpl_spc_header,
	hip_status_drv_ko_cpl_spc_data,
	int_msi_app_msi_num,
	int_msi_app_msi_req,
	int_msi_app_msi_tc,
	int_msi_app_msi_ack,
	int_msi_app_int_sts,
	lmi_lmi_addr,
	lmi_lmi_din,
	lmi_lmi_rden,
	lmi_lmi_wren,
	lmi_lmi_ack,
	lmi_lmi_dout,
	npor_npor,
	npor_pin_perst,
	pld_clk_clk,
	pld_clk_1_clk,
	power_mngt_pm_auxpwr,
	power_mngt_pm_data,
	power_mngt_pme_to_cr,
	power_mngt_pm_event,
	power_mngt_pme_to_sr,
	reconfig_clk_clk,
	reconfig_reset_reset_n,
	refclk_clk,
	rx_bar_be_rx_st_bar,
	rx_bar_be_rx_st_mask,
	rx_st_valid,
	rx_st_startofpacket,
	rx_st_endofpacket,
	rx_st_ready,
	rx_st_error,
	rx_st_data,
	tx_cred_tx_cred_datafccp,
	tx_cred_tx_cred_datafcnp,
	tx_cred_tx_cred_datafcp,
	tx_cred_tx_cred_fchipcons,
	tx_cred_tx_cred_fcinfinite,
	tx_cred_tx_cred_hdrfccp,
	tx_cred_tx_cred_hdrfcnp,
	tx_cred_tx_cred_hdrfcp,
	tx_fifo_fifo_empty,
	tx_st_valid,
	tx_st_startofpacket,
	tx_st_endofpacket,
	tx_st_ready,
	tx_st_error,
	tx_st_data);	

	input	[4:0]	config_tl_hpg_ctrler;
	output	[31:0]	config_tl_tl_cfg_ctl;
	input	[6:0]	config_tl_cpl_err;
	output	[3:0]	config_tl_tl_cfg_add;
	output		config_tl_tl_cfg_ctl_wr;
	output		config_tl_tl_cfg_sts_wr;
	output	[52:0]	config_tl_tl_cfg_sts;
	input	[0:0]	config_tl_cpl_pending;
	output		coreclkout_hip_clk;
	input	[31:0]	hip_ctrl_test_in;
	input		hip_ctrl_simu_mode_pipe;
	input		hip_pipe_sim_pipe_pclk_in;
	output	[1:0]	hip_pipe_sim_pipe_rate;
	output	[4:0]	hip_pipe_sim_ltssmstate;
	output	[2:0]	hip_pipe_eidleinfersel0;
	output	[2:0]	hip_pipe_eidleinfersel1;
	output	[2:0]	hip_pipe_eidleinfersel2;
	output	[2:0]	hip_pipe_eidleinfersel3;
	output	[1:0]	hip_pipe_powerdown0;
	output	[1:0]	hip_pipe_powerdown1;
	output	[1:0]	hip_pipe_powerdown2;
	output	[1:0]	hip_pipe_powerdown3;
	output		hip_pipe_rxpolarity0;
	output		hip_pipe_rxpolarity1;
	output		hip_pipe_rxpolarity2;
	output		hip_pipe_rxpolarity3;
	output		hip_pipe_txcompl0;
	output		hip_pipe_txcompl1;
	output		hip_pipe_txcompl2;
	output		hip_pipe_txcompl3;
	output	[7:0]	hip_pipe_txdata0;
	output	[7:0]	hip_pipe_txdata1;
	output	[7:0]	hip_pipe_txdata2;
	output	[7:0]	hip_pipe_txdata3;
	output		hip_pipe_txdatak0;
	output		hip_pipe_txdatak1;
	output		hip_pipe_txdatak2;
	output		hip_pipe_txdatak3;
	output		hip_pipe_txdetectrx0;
	output		hip_pipe_txdetectrx1;
	output		hip_pipe_txdetectrx2;
	output		hip_pipe_txdetectrx3;
	output		hip_pipe_txelecidle0;
	output		hip_pipe_txelecidle1;
	output		hip_pipe_txelecidle2;
	output		hip_pipe_txelecidle3;
	output		hip_pipe_txswing0;
	output		hip_pipe_txswing1;
	output		hip_pipe_txswing2;
	output		hip_pipe_txswing3;
	output	[2:0]	hip_pipe_txmargin0;
	output	[2:0]	hip_pipe_txmargin1;
	output	[2:0]	hip_pipe_txmargin2;
	output	[2:0]	hip_pipe_txmargin3;
	output		hip_pipe_txdeemph0;
	output		hip_pipe_txdeemph1;
	output		hip_pipe_txdeemph2;
	output		hip_pipe_txdeemph3;
	input		hip_pipe_phystatus0;
	input		hip_pipe_phystatus1;
	input		hip_pipe_phystatus2;
	input		hip_pipe_phystatus3;
	input	[7:0]	hip_pipe_rxdata0;
	input	[7:0]	hip_pipe_rxdata1;
	input	[7:0]	hip_pipe_rxdata2;
	input	[7:0]	hip_pipe_rxdata3;
	input		hip_pipe_rxdatak0;
	input		hip_pipe_rxdatak1;
	input		hip_pipe_rxdatak2;
	input		hip_pipe_rxdatak3;
	input		hip_pipe_rxelecidle0;
	input		hip_pipe_rxelecidle1;
	input		hip_pipe_rxelecidle2;
	input		hip_pipe_rxelecidle3;
	input	[2:0]	hip_pipe_rxstatus0;
	input	[2:0]	hip_pipe_rxstatus1;
	input	[2:0]	hip_pipe_rxstatus2;
	input	[2:0]	hip_pipe_rxstatus3;
	input		hip_pipe_rxvalid0;
	input		hip_pipe_rxvalid1;
	input		hip_pipe_rxvalid2;
	input		hip_pipe_rxvalid3;
	output		hip_rst_reset_status;
	output		hip_rst_serdes_pll_locked;
	output		hip_rst_pld_clk_inuse;
	input		hip_rst_pld_core_ready;
	output		hip_rst_testin_zero;
	input		hip_serial_rx_in0;
	input		hip_serial_rx_in1;
	input		hip_serial_rx_in2;
	input		hip_serial_rx_in3;
	output		hip_serial_tx_out0;
	output		hip_serial_tx_out1;
	output		hip_serial_tx_out2;
	output		hip_serial_tx_out3;
	output		hip_status_derr_cor_ext_rcv;
	output		hip_status_derr_cor_ext_rpl;
	output		hip_status_derr_rpl;
	output		hip_status_dlup_exit;
	output	[4:0]	hip_status_ltssmstate;
	output		hip_status_ev128ns;
	output		hip_status_ev1us;
	output		hip_status_hotrst_exit;
	output	[3:0]	hip_status_int_status;
	output		hip_status_l2_exit;
	output	[3:0]	hip_status_lane_act;
	output	[7:0]	hip_status_ko_cpl_spc_header;
	output	[11:0]	hip_status_ko_cpl_spc_data;
	input		hip_status_drv_derr_cor_ext_rcv;
	input		hip_status_drv_derr_cor_ext_rpl;
	input		hip_status_drv_derr_rpl;
	input		hip_status_drv_dlup_exit;
	input		hip_status_drv_ev128ns;
	input		hip_status_drv_ev1us;
	input		hip_status_drv_hotrst_exit;
	input	[3:0]	hip_status_drv_int_status;
	input		hip_status_drv_l2_exit;
	input	[3:0]	hip_status_drv_lane_act;
	input	[4:0]	hip_status_drv_ltssmstate;
	input	[7:0]	hip_status_drv_ko_cpl_spc_header;
	input	[11:0]	hip_status_drv_ko_cpl_spc_data;
	input	[4:0]	int_msi_app_msi_num;
	input		int_msi_app_msi_req;
	input	[2:0]	int_msi_app_msi_tc;
	output		int_msi_app_msi_ack;
	input		int_msi_app_int_sts;
	input	[11:0]	lmi_lmi_addr;
	input	[31:0]	lmi_lmi_din;
	input		lmi_lmi_rden;
	input		lmi_lmi_wren;
	output		lmi_lmi_ack;
	output	[31:0]	lmi_lmi_dout;
	input		npor_npor;
	input		npor_pin_perst;
	input		pld_clk_clk;
	input		pld_clk_1_clk;
	input		power_mngt_pm_auxpwr;
	input	[9:0]	power_mngt_pm_data;
	input		power_mngt_pme_to_cr;
	input		power_mngt_pm_event;
	output		power_mngt_pme_to_sr;
	input		reconfig_clk_clk;
	input		reconfig_reset_reset_n;
	input		refclk_clk;
	output	[7:0]	rx_bar_be_rx_st_bar;
	input		rx_bar_be_rx_st_mask;
	output		rx_st_valid;
	output		rx_st_startofpacket;
	output		rx_st_endofpacket;
	input		rx_st_ready;
	output		rx_st_error;
	output	[63:0]	rx_st_data;
	output	[11:0]	tx_cred_tx_cred_datafccp;
	output	[11:0]	tx_cred_tx_cred_datafcnp;
	output	[11:0]	tx_cred_tx_cred_datafcp;
	output	[5:0]	tx_cred_tx_cred_fchipcons;
	output	[5:0]	tx_cred_tx_cred_fcinfinite;
	output	[7:0]	tx_cred_tx_cred_hdrfccp;
	output	[7:0]	tx_cred_tx_cred_hdrfcnp;
	output	[7:0]	tx_cred_tx_cred_hdrfcp;
	output		tx_fifo_fifo_empty;
	input		tx_st_valid;
	input		tx_st_startofpacket;
	input		tx_st_endofpacket;
	output		tx_st_ready;
	input		tx_st_error;
	input	[63:0]	tx_st_data;
endmodule
