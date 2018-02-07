	nios_cpu u0 (
		.clk_clk                                    (<connected-to-clk_clk>),                                    //                                 clk.clk
		.dac_spi1_MISO                              (<connected-to-dac_spi1_MISO>),                              //                            dac_spi1.MISO
		.dac_spi1_MOSI                              (<connected-to-dac_spi1_MOSI>),                              //                                    .MOSI
		.dac_spi1_SCLK                              (<connected-to-dac_spi1_SCLK>),                              //                                    .SCLK
		.dac_spi1_SS_n                              (<connected-to-dac_spi1_SS_n>),                              //                                    .SS_n
		.exfifo_if_d_export                         (<connected-to-exfifo_if_d_export>),                         //                         exfifo_if_d.export
		.exfifo_if_rd_export                        (<connected-to-exfifo_if_rd_export>),                        //                        exfifo_if_rd.export
		.exfifo_if_rdempty_export                   (<connected-to-exfifo_if_rdempty_export>),                   //                   exfifo_if_rdempty.export
		.exfifo_of_d_export                         (<connected-to-exfifo_of_d_export>),                         //                         exfifo_of_d.export
		.exfifo_of_wr_export                        (<connected-to-exfifo_of_wr_export>),                        //                        exfifo_of_wr.export
		.exfifo_of_wrfull_export                    (<connected-to-exfifo_of_wrfull_export>),                    //                    exfifo_of_wrfull.export
		.exfifo_rst_export                          (<connected-to-exfifo_rst_export>),                          //                          exfifo_rst.export
		.fpga_spi0_MISO                             (<connected-to-fpga_spi0_MISO>),                             //                           fpga_spi0.MISO
		.fpga_spi0_MOSI                             (<connected-to-fpga_spi0_MOSI>),                             //                                    .MOSI
		.fpga_spi0_SCLK                             (<connected-to-fpga_spi0_SCLK>),                             //                                    .SCLK
		.fpga_spi0_SS_n                             (<connected-to-fpga_spi0_SS_n>),                             //                                    .SS_n
		.gpi0_export                                (<connected-to-gpi0_export>),                                //                                gpi0.export
		.gpio0_export                               (<connected-to-gpio0_export>),                               //                               gpio0.export
		.pll_lock_external_connection_export        (<connected-to-pll_lock_external_connection_export>),        //        pll_lock_external_connection.export
		.pll_recfg_from_pll_0_reconfig_from_pll     (<connected-to-pll_recfg_from_pll_0_reconfig_from_pll>),     //                pll_recfg_from_pll_0.reconfig_from_pll
		.pll_recfg_from_pll_1_reconfig_from_pll     (<connected-to-pll_recfg_from_pll_1_reconfig_from_pll>),     //                pll_recfg_from_pll_1.reconfig_from_pll
		.pll_recfg_from_pll_2_reconfig_from_pll     (<connected-to-pll_recfg_from_pll_2_reconfig_from_pll>),     //                pll_recfg_from_pll_2.reconfig_from_pll
		.pll_recfg_from_pll_3_reconfig_from_pll     (<connected-to-pll_recfg_from_pll_3_reconfig_from_pll>),     //                pll_recfg_from_pll_3.reconfig_from_pll
		.pll_recfg_from_pll_4_reconfig_from_pll     (<connected-to-pll_recfg_from_pll_4_reconfig_from_pll>),     //                pll_recfg_from_pll_4.reconfig_from_pll
		.pll_recfg_from_pll_5_reconfig_from_pll     (<connected-to-pll_recfg_from_pll_5_reconfig_from_pll>),     //                pll_recfg_from_pll_5.reconfig_from_pll
		.pll_recfg_to_pll_0_reconfig_to_pll         (<connected-to-pll_recfg_to_pll_0_reconfig_to_pll>),         //                  pll_recfg_to_pll_0.reconfig_to_pll
		.pll_recfg_to_pll_1_reconfig_to_pll         (<connected-to-pll_recfg_to_pll_1_reconfig_to_pll>),         //                  pll_recfg_to_pll_1.reconfig_to_pll
		.pll_recfg_to_pll_2_reconfig_to_pll         (<connected-to-pll_recfg_to_pll_2_reconfig_to_pll>),         //                  pll_recfg_to_pll_2.reconfig_to_pll
		.pll_recfg_to_pll_3_reconfig_to_pll         (<connected-to-pll_recfg_to_pll_3_reconfig_to_pll>),         //                  pll_recfg_to_pll_3.reconfig_to_pll
		.pll_recfg_to_pll_4_reconfig_to_pll         (<connected-to-pll_recfg_to_pll_4_reconfig_to_pll>),         //                  pll_recfg_to_pll_4.reconfig_to_pll
		.pll_recfg_to_pll_5_reconfig_to_pll         (<connected-to-pll_recfg_to_pll_5_reconfig_to_pll>),         //                  pll_recfg_to_pll_5.reconfig_to_pll
		.pll_rst_export                             (<connected-to-pll_rst_export>),                             //                             pll_rst.export
		.pllcfg_cmd_export                          (<connected-to-pllcfg_cmd_export>),                          //                          pllcfg_cmd.export
		.pllcfg_err_external_connection_export      (<connected-to-pllcfg_err_external_connection_export>),      //      pllcfg_err_external_connection.export
		.pllcfg_spi_MISO                            (<connected-to-pllcfg_spi_MISO>),                            //                          pllcfg_spi.MISO
		.pllcfg_spi_MOSI                            (<connected-to-pllcfg_spi_MOSI>),                            //                                    .MOSI
		.pllcfg_spi_SCLK                            (<connected-to-pllcfg_spi_SCLK>),                            //                                    .SCLK
		.pllcfg_spi_SS_n                            (<connected-to-pllcfg_spi_SS_n>),                            //                                    .SS_n
		.pllcfg_stat_export                         (<connected-to-pllcfg_stat_export>),                         //                         pllcfg_stat.export
		.scl_export                                 (<connected-to-scl_export>),                                 //                                 scl.export
		.sda_export                                 (<connected-to-sda_export>),                                 //                                 sda.export
		.smpl_cmp_en_external_connection_export     (<connected-to-smpl_cmp_en_external_connection_export>),     //     smpl_cmp_en_external_connection.export
		.smpl_cmp_status_external_connection_export (<connected-to-smpl_cmp_status_external_connection_export>)  // smpl_cmp_status_external_connection.export
	);
