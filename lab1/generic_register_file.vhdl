library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.mi_package.all;


entity generic_register_file is
    generic( 
        word_len: integer := 32;
        addr_bits: integer := 5
        );
    port ( 
        clk, reset: in std_logic;
        write_en: in std_logic;
        d_addr: in std_logic_vector ( addr_bits-1 downto 0 );
        d_in: in std_logic_vector ( word_len-1 downto 0 );
        a_addr: in std_logic_vector ( addr_bits-1 downto 0 );
        a_out : out std_logic_vector ( word_len-1 downto 0 );
        b_addr: in std_logic_vector ( addr_bits-1 downto 0 ); 
        b_out : out std_logic_vector ( word_len-1 downto 0 )
        );
end generic_register_file;

architecture Behavioral of generic_register_file is
    type signal_array is array ( 2**addr_bits-1 downto 0 ) of std_logic_vector ( word_len-1 downto 0 );
    signal array_reg: signal_array;
    signal decoded : std_logic_vector ( 2**addr_bits-1 downto 0 );
begin
    decoded <= decode( d_addr, write_en );
    
    regs: for i in 1 to 2**addr_bits - 1 generate --only 2^addr_bits - 1 register (so 31 for 5 addrress) as x0 is going to be grounded
        regsi: entity work.generic_register ( Behavioral )
        generic map ( bits => word_len )
        port map ( clk => clk, reset => reset, enable => decoded(i), d => d_in, q => array_reg(i));  
    end generate regs;
    array_reg(0) <= ( others => '0'); --x0 = 0
    a_out <= array_reg ( to_integer( unsigned( a_addr )));
    b_out <= array_reg ( to_integer( unsigned( b_addr )));
end Behavioral; 
