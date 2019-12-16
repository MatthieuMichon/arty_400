library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mii_mdio_types is
    subtype t_register_address is std_ulogic_vector(4 downto 0);
    subtype t_phy_address is unsigned(4 downto 0);
    subtype t_data is std_ulogic_vector(15 downto 0);
function reverse_vector(vec : in std_ulogic_vector) return std_ulogic_vector;

    constant DEFAULT_POLL_WAIT_TICKS : natural := 10000000;
end package;

package body mii_mdio_types is
    function reverse_vector(vec : in std_ulogic_vector) return std_ulogic_vector is
        variable result : std_ulogic_vector(vec'range);
        alias rev_vec   : std_ulogic_vector(vec'reverse_range) is vec;
    begin
        for i in rev_vec'range loop
            result(i) := rev_vec(i);
        end loop;
        return result;
    end function;
end package body;

library ieee;
use ieee.std_logic_1164.all;

use work.mii_mdio_types.all;
--use work.utility.all;

-- MII Management Interface compliant to IEEE 802.3 clause 22
entity mii_mdio is
    generic(
        -- Resulting clock frequency fclock / clock_divider has to be below 2.5 MHz for IEEE conformance
        -- Use only even numbers for 50% duty cycle of MDC
        CLOCK_DIVIDER : integer range 8 to 1000 := 50
    );
    port(
        -- Synchronous active-high reset
        rst            : in    std_ulogic;
        clk            : in    std_ulogic;

        -- Transaction data
        reg_addr : in    t_register_address;
        phy_addr      : in    t_phy_address := (others => '0');
        -- Output data read from the PHY when wr_rd was low when the transaction was started
        read_data        : out   t_data;
        -- Input data to write to the PHY when wr_rd is high when the transaction starts
        write_data       : in    t_data;
        -- Request transaction
        -- Must stay asserted until the transaction has completed
        request              : in    std_ulogic;
        -- Transaction has completed
        -- Deasserted after the user deasserts request
        done              : out   std_ulogic;
        -- Transaction direction:
        --  Low: read register from PHY
        -- High: write register to PHY
        wr_rd            : in    std_ulogic;

        -- mii_mdio interface: connect to top-level pins
        mdc_o              : out   std_ulogic;
        mdio_io            : inout std_ulogic
    );
end entity;

architecture rtl of mii_mdio is
    type t_mii_mdio_txrx_state is (
        IDLE,
        TX_COMMAND,
        RX_TURNAROUND_Z,
        RX_TURNAROUND_Z_READLOW,
        RX_DATA,
        TX_TURNAROUND_HIGH,
        TX_TURNAROUND_LOW,
        TX_DATA,
        COMPLETED
    );

    signal state : t_mii_mdio_txrx_state := IDLE;

    -- Operation type as defined by the standard
    subtype t_operation_type is std_ulogic_vector(1 downto 0);

    constant PREAMBLE_LENGTH : natural                       := 32;
    -- The frame format as described in IEEE 802.3 clause 22.2.4.5 is LSB first, so the constants appear reversed here
    constant START_OF_FRAME  : std_ulogic_vector(1 downto 0) := "10";
    constant OPERATION_READ  : t_operation_type              := "01";
    constant OPERATION_WRITE : t_operation_type              := "10";
    -- Total length of a command on the interface
    constant COMMAND_LENGTH  : natural                       := PREAMBLE_LENGTH + START_OF_FRAME'length + t_operation_type'length + t_phy_address'length + t_register_address'length;

    signal operation_code       : t_operation_type;
    -- Complete prebuffered command to send out
    signal command              : std_ulogic_vector(COMMAND_LENGTH - 1 downto 0);
    -- Number of the command bit currently being sent
    signal command_bit_position : integer range 0 to COMMAND_LENGTH;
    -- Number of the data bit currently being sent
    signal data_bit_position    : integer range 0 to t_data'length;

    signal clock_divide_counter : integer range 0 to CLOCK_DIVIDER;

-- Bit order:
--  PHYAD/REGAD/DATA: MSB first

begin

    -- Disable clock when idle, apply division otherwise
    mdc_o <= '1' when ((state /= IDLE) and (state /= COMPLETED) and clock_divide_counter >= (CLOCK_DIVIDER / 2)) else '0';

    with wr_rd select operation_code <=
        OPERATION_WRITE when '1',
        OPERATION_READ when others;

    -- Build command data array
    command(PREAMBLE_LENGTH - 1 downto 0)           <= (others => '1');
    command(command'high(1) downto PREAMBLE_LENGTH) <= reverse_vector(std_ulogic_vector(reg_addr)) & reverse_vector(std_ulogic_vector(phy_addr)) & operation_code & START_OF_FRAME;

    output : process(state, command_bit_position, data_bit_position, command, write_data) is
    begin
        done   <= '0';
        mdio_io <= 'Z';
        case state is
            when IDLE =>
                null;
            when TX_COMMAND =>
                mdio_io <= command(command_bit_position);
            when RX_TURNAROUND_Z =>
                null;
            when RX_TURNAROUND_Z_READLOW =>
                null;
            when RX_DATA =>
                null;
            when TX_TURNAROUND_HIGH =>
                mdio_io <= '1';
            when TX_TURNAROUND_LOW =>
                mdio_io <= '0';
            when TX_DATA =>
                mdio_io <= write_data(data_bit_position);
            when COMPLETED =>
                done <= '1';
        end case;
    end process;

    rx : process(clk) is
    begin
        -- Synchronize to rising as in the FSM process
        if rising_edge(clk) then
            -- and read just before rising (divided) MDC edge
            -- / 2 - 1
            if state = RX_DATA and (clock_divide_counter = (CLOCK_DIVIDER / 4)) then
                read_data(data_bit_position) <= mdio_io;
            end if;
        end if;
    end process;

    fsm : process(clk) is
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state                <= IDLE;
                clock_divide_counter <= 0;
            else
                if clock_divide_counter = CLOCK_DIVIDER - 1 then
                    clock_divide_counter <= 0;
                else
                    clock_divide_counter <= clock_divide_counter + 1;
                end if;

                -- Run the FSM on the falling divided MDC edge
                if (clock_divide_counter = 0) then
                    case state is
                        when IDLE =>
                            command_bit_position <= 0;
                            -- start at MSB
                            data_bit_position    <= t_data'length - 1;

                            if request = '1' then
                                state <= TX_COMMAND;
                            end if;

                        when TX_COMMAND =>
                            command_bit_position <= command_bit_position + 1;
                            if command_bit_position = COMMAND_LENGTH - 1 then
                                if wr_rd = '0' then
                                    state <= RX_TURNAROUND_Z;
                                else
                                    state <= TX_TURNAROUND_HIGH;
                                end if;
                            end if;

                        when RX_TURNAROUND_Z =>
                            state <= RX_TURNAROUND_Z_READLOW;
                        when RX_TURNAROUND_Z_READLOW =>
                            state <= RX_DATA;
                        when TX_TURNAROUND_HIGH =>
                            state <= TX_TURNAROUND_LOW;
                        when TX_TURNAROUND_LOW =>
                            state <= TX_DATA;

                        when RX_DATA | TX_DATA =>
                            if data_bit_position = 0 then
                                state <= COMPLETED;
                            else
                                data_bit_position <= data_bit_position - 1;
                            end if;

                        when COMPLETED =>
                            if request = '0' then
                                state <= IDLE;
                            end if;
                    end case;
                end if;
            end if;
        end if;
    end process;

end architecture;
