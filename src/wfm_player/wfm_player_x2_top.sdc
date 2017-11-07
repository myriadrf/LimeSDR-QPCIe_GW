# ----------------------------------------------------------------------------
# FILE         : 	wfm_player_x2_top.sdc
# DESCRIPTION  :	Constrains file for wfm_player_x2_top.vhd file
# DATE         :	9:24 AM Tuesday, November 7, 2017
# AUTHOR(s)    :	Lime Microsystems
# REVISIONS    :
# ----------------------------------------------------------------------------
# NOTES:
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# Exceptions
# ----------------------------------------------------------------------------

# to avoid recovery failures for fifo asynchronous clear. There should be more 
# than one cycle from aclr to wrreq so it safe to ignore this path
set_false_path -from {edge_pulse:edge_pulse2|sig_in_risign} -to {*}
set_false_path -from {edge_pulse:edge_pulse3|sig_in_risign} -to {*}