################################################################################
# Digilent Arty UART Pin Constraints
################################################################################

set_property PACKAGE_PIN D10 [get_ports uart_rxd_out]; #IO_L19N_T3_VREF_16 Sch=uart_rxd_out
set_property PACKAGE_PIN A9 [get_ports uart_txd_in]; #IO_L14N_T2_SRCC_16 Sch=uart_txd_in

################################################################################
# UART Pin IO Constraints

set_output_delay -clock gclk100 -min 1.0 -max 5.0 [get_ports uart_rxd_out];
set_false_path -to [get_ports uart_rxd_out];
set_input_delay -clock gclk100 -min 1.0 -max 5.0 [get_ports uart_txd_in];
set_false_path -from [get_ports uart_txd_in];
