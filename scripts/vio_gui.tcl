# ------------------------------------------------------------------------------
# Change Work Directory
# ------------------------------------------------------------------------------

set work_directory "build"
file mkdir $work_directory
cd $work_directory

start_gui
open_hw
connect_hw_server
open_hw_target
current_hw_device [lindex [get_hw_devices] 0]
set_property PROBES.FILE vio_probe.ltx [lindex [get_hw_devices] 0]
set_property FULL_PROBES.FILE vio_probe.ltx [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE {bitstream.bit} [lindex [get_hw_devices] 0]
#program_hw_devices [lindex [get_hw_devices] 0]
refresh_hw_device [lindex [get_hw_devices xc7a35t_0] 0]