/* VHDL-2008 */

--------------------------------------------------------------------------------
-- | |_ ___ _ __
-- |  _/ _ \ '_ \
--  \__\___/ .__/
--         |_|
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--------------------------------------------------------------------------------
entity top_vivado_400_tb is end entity;
--------------------------------------------------------------------------------
architecture a_top_vivado_400_tb of top_vivado_400_tb is
    constant MII_DATA_WIDTH: positive := 4;
    subtype t_eth_data is std_ulogic_vector(MII_DATA_WIDTH-1 downto 0);

    signal gclk100: std_ulogic := '0';
    signal ck_rst: std_ulogic := '1';
    signal eth_col: std_ulogic;
    signal eth_crs: std_ulogic;
    signal eth_mdc: std_ulogic;
    signal eth_mdio: std_ulogic;
    signal eth_ref_clk: std_ulogic;
    signal eth_rstn: std_ulogic;
    signal eth_rx_clk: std_ulogic;
    signal eth_rx_dv: std_ulogic;
    signal eth_rxd: t_eth_data;
    signal eth_rxerr: std_ulogic;
    signal eth_tx_clk: std_ulogic;
    signal eth_tx_en: std_ulogic;
    signal eth_txd: t_eth_data;
begin

b_phy: block is
begin
    eth_tx_clk <= eth_ref_clk after 2.5 ns; -- T2.27.1
    eth_rx_clk <= eth_ref_clk after 6.5 ns; -- dummy delay
    eth_rx_dv <= '0';
    eth_rxd <= (others=>'0');
end block;

i_top_vivado_400: entity work.top_vivado_400 generic map (
    MII_DATA_WIDTH => MII_DATA_WIDTH
) port map (
    eth_col => eth_col,
    eth_crs => eth_crs,
    eth_mdc => eth_mdc,
    eth_mdio => eth_mdio,
    eth_ref_clk => eth_ref_clk,
    eth_rstn => eth_rstn,
    eth_rx_clk => eth_rx_clk,
    eth_rx_dv => eth_rx_dv,
    eth_rxd => eth_rxd,
    eth_rxerr => eth_rxerr,
    eth_tx_clk => eth_tx_clk,
    eth_tx_en => eth_tx_en,
    eth_txd => eth_txd,
    -- Essential Ports
    gclk100 => gclk100,
    ck_rst => ck_rst);

b_osc_asem1_100mhz: block is
    constant OSC_FREQ_MHZ: real := 100.0;
    constant OSC_PERIOD: time := 1 us / OSC_FREQ_MHZ;
begin
    gclk100 <= not gclk100 after OSC_PERIOD / 2;
    process is begin wait for 100 us; report "stop" severity failure; wait; end process;
end block;
end architecture;
