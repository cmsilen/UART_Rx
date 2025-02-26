library ieee;
use ieee.std_logic_1164.all;

entity Full_Adder is
    port(
        af : in std_logic;
        bf : in std_logic;
        cinf : in std_logic;
        sf : out std_logic;
        coutf : out std_logic
    );
end entity;

architecture structural of Full_Adder is
begin
    sf <= af xor bf xor cinf;
    coutf <= (af and bf) or (af and cinf) or (bf and cinf);
end architecture;