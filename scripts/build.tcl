package require cmdline

set usage "Vivado project build script"
set parameters {
    {write-dcp "Write checkpoints at each stage, default=off"}
}

array set options [cmdline::getoptions ::argv $parameters $usage]
parray options

# ------------------------------------------------------------------------------
# Change Work Directory
# ------------------------------------------------------------------------------

set work_directory "build"
file mkdir $work_directory
cd $work_directory

# ------------------------------------------------------------------------------
# Import Source Files
# ------------------------------------------------------------------------------

# Constraints

set xdc_dir [file normalize "../sdc"]
set xdc_files [list \
	[file normalize $xdc_dir/arty_ess.xdc] \
	[file normalize $xdc_dir/arty_mii.xdc] \
	[file normalize $xdc_dir/arty_board.xdc] \
]
read_xdc $xdc_files

# HDL Files

set hdl_dir [file normalize "../hdl"]
set vhd_files [list \
	[file normalize $hdl_dir/top_vivado_400.vhd] \
]
read_vhdl -vhdl2008 $vhd_files

# ------------------------------------------------------------------------------
# Create Vendor IPs
# ------------------------------------------------------------------------------

# Target part is required at this point

set_property part xc7a35ticsg324-1L [current_project]

# create_ip -name vio -vendor xilinx.com -library ip -module_name vio
# set_property -dict [list \
# 	CONFIG.C_PROBE_IN0_WIDTH {36} \
# 	CONFIG.C_PROBE_OUT0_WIDTH {36} \
# 	CONFIG.C_NUM_PROBE_IN {1} \
# 	CONFIG.C_NUM_PROBE_OUT {1} \
# ] [get_ips vio]
# synth_ip [get_ips vio]

set ILA_C_PROBE0_WIDTH 36

create_ip -name ila -vendor xilinx.com -library ip -module_name ila
set_property -dict [list \
	CONFIG.C_PROBE0_WIDTH  $ILA_C_PROBE0_WIDTH \
	CONFIG.C_DATA_DEPTH 1024 \
	CONFIG.C_NUM_OF_PROBES 1 \
] [get_ips ila]
synth_ip [get_ips ila]

# ------------------------------------------------------------------------------
# Synthesize
# ------------------------------------------------------------------------------

synth_design \
	-top [lindex [find_top] 0] \
	-flatten_hierarchy none \
	-verbose\
	-generic ILA_C_PROBE0_WIDTH=$ILA_C_PROBE0_WIDTH
#write_checkpoint -force synth_design.dcp
report_timing_summary -file synth_design_timing_summary.rpt

# ------------------------------------------------------------------------------
# Optimize
# ------------------------------------------------------------------------------

opt_design -directive ExploreWithRemap -verbose
#write_checkpoint -force opt_design.dcp
report_timing_summary -file opt_design_timing_summary.rpt

# ------------------------------------------------------------------------------
# Place
# ------------------------------------------------------------------------------

place_design -directive ExtraNetDelay_high
#write_checkpoint -force place_design.dcp
report_timing_summary -file place_design_timing_summary.rpt

# ------------------------------------------------------------------------------
# Post-Place Optimize
# ------------------------------------------------------------------------------

phys_opt_design -directive AggressiveFanoutOpt
#write_checkpoint -force post_place_opt_design.dcp
report_timing_summary -file post_place_opt_design_timing_summary.rpt

# ------------------------------------------------------------------------------
# Route
# ------------------------------------------------------------------------------

route_design -directive AggressiveExplore
#write_checkpoint -force route_design.dcp
#report_timing_summary -file route_design_timing_summary.rpt

# ------------------------------------------------------------------------------
# Port-Route Optimize
# ------------------------------------------------------------------------------

#phys_opt_design
write_checkpoint -force post_route_opt_design.dcp
report_timing_summary -file post_route_opt_design_timing_summary.rpt

# ------------------------------------------------------------------------------
# Generate Bitstream
# ------------------------------------------------------------------------------

write_bitstream -force -file bitstream.bit
write_debug_probes -force -file vio_probe.ltx
