/* VHDL-2008 */

--------------------------------------------------------------------------------
-- | |_ ___ _ __
-- |  _/ _ \ '_ \
--  \__\___/ .__/
--         |_|
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;
library secureip;
--------------------------------------------------------------------------------
entity top_vivado_400 is
    generic (
        ILA_C_PROBE0_WIDTH: natural := 0;
        MII_DATA_WIDTH: positive := 4);
    port (
        -- MII
        eth_col: in std_ulogic;
        eth_crs: in std_ulogic;
        eth_mdc: out std_ulogic;
        eth_mdio: inout std_ulogic;
        eth_ref_clk: out std_ulogic;
        eth_rstn: out std_ulogic;
        eth_rx_clk: in std_ulogic;
        eth_rx_dv: in std_ulogic;
        eth_rxd: in std_ulogic_vector(MII_DATA_WIDTH-1 downto 0);
        eth_rxerr: in std_ulogic;
        eth_tx_clk: in std_ulogic;
        eth_tx_en: out std_ulogic;
        eth_txd: out std_ulogic_vector(MII_DATA_WIDTH-1 downto 0);
        -- Essential Ports
        gclk100: in std_ulogic;
        ck_rst: in std_ulogic -- '1': released
    );
end entity;
--------------------------------------------------------------------------------
architecture a_top_vivado_400 of top_vivado_400 is
    signal clk100: std_ulogic;
    signal clk200: std_ulogic;
    signal clk300: std_ulogic;
    signal clk400: std_ulogic;
begin
b_clocking: block is
    signal pll_fb: std_ulogic;
    signal pll_rst: std_ulogic;
    signal pll_lock: std_ulogic;
    signal pll_clk: std_ulogic_vector(3-1 downto 0);
    signal clk: std_ulogic_vector(3-1 downto 0);
begin
    i_bufg_clk100: bufg port map (
        i => gclk100,
        o => clk100);

    pll_rst <= not ck_rst when rising_edge(clk100);

    i_mmcme2_base_internal_clk: mmcme2_base
        generic map (
            CLKIN1_PERIOD => 10.0,
            CLKFBOUT_MULT_F => 12.0, -- 2..64
            CLKOUT0_DIVIDE_F => 3.0, -- 1.000; 2.000 to 128.000
            CLKOUT1_DIVIDE => 4, -- 1..128
            CLKOUT2_DIVIDE => 6 -- 1..128
        )
        port map (
            clkin1 => clk100,
            clkfbin => pll_fb,
            clkfbout => pll_fb,
            clkout0 => pll_clk(0),
            clkout1 => pll_clk(1),
            clkout2 => pll_clk(2),
            locked => pll_lock,
            rst => pll_rst,
            pwrdwn => '0');

    g_all_pll_clkout: for i in pll_clk'range generate
        i_bufg_pll_clkout: bufg port map (
                i => pll_clk(i),
                o => clk(i));
    end generate;

    clk400 <= clk(0);
    clk300 <= clk(1);
    clk200 <= clk(2);
end block;

b_mii: block is
    signal bufg_eth_rx_clk: std_ulogic;
    signal bufg_eth_tx_clk: std_ulogic;
    signal pll_rst: std_ulogic;
    signal pll_fb: std_ulogic;
    signal mii_ref_clk: std_ulogic;
    signal bufg_mii_ref_clk: std_ulogic;

    signal deser_mii_rx_dv: std_ulogic_vector(8-1 downto 0);
begin
    pll_rst <= not ck_rst when rising_edge(clk100);

    i_mmcme2_base_mii_ref_clk: mmcme2_base
        generic map (
            CLKIN1_PERIOD => 10.0,
            CLKFBOUT_MULT_F => real(1.0 * 1200 / 100), -- 2..64
            CLKOUT0_DIVIDE_F => real(1.0 * 1200 / 25), -- 1.000; 2.000 to 128.000
            CLKOUT1_DIVIDE => 1200 / 200) -- 1..128
        port map (
            clkin1 => clk100,
            clkfbin => pll_fb,
            clkfbout => pll_fb,
            clkout0 => mii_ref_clk,
            clkout1 => open,
            locked => open,
            rst => pll_rst,
            pwrdwn => '0');

    i_bufg_eth_ref_clk: bufg port map (
        i => mii_ref_clk,
        o => bufg_mii_ref_clk);

    i_oddr_eth_ref_clk: oddr port map (
        C => bufg_mii_ref_clk,
        CE => '1',
        D1 => '1',
        D2 => '0',
        Q => eth_ref_clk);

    eth_rstn <= '1';
    eth_mdc <= 'Z';
    eth_mdio <= 'Z';
    eth_tx_en <= '0';
    eth_txd <= (others=>'0');

    i_iserdes_eth_rxd_0: iserdes generic map (
        DATA_RATE => "SDR",
        DATA_WIDTH => deser_mii_rx_dv'length,
        INTERFACE_TYPE => "NETWORKING"
    ) port map (
        O => open,
        Q1 => deser_mii_rx_dv(0),
        Q2 => deser_mii_rx_dv(1),
        Q3 => deser_mii_rx_dv(2),
        Q4 => deser_mii_rx_dv(3),
        SHIFTOUT1 => open,
        SHIFTOUT2 => open,
        BITSLIP => '0',
        CE1 => '1',
        CE2 => '1',
        CLK => clk200,
        CLKDIV => bufg_mii_ref_clk,
        D => eth_rxd(0),
        OCLK => '0',
        SHIFTIN1 => '0',
        DLYCE => '0',
        DLYINC => '0',
        DLYRST => '0',
        REV => '0',
        SR => '0',
        SHIFTIN2 => '0');

    --i_bufg_eth_rx_clk: bufg port map (
    --    i => eth_rx_clk,
    --    o => bufg_eth_rx_clk);

    --i_bufg_eth_tx_clk: bufg port map (
    --    i => eth_tx_clk,
    --    o => bufg_eth_tx_clk);

    --i_mmcme2_base_mii_eth_rx_clk: mmcme2_base
    --    generic map (
    --        CLKIN1_PERIOD => MII_FOUR_BIT_CLK_PERIOD,
    --        CLKFBOUT_MULT_F => 32, -- 2..64
    --        CLKOUT0_DIVIDE_F => 3.0, -- 1.000; 2.000 to 128.000
    --        CLKOUT1_DIVIDE => 4, -- 1..128
    --        CLKOUT2_DIVIDE => 6 -- 1..128
    --    )
    --    port map (
    --        clkin1 => bufg_eth_rx_clk,
    --        clkfbin => pll_fb, -- 800 MHz
    --        clkfbout => pll_fb,
    --        clkout0 => pll_clk(0),
    --        clkout1 => pll_clk(1),
    --        clkout2 => pll_clk(2),
    --        locked => pll_lock,
    --        rst => pll_rst,
    --        pwrdwn => '0');

end block;

    --g_ila: if ILA_C_PROBE0_WIDTH /= 0 generate
    --    signal ila_probe0: std_ulogic_vector(ILA_C_PROBE0_WIDTH-1 downto 0);
    --begin
    --    ila_probe0 <= (
    --        0 => ck_rst,
    --        1 => pll_lock,
    --        2 => pll_rst,
    --        3 => eth_rx_clk,
    --        4 => eth_tx_clk,

    --        others => '0');

    --    i_ila: ila port map (
    --        clk => clk200,
    --        probe0 => ila_probe0);
    --end generate;

end architecture;

