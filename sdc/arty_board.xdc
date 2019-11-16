################################################################################
# Digilent Arty Board Gloval Constraints
################################################################################

################################################################################
# Configuration Bank Voltage

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

################################################################################
# Set IO Standard to all pins

set_property IOSTANDARD LVCMOS33 [get_ports -filter { LOC =~ IOB_* } ]

################################################################################
# Thermal Configuration

set_operating_conditions -airflow 0 -heatsink none
