# ------------------------------------------------------------------------------
# Change Work Directory
# ------------------------------------------------------------------------------

set work_directory "build"
file mkdir $work_directory
cd $work_directory

# ------------------------------------------------------------------------------

open_hw
connect_hw_server
open_hw_target

set_property PROGRAM.FILE bitstream.bit [lindex [get_hw_devices] 0]
program_hw_devices [lindex [get_hw_devices] 0]
