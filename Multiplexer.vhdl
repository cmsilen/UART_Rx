library ieee;
use ieee.std_logic_1164.all;

-- Multiplexer with 2 inputs of MU_SIZE bits:
-- sel_de = 0 ---> y_de = x0_de
-- sel_de = 1 ---> y_de = x1_de

entity Multiplexer is
    generic(
        MU_SIZE : positive := 8
    );
    port(
        x0_mu : in std_logic_vector(MU_SIZE - 1 downto 0);
        x1_mu : in std_logic_vector(MU_SIZE - 1 downto 0);
        sel_mu : in std_logic;
        y_mu : out std_logic_vector(MU_SIZE - 1 downto 0)
    );
end entity;

architecture default of Multiplexer is
begin
    p_mul: process(x0_mu, x1_mu, sel_mu)
    begin
        if sel_mu = '0' then
            y_mu <= x0_mu;
        else
            y_mu <= x1_mu;
        end if;
    end process;
end architecture;