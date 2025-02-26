library ieee;
use ieee.std_logic_1164.all;

-- modified accumulator with to operational modes:
-- mode_acc = 0 ---> accumulator operation (sum of d_acc and value held in memory)
-- mode_acc = 1 ---> memory operation (d_acc is held in memory)

entity Accumulator is
    generic(
        ACC_SIZE : positive := 8                                -- amount of bits for input and output
    );
    port(
        d_acc : in std_logic_vector(ACC_SIZE - 1 downto 0);     -- data input
        cin_acc : in std_logic;                                 -- cin of adder
        mode_acc : in std_logic;                                -- operational mode
        enable_acc : in std_logic;
        resetn_acc : in std_logic;
        clk_acc : in std_logic;
        out_acc : out std_logic_vector(ACC_SIZE - 1 downto 0)   -- data output
    );
end entity;

architecture default of Accumulator is
    component Ripple_Carry_Adder
        generic(
            Nbit : positive := 8
        );
        port (
            a : in std_logic_vector(Nbit - 1 downto 0);
            b : in std_logic_vector(Nbit - 1 downto 0);
            cin : in std_logic;
            s : out std_logic_vector(Nbit - 1 downto 0);
            cout : out std_logic
        );
    end component;

    component Multiplexer
        generic(
            MU_SIZE : positive := 8
        );
        port(
            x0_mu : in std_logic_vector(MU_SIZE - 1 downto 0);
            x1_mu : in std_logic_vector(MU_SIZE - 1 downto 0);
            sel_mu : in std_logic;
            y_mu : out std_logic_vector(MU_SIZE - 1 downto 0)
        );
    end component;

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

    signal inner_s : std_logic_vector(ACC_SIZE - 1 downto 0);
    signal inner_y : std_logic_vector(ACC_SIZE - 1 downto 0);
    signal inner_q : std_logic_vector(ACC_SIZE - 1 downto 0);

begin
    -- adder for accumulator operation
    g_RCA: Ripple_Carry_Adder
        generic map(
            Nbit => ACC_SIZE
        )
        port map(
            a => d_acc,
            b => inner_q,
            cin => cin_acc,
            s => inner_s
        );

    -- for redirecting the output of the adder or the data input to the inner DFF
    g_Mul: Multiplexer
        generic map(
            MU_SIZE => ACC_SIZE
        )
        port map(
            x0_mu => inner_s,
            x1_mu => d_acc,
            sel_mu => mode_acc,
            y_mu => inner_y
        );

    -- inner DFF for storing the current data
    g_DFF: DFF
        generic map(
            SIZE => ACC_SIZE
        )
        port map(
            d_dff => inner_y,
            enable_dff => enable_acc,
            resetn_dff => resetn_acc,
            clk_dff => clk_acc,
            q_dff => inner_q
        );

    out_acc <= inner_q;
end architecture;