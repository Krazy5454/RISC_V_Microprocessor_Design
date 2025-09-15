
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity generic_counter is
    generic ( bits : integer := 4 );
    Port ( clk, reset, latch, enable : in STD_LOGIC;
           d : in std_logic_vector ( bits-1 downto 0);
           q : out STD_LOGIC_VECTOR ( bits-1 downto 0 ));
end generic_counter;

architecture Behavioral of generic_counter is
    signal current_count : std_logic_vector ( bits-1 downto 0 ) := ( others => '0' );
    signal next_count : std_logic_vector ( bits-1 downto 0 ) := ( others => '0' );
    signal ctrl : std_logic_vector ( 2 downto 0 );
begin
    --declare memory
    current_count <= next_count when rising_edge( clk );
    --next state logic
    ctrl <= reset & latch & enable;
    with ctrl select next_count <=
        current_count when "000",
        std_logic_vector ( unsigned ( current_count ) + 1 ) when "001",
        d when "010"|"011",
        (others => '0') when others;

    --output logic
    q <= current_count;

end Behavioral;
