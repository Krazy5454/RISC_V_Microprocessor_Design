library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

package RISCV_package is
constant XLEN_BITS : integer := 5;
constant XLEN : integer := 2**XLEN_BITS;
constant REGS_ADDR_BITS : integer := 5;

type control_word is record
    Asel : std_logic_vector(4 downto 0);
    Bsel : std_logic_vector(4 downto 0);
    Dsel : std_logic_vector(4 downto 0);
    Dlen : std_logic;
    PCAsel : std_logic;
    IMMBsel : std_logic;
    PCDsel : std_logic;
    PCie : std_logic;
    PCle : std_logic; --might not needed
    isBR : std_logic;
    BRcond : std_logic_vector(2 downto 0);
    ALUFunc : std_logic_vector(3 downto 0);
    IMM : std_logic_vector(31 downto 0);
end record control_word;

function decode (signal sel: std_logic_vector; signal enable: std_logic ) return std_logic_vector;
function vector_and ( signal to_and : std_logic_vector ) return std_logic;
end RISCV_package;

package body RISCV_package is

function decode (signal sel: std_logic_vector; signal enable: std_logic ) return std_logic_vector is
    variable decoded : std_logic_vector ((2**sel'length)-1 downto 0);
begin
        decoded := (others => '0');
        decoded( to_integer( unsigned( sel ))) := enable;
        return decoded;
end function;
    
function vector_and ( signal to_and : std_logic_vector ) return std_logic is
    variable result : std_logic := '1';
begin
    for i in to_and'range loop
        result := to_and(i) and result;
    end loop;
end function;
   
end RISCV_package;
