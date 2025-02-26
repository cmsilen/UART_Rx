library ieee;
use ieee.std_logic_1164.all;

-- Shift Register with one bit input and SR_DEPTH bits output

entity Shift_Register is
    generic(
        SR_DEPTH : positive := 8
    );
    port(
        x_sr : in std_logic;
        enable_sr : in std_logic;
        resetn_sr : in std_logic;
        clk_sr : in std_logic;
        y_sr : out std_logic_vector(SR_DEPTH - 1 downto 0)
    );
end entity;

architecture default of Shift_Register is
    component DFF
        generic(
            SIZE : positive := 1
        );
        port(
            d_dff : in std_logic_vector(SIZE - 1 downto 0);
            enable_dff : in std_logic;
            resetn_dff : in std_logic;
            clk_dff : in std_logic;
            q_dff : out std_logic_vector(SIZE - 1 downto 0)
        );
    end component;

    signal inner_q : std_logic_vector(SR_DEPTH downto 1);
begin
    for_gen: for i in 0 to SR_DEPTH - 1 generate
        first_gen: if i = 0 generate
            first_dff: DFF
                generic map(
                    SIZE => 1
                )
                port map(
                    d_dff(0) => x_sr,
                    enable_dff => enable_sr,
                    resetn_dff => resetn_sr,
                    clk_dff => clk_sr,
                    q_dff(0) => inner_q(1)
                );
        end generate;

        other_gen: if i > 0 generate
            other_dff: DFF
                generic map(
                    SIZE => 1
                )
                port map(
                    d_dff(0) => inner_q(i),
                    enable_dff => enable_sr,
                    resetn_dff => resetn_sr,
                    clk_dff => clk_sr,
                    q_dff(0) => inner_q(i + 1)
                );
        end generate;
    end generate;

    y_sr <= inner_q;
end architecture;