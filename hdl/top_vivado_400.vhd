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
--------------------------------------------------------------------------------
entity top_vivado_400 is
    generic (
        ILA_C_PROBE0_WIDTH: natural := 0);
    port (
        -- Oscillator
        gclk100: in std_ulogic;
        -- Reset Push Button
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

    mmcme2_base_mii_ref_clk: mmcme2_base
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

    g_ila: if ILA_C_PROBE0_WIDTH /= 0 generate
        signal ila_probe0: std_ulogic_vector(ILA_C_PROBE0_WIDTH-1 downto 0);
    begin
        ila_probe0 <= (
            0 => ck_rst,
            1 => pll_lock,
            2 => pll_rst,

            others => '0');

        i_ila: ila port map (
            clk => clk200,
            probe0 => ila_probe0);
    end generate;
end block;

end architecture;

