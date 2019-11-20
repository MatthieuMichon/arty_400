################################################################################
# Digilent Arty A7 - Essential Pins Constraints
################################################################################

################################################################################
# 100 MHz Clock Input

set_property package_pin e3 [get_ports gclk100]; #IO_L12P_T1_MRCC_35 Sch=gclk100

################################################################################
# Clock Oscillator reference: ASEM1-100.000MHZ-LC-T

create_clock -period 10 [get_ports gclk100];
set_input_jitter gclk100 0.050;

################################################################################
# Reset Push Buton (pressed: '0', released: '1')

set_property package_pin c2 [get_ports ck_rst]; #IO_L16P_T2_35 Sch=ck_rst
set_input_delay -clock gclk100 -min 1.0 -max 5.0 [get_ports ck_rst];
set_false_path -from [get_ports ck_rst];
