onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {avl signals} /wfm_player_tb/wfm_player_dut0/avalon_traffic_gen_inst2/avl_ready
add wave -noupdate -expand -group {avl signals} /wfm_player_tb/wfm_player_dut0/avalon_traffic_gen_inst2/avl_write_req
add wave -noupdate -expand -group {avl signals} /wfm_player_tb/wfm_player_dut0/avalon_traffic_gen_inst2/avl_read_req
add wave -noupdate -expand -group {avl signals} /wfm_player_tb/wfm_player_dut0/avalon_traffic_gen_inst2/avl_burstbegin
add wave -noupdate -expand -group {avl signals} -radix unsigned /wfm_player_tb/wfm_player_dut0/avalon_traffic_gen_inst2/avl_addr
add wave -noupdate -expand -group {avl signals} /wfm_player_tb/wfm_player_dut0/avalon_traffic_gen_inst2/avl_size
add wave -noupdate -expand -group {avl signals} -radix hexadecimal /wfm_player_tb/wfm_player_dut0/avalon_traffic_gen_inst2/avl_wdata
add wave -noupdate -expand -group {avl signals} /wfm_player_tb/wfm_player_dut0/avalon_traffic_gen_inst2/avl_be
add wave -noupdate -expand -group {wfm infifo} /wfm_player_tb/wfm_player_dut0/wfm_infifo_inst0/wrclk
add wave -noupdate -expand -group {wfm infifo} /wfm_player_tb/wfm_player_dut0/wfm_infifo_inst0/wrreq
add wave -noupdate -expand -group {wfm infifo} -radix hexadecimal /wfm_player_tb/wfm_player_dut0/wfm_infifo_inst0/data
add wave -noupdate -expand -group {wfm infifo} /wfm_player_tb/wfm_player_dut0/wfm_infifo_inst0/wrfull
add wave -noupdate -expand -group {wfm infifo} /wfm_player_tb/wfm_player_dut0/wfm_infifo_inst0/wrempty
add wave -noupdate -expand -group {wfm infifo} /wfm_player_tb/wfm_player_dut0/wfm_infifo_inst0/wrusedw
add wave -noupdate -expand -group {wfm infifo} /wfm_player_tb/wfm_player_dut0/wfm_infifo_inst0/rdclk
add wave -noupdate -expand -group {wfm infifo} /wfm_player_tb/wfm_player_dut0/wfm_infifo_inst0/rdreq
add wave -noupdate -expand -group {wfm infifo} -radix hexadecimal /wfm_player_tb/wfm_player_dut0/wfm_infifo_inst0/q
add wave -noupdate -expand -group {wfm infifo} /wfm_player_tb/wfm_player_dut0/wfm_infifo_inst0/rdempty
add wave -noupdate -expand -group {wfm infifo} /wfm_player_tb/wfm_player_dut0/wfm_infifo_inst0/reset_n
add wave -noupdate -expand -group {wfm infifo} -radix hexadecimal /wfm_player_tb/wfm_player_dut0/wfm_infifo_inst0/rdusedw
add wave -noupdate -expand -group {wfm infifo} /wfm_player_tb/wfm_player_dut0/wfm_infifo_inst0/rdempty
add wave -noupdate /wfm_player_tb/wfm_player_dut0/avalon_traffic_gen_inst2/write_addr
add wave -noupdate /wfm_player_tb/wfm_player_dut0/avalon_traffic_gen_inst2/do_write
add wave -noupdate -radix hexadecimal /wfm_player_tb/wfm_player_dut0/avalon_traffic_gen_inst2/write_addr
add wave -noupdate -radix hexadecimal /wfm_player_tb/wfm_player_dut0/avalon_traffic_gen_inst2/wdata
add wave -noupdate /wfm_player_tb/wfm_player_dut0/avalon_traffic_gen_inst2/write_burstcount
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {396708 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {299037 ps} {517399 ps}
