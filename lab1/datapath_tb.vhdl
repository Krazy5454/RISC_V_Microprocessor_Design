library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_package.all;


entity datapath_tb is
end datapath_tb;

architecture Behavioral of datapath_tb is
    signal clk: std_logic := '1';
    signal reset: std_logic := '0';
    signal Asel : std_logic_vector(REGS_ADDR_BITS-1 downto 0) := "00000";
    signal Bsel : std_logic_vector(REGS_ADDR_BITS-1 downto 0) := "00000";
    signal Dsel : std_logic_vector(REGS_ADDR_BITS-1 downto 0) := "00000";
    signal Dlen : std_logic := '0';
    signal PCAsel : std_logic := '0';
    signal IMMBsel : std_logic := '0';
    signal PCDsel : std_logic := '0';
    signal PCie : std_logic := '0';
    signal PCle : std_logic := '0'; --might not needed
    signal isBR : std_logic:= '0';
    signal BRcond : std_logic_vector(2 downto 0):= "000";
    signal ALUFunc : std_logic_vector(3 downto 0):= "0000";
    signal IMM : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
begin

  uut: entity work.datapath (Behavioral)
      port map( clk => clk,
                reset =>reset,
                control_word.Asel => Asel,
                control_word.Bsel => Bsel,
                control_word.Dsel => Dsel,
                control_word.Dlen => Dlen,
                control_word.PCAsel => PCAsel,
                control_word.IMMBsel => IMMBsel,
                control_word.PCDsel => PCDsel,
                control_word.PCie => PCie,
                control_word.PCle => PCle,
                control_word.isBR => isBR,
                control_word.BRcond => BRcond,
                control_word.ALUFunc => ALUFunc,
                control_word.IMM => IMM
                );

  --clk
  clk <= not clk after 5 ns;

  test: process
    begin
     wait for 5 ns;
      --reset in beginning
      reset <= '1';
      wait for 20 ns;
      reset <= '0';

      --add x0 + 56329378 -> x1
      Asel    <= "00000";
      Bsel    <= "00000";
      Dsel    <= "00001";
      Dlen    <= '1';
      PCAsel  <= '0';
      IMMBsel <= '1';
      PCDsel  <= '0';
      PCie    <= '0';
      PCle    <= '0';
      isBR    <= '0';
      BRcond  <= "000";
      ALUFunc <= "0000";
      IMM     <= std_logic_vector(to_unsigned(56329378,32));
      wait for 10 ns;

      --add x0 + 5 -> x1 (but no Dlen so nothing happens)
      Dlen    <= '0';
      IMM     <= std_logic_vector(to_unsigned(5,32));
      wait for 10 ns;

      --add x0 + x1 -> x0 (shouldn't do anything)
      Bsel    <= "00001";
      Dsel    <= "00000";
      Dlen    <= '1';
      IMMBsel <= '0';
      wait for 10 ns;

     --add x0 + 1 -> x2
      Bsel    <= "00000";
      Dsel    <= "00010";
      IMMBsel <= '1';
      IMM     <= std_logic_vector(to_unsigned(1,32));
      wait for 10 ns;

      --add x1 + x2 -> x31
      Asel    <= "00001";
      Bsel    <= "00010";
      Dsel    <= "11111";
      IMMBsel <= '0';
      wait for 10 ns;

      --sub x1 - x2 -> x31
      ALUFunc <= "0001";
      wait for 10 ns;

      --sub x1 - 13 -> x1
      Bsel    <= "00000";
      Dsel    <= "00001";
      IMMBsel <= '1';
      IMM     <= std_logic_vector(to_unsigned(13,32));
      wait for 10 ns;

      --shift x0 left 5 -> x31 (should be 0) --100 ns
      Asel    <= "00000";
      Bsel    <= "00010";
      Dsel    <= "11111";
      ALUFunc <= "0010";
      IMM     <= std_logic_vector(to_unsigned(5,32));
      wait for 10 ns;

      --shift x1 left 5 -> x31
      Asel    <= "00001";
      Bsel    <= "00000";
      wait for 10 ns;

      --shift x1 left x2 -> x31
      Bsel    <= "00010";
      IMMBsel <= '0';
      wait for 10 ns;

      --shift x1 right 5 -> x31
      Bsel    <= "00000";
      IMMBsel <= '1';
      ALUFunc <= "1010";
      wait for 10 ns;

      --shift x1 right x2 -> x31
      Bsel    <= "00010";
      IMMBsel <= '0';
      wait for 10 ns;

      --shift x1 right arithmetic 5 -> x31
      Bsel    <= "00000";
      IMMBsel <= '1';
      ALUFunc <= "1011";
      wait for 10 ns;

      --load number with 1 in msb in x1
      Asel    <= "00000";
      Dsel    <= "00001";
      ALUFunc <= "0000";
      IMM     <= std_logic_vector(to_signed(-561234,32));
      wait for 10 ns;

      --shift x1 right logical 5 -> x31
      Asel    <= "00001";
      Dsel    <= "11111";
      ALUFunc <= "1010";
      IMM     <= std_logic_vector(to_unsigned(5,32));
      wait for 10 ns;

      --shift x1 right arithmetic 5 -> x31
      ALUFunc <= "1011";
      wait for 10 ns;

      --set less than signed x1 < 10 -> x31
      ALUFunc <= "0100";
      IMM     <= std_logic_vector(to_signed(10,32));
      wait for 10 ns;

      --set less than signed x1 < -561234 -> x31 --200 ns
      IMM     <= std_logic_vector(to_signed(-561234,32));
      wait for 10 ns;

      --set less than signed x1 < -561236 -> x31
      IMM     <= std_logic_vector(to_signed(-561236,32));
      wait for 10 ns;

      --set less than signed x1 < x0 -> x31
      IMMBsel <= '0';
      IMM     <= std_logic_vector(to_signed(10,32));
      wait for 10 ns;

      --set less than signed x2 < x0 -> x31
      Asel    <= "00010";
      wait for 10 ns;

      --set less than signed x1 < x1 -> x31
      Asel    <= "00001";
      Bsel    <= "00001";
      wait for 10 ns;

      --set less than unsigned x1 < 10 -> x31 --250 ns
      Bsel    <= "00000";
      IMMBsel <= '1';
      ALUFunc <= "0110";
      IMM     <= std_logic_vector(to_unsigned(10,32));
      wait for 10 ns;

      --set less than unsigned x1 < 4294406062 -> x31
      IMM     <= std_logic_vector(to_signed(-561234,32)); --just leaving as signed so its same value
      wait for 10 ns;

      --set less than unsigned x1 < -4294406064 -> x31
      IMM     <= std_logic_vector(to_signed(-561232,32)); --is greater than -561234 when interpreted unsigned
      wait for 10 ns;

      --set less than unsigned x1 < x0 -> x31
      IMMBsel <= '0';
      IMM     <= std_logic_vector(to_signed(10,32));
      wait for 10 ns;

      --set less than unsigned x0 < x2 -> x31
      Asel    <= "00000";
      Bsel    <= "00010";
      wait for 10 ns;

      --set less than unsigned x1 < x1 -> x31 --300 ns
      Asel    <= "00001";
      Bsel    <= "00001";
      wait for 10 ns;

      --add x0 + 64334 -> x2
      Asel    <= "00000";
      Bsel    <= "00000";
      Dsel    <= "00010";
      IMMBsel <= '1';
      ALUFunc <= "0000";
      IMM     <= std_logic_vector(to_unsigned(64334,32));
      wait for 10 ns;

      -- x1 xor x2 -> x31
      Asel    <= "00001";
      Bsel    <= "00010";
      Dsel    <= "11111";
      IMMBsel <= '0';
      ALUFunc <= "1000";
      wait for 10 ns;

      -- x1 xor 53 -> x31
      IMMBsel <= '1';
      IMM     <= std_logic_vector(to_unsigned(53,32));
      wait for 10 ns;

      -- x1 or x2 -> x31
      IMMBsel <= '0';
      ALUFunc <= "1100";
      wait for 10 ns;

      -- x1 or 53 -> x31 --350 ns
      IMMBsel <= '1';
      wait for 10 ns;

      -- x1 and x2 -> x31
      IMMBsel <= '0';
      ALUFunc <= "1110";
      wait for 10 ns;

      -- x1 and 53 -> x31
      IMMBsel <= '1';
      wait for 10 ns;

      -- add x0 and 19 -> PC (should only be 16 as takes of bottom 2 bits) and store PC -> x31
      Asel    <= "00000";
      PCDsel  <= '1';
      PCle    <= '1';
      ALUFunc <= "0000";
      IMM     <= std_logic_vector(to_unsigned(19,32));
      wait for 10 ns;

      -- increment PC 
      Dlen    <= '0';
      PCDsel  <= '0';
      PCie    <= '1';
      PCle    <= '0';
      wait for 10 ns;

      -- PC + x0 -> x31 --400 ns
      Asel    <= "00001";
      Bsel    <= "00000";
      Dlen    <= '1';
      IMMBsel <= '0';
      PCDsel  <= '1';
      PCie    <= '0';
      wait for 10 ns;

      -- PC + 16 -> PC
      Asel    <= "00000";
      Dlen    <= '0';
      PCAsel  <= '1';
      IMMBsel <= '1';
      PCDsel  <= '0';
      PCle    <= '1';
      IMM     <= std_logic_vector(to_unsigned(16,32));
      wait for 10 ns;

      --branch to PC + 8 if x1 equal x1
      Asel    <= "00001";
      Bsel    <= "00001";
      PCle    <= '0';
      isBR    <= '1';
      IMM     <= std_logic_vector(to_unsigned(8,32));
      wait for 10 ns;

      --branch to PC + 8 if x1 equal x2
      Bsel    <= "00010";
      wait for 10 ns;

      --branch to PC + 8 if x1 not equal x1
      Bsel    <= "00001";
      BRcond  <= "001";
      wait for 10 ns;

      --branch to PC + 8 if x1 not equal x2 --450 ns
      Bsel    <= "00010";
      wait for 10 ns;

       --branch to PC + 8 if x1 less than x1 (signed)
      Bsel    <= "00001";
      BRcond  <= "100";
      wait for 10 ns;

      --branch to PC + 8 if x1 less than x2 (signed)
      Bsel    <= "00010";
      wait for 10 ns;

      --branch to PC + 8 if x2 less than x1 (signed)
      Asel    <= "00010";
      Bsel    <= "00001";
      wait for 10 ns;

      --branch to PC + 8 if x1 greater than or equal to x1 (signed)
      Asel    <= "00001";
      BRcond  <= "101";
      wait for 10 ns;

      --branch to PC + 8 if x1 greater than or equal to x2 (signed) --500 ns
      Bsel    <= "00010";
      wait for 10 ns;

      --branch to PC + 8 if x2 greater than or equal to x1 (signed)
      Asel    <= "00010";
      Bsel    <= "00001";
      wait for 10 ns;

      --branch to PC + 8 if x1 less than x1 (unsigned)
      Asel    <= "00001";
      BRcond  <= "110";
      wait for 10 ns;

      --branch to PC + 8 if x1 less than x2 (unsigned)
      Bsel    <= "00010";
      wait for 10 ns;

      --branch to PC + 8 if x2 less than x1 (unsigned)
      Asel    <= "00010";
      Bsel    <= "00001";
      wait for 10 ns;

      --branch to PC + 8 if x1 greater than or equal to x1 (unsigned) --550 ns
      Asel    <= "00001";
      BRcond  <= "111";
      wait for 10 ns;

      --branch to PC + 8 if x1 greater than or equal to x2 (unsigned)
      Bsel    <= "00010";
      wait for 10 ns;

      --branch to PC + 8 if x2 greater than or equal to x1 (unsigned)
      Asel    <= "00010";
      Bsel    <= "00001";
      wait for 10 ns;

      wait;
    end process;

end Behavioral;
