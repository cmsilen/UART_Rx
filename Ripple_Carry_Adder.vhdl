library ieee;
use ieee.std_logic_1164.all;

entity Ripple_Carry_Adder is
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
end entity;

architecture default of Ripple_Carry_Adder is
    component Full_Adder
        port(
            af : in std_logic;
            bf : in std_logic;
            cinf : in std_logic;
            sf : out std_logic;
            coutf : out std_logic
        );
    end component;

    signal inner_cout : std_logic_vector(Nbit - 1 downto 1);
    
begin
    g_ADDER: for i in 0 to Nbit - 1 generate
        g_FIRST: if i = 0 generate
            i_ADDER: Full_Adder 
                port map(
                    af => a(i),
                    bf => b(i),
                    cinf => cin,
                    sf => s(i),
                    coutf => inner_cout(i + 1)
                );
        end generate;

        g_INTERNAL: if i > 0 and i < Nbit - 1 generate
            i_ADDER: Full_Adder 
                port map(
                    af => a(i),
                    bf => b(i),
                    cinf => inner_cout(i),
                    sf => s(i),
                    coutf => inner_cout(i + 1)
                );
        end generate;

        g_LAST: if i = Nbit - 1 generate
            i_ADDER: Full_Adder 
                port map(
                    af => a(i),
                    bf => b(i),
                    cinf => inner_cout(i),
                    sf => s(i),
                    coutf => cout
                );
        end generate;
    end generate;
end architecture;    
        