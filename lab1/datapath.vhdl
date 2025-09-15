library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.RISCV_package.all;

entity datapath is
    port (
        clk, reset: in std_logic;
        control_word: in control_word
        );
end datapath;

architecture Behavioral of datapath is
    signal d_bus, a_pre_bus, b_pre_bus, a_bus, b_bus, pc, alu_out : std_logic_vector(XLEN-1 downto 0);
    signal BTU_out, pc_latch : std_logic;

begin

    Regs: entity work.generic_register_file (Behavioral)
    generic map (word_len => XLEN, addr_bits => REGS_ADDR_BITS)
    port map ( clk => clk, reset => reset,
               write_en => control_word.Dlen,
               d_addr =>control_word.Dsel,
               d_in => d_bus,
               a_addr => control_word.Asel,
               a_out => a_pre_bus,
               b_addr => control_word.Bsel,
               b_out => b_pre_bus);
               
    ALU: entity work.ALU (Behavioral) 
    port map ( a => a_bus, b => b_bus, alu_out => alu_out, func => control_word.ALUfunc );
    
    Program_Counter: entity work.generic_counter (Behavioral)
    generic map ( bits => XLEN - 2)
    port map (clk => clk, reset => reset, latch => pc_latch, enable => control_word.PCie, d => alu_out(31 downto 2), q => pc(31 downto 2));
    pc(1 downto 0) <= "00"; --hard set last 2 bits of pc to 00
    
    BTU : entity work.BTU (Behavioral)
    port map ( a => a_pre_bus, b => b_pre_bus, cond => control_word.BRcond, enable => control_word.isBR, BTU_out => BTU_out);
    
    
    

    a_bus <= pc when control_word.PCAsel = '1' else
             a_pre_bus;
    b_bus <= control_word.IMM when control_word.IMMBsel = '1' else
             b_pre_bus;
    d_bus <= pc when control_word.PCDsel = '1' else
             alu_out; 
    pc_latch <= control_word.PCle or BTU_out; --might not needed. BTU_out might just be PCle
        
end Behavioral;
