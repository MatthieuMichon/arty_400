################################################################################
# Digilent Arty MII Pin Constraints
################################################################################

set_property -dict {PACKAGE_PIN D17} [get_ports eth_col]; #IO_L16N_T2_A27_15 Sch=eth_col
set_property -dict {PACKAGE_PIN G14} [get_ports eth_crs]; #IO_L15N_T2_DQS_ADV_B_15 Sch=eth_crs
set_property -dict {PACKAGE_PIN F16} [get_ports eth_mdc]; #IO_L14N_T2_SRCC_15 Sch=eth_mdc
set_property -dict {PACKAGE_PIN K13} [get_ports eth_mdio]; #IO_L17P_T2_A26_15 Sch=eth_mdio
set_property -dict {PACKAGE_PIN G18} [get_ports eth_ref_clk]; #IO_L22P_T3_A17_15 Sch=eth_ref_clk
set_property -dict {PACKAGE_PIN C16} [get_ports eth_rstn]; #IO_L20P_T3_A20_15 Sch=eth_rstn
set_property -dict {PACKAGE_PIN F15} [get_ports eth_rx_clk]; #IO_L14P_T2_SRCC_15 Sch=eth_rx_clk
set_property -dict {PACKAGE_PIN G16} [get_ports eth_rx_dv]; #IO_L13N_T2_MRCC_15 Sch=eth_rx_dv
set_property -dict {PACKAGE_PIN D18} [get_ports eth_rxd[0]]; #IO_L21N_T3_DQS_A18_15 Sch=eth_rxd[0]
set_property -dict {PACKAGE_PIN E17} [get_ports eth_rxd[1]]; #IO_L16P_T2_A28_15 Sch=eth_rxd[1]
set_property -dict {PACKAGE_PIN E18} [get_ports eth_rxd[2]]; #IO_L21P_T3_DQS_15 Sch=eth_rxd[2]
set_property -dict {PACKAGE_PIN G17} [get_ports eth_rxd[3]]; #IO_L18N_T2_A23_15 Sch=eth_rxd[3]
set_property -dict {PACKAGE_PIN C17} [get_ports eth_rxerr]; #IO_L20N_T3_A19_15 Sch=eth_rxerr
set_property -dict {PACKAGE_PIN H16} [get_ports eth_tx_clk]; #IO_L13P_T2_MRCC_15 Sch=eth_tx_clk
set_property -dict {PACKAGE_PIN H15} [get_ports eth_tx_en]; #IO_L19N_T3_A21_VREF_15 Sch=eth_tx_en
set_property -dict {PACKAGE_PIN H14} [get_ports eth_txd[0]]; #IO_L15P_T2_DQS_15 Sch=eth_txd[0]
set_property -dict {PACKAGE_PIN J14} [get_ports eth_txd[1]]; #IO_L19P_T3_A22_15 Sch=eth_txd[1]
set_property -dict {PACKAGE_PIN J13} [get_ports eth_txd[2]]; #IO_L17N_T2_A25_15 Sch=eth_txd[2]
set_property -dict {PACKAGE_PIN H17} [get_ports eth_txd[3]]; #IO_L18P_T2_A24_15 Sch=eth_txd[3]

################################################################################
# MII Pin IO Constraints

create_clock -period 40 [get_ports eth_rx_clk];

set_input_delay -min 10 -clock [get_clocks eth_rx_clk] [get_ports eth_rxd];
set_input_delay -min 10 -clock [get_clocks eth_rx_clk] [get_ports eth_rx_dv];
set_input_delay -max 30 -clock [get_clocks eth_rx_clk] [get_ports eth_rxd];
set_input_delay -max 30 -clock [get_clocks eth_rx_clk] [get_ports eth_rx_dv];

create_clock -period 40 [get_ports eth_tx_clk];

set_output_delay -min 10 -clock [get_clocks eth_tx_clk] [get_ports eth_txd];
set_output_delay -min 10 -clock [get_clocks eth_tx_clk] [get_ports eth_tx_dv];
set_output_delay -max 30 -clock [get_clocks eth_tx_clk] [get_ports eth_txd];
set_output_delay -max 30 -clock [get_clocks eth_tx_clk] [get_ports eth_tx_dv];
