################################################################################
# Digilent Arty Board Gloval Constraints
################################################################################

################################################################################
# Configuration Bank Voltage

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

################################################################################
# Set IO Standard to all pins

set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 14]];
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 15]];
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 16]];
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]];

################################################################################
# Thermal Configuration

set_operating_conditions -airflow 0 -heatsink none
