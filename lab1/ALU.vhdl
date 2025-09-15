library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.RISCV_package.all;
use IEEE.numeric_std.all;

entity ALU is
    port (
        a, b: in std_logic_vector(XLEN-1 downto 0);
        alu_out: out std_logic_vector(XLEN-1 downto 0); --bit 0: 1 = right/sub: 0 = left/add, --bit 3 to 1: 000 = 
        func : in std_logic_vector(3 downto 0)
        );
end ALU;

architecture Behavioral of ALU is
    signal add_sub_out, shift_out, slt_unsigned_out, slt_signed_out, xor_out, or_out, and_out : std_logic_vector(XLEN-1 downto 0);
    signal post_b: std_logic_vector(XLEN-1 downto 0);
    signal shift_func : std_logic_vector (1 downto 0);
begin
    --add/subtract
    post_b <= b when func(0) = '0' else
              std_logic_vector(-signed(b));
    add_sub_out <= std_logic_vector(unsigned(a) + unsigned(post_b));
    
    --shift
    shift_func <= func(3) & func(0);
    shifter: entity work.generic_shifter (Behavioral)
    generic map (shamt_bits => XLEN_BITS)
    port map ( din => a, 
               dout => shift_out, 
               shamt => b(4 downto 0), 
               func => shift_func);
               --co =>
               
    --set less than
    slt_unsigned_out <= std_logic_vector(to_unsigned(1,XLEN)) when unsigned(a) < unsigned(b) else (others => '0');
    slt_signed_out <= std_logic_vector(to_unsigned(1,XLEN)) when signed(a) < signed(b) else (others => '0');
    
    --logicals
    xor_out <= a xor b;
    or_out <= a or b;
    and_out <= a and b;
               
               
    --out            
    with func(3 downto 1) select alu_out <=
        add_sub_out when "000",
        shift_out when "001"|"101",
        slt_signed_out when "010",
        slt_unsigned_out when "011",
        xor_out when "100",
        or_out when "110",
        and_out when others;
        
        
end Behavioral;
