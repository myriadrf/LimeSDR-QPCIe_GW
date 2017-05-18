onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fifo_bulk_read_tb/fifo_bulk_read_inst1/clk
add wave -noupdate /fifo_bulk_read_tb/fifo_bulk_read_inst1/reset_n
add wave -noupdate /fifo_bulk_read_tb/fifo_bulk_read_inst1/bulk_size
add wave -noupdate /fifo_bulk_read_tb/fifo_bulk_read_inst1/bulk_buff_rdy
add wave -noupdate -radix decimal /fifo_bulk_read_tb/fifo_bulk_read_inst1/fifo_rdusedw
add wave -noupdate /fifo_bulk_read_tb/fifo_bulk_read_inst1/fifo_rdreq
add wave -noupdate -radix unsigned /fifo_bulk_read_tb/fifo_bulk_read_inst1/rd_cnt
add wave -noupdate /fifo_bulk_read_tb/fifo_bulk_read_inst1/current_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10881523 ps} 0}
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
WaveRestoreZoom {10736907 ps} {11313847 ps}
