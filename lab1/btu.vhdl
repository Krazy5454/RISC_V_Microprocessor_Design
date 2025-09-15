library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.RISCV_package.all;


entity btu is
    Port ( a : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
           b : in STD_LOGIC_VECTOR (XLEN-1 downto 0);
           cond : in STD_LOGIC_VECTOR (2 downto 0); -- bit 2: 1 = less then: 0 = eq, bit 1: 1 = signed: 2 = signed, bit 0: 1 = invert result  
           enable : in STD_LOGIC;
           BTU_out : out STD_LOGIC);
end btu;

architecture Behavioral of btu is
    signal pre_out, equal, lt, slt : std_logic;
begin
    equal <= '1' when a = b else '0';
    lt <= '1' when unsigned(a) <  unsigned(b) else '0';
    slt <= '1' when signed(a) < signed(b) else '0'; 
    
    with cond(2 downto 1) select pre_out <=
        slt when "10",
        lt when "11",
        equal when others;
    
    BTU_out <= (pre_out xor cond(0)) and enable;

end Behavioral;
