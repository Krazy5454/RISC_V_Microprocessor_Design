library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity generic_register is
    generic (bits: integer := 4);
    port(
        clk, reset,enable: in std_logic;
        d: in std_logic_vector ( bits-1 downto 0 );
        q: out std_logic_vector ( bits-1 downto 0 )
        );
end generic_register; 

architecture Behavioral of generic_register is
    signal q_i, next_q_i : std_logic_vector ( bits-1 downto 0 );
    signal ctrl : std_logic_vector ( 1 downto 0 );
begin
    q_i <= next_q_i when rising_edge(clk);
    next_q_i <= (others => '0' ) when reset ='1' else d when enable = '1' else q_i;
    q <= q_i;
end Behavioral;
