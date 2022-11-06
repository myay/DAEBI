library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
  port (
    clk: in std_logic;
    we3: in std_logic;
    a1: in std_logic_vector(1 downto 0);
    a3: in std_logic_vector(1 downto 0);
    wd3: in std_logic_vector(31 downto 0);
    rd1: buffer std_logic_vector(31 downto 0)
  );
end;

architecture behavior of regfile is
  type ramtype is array (3 downto 0) of std_logic_vector(31 downto 0);
  signal mem: ramtype;
begin
  -- If write enable is 1, then store value wd3 to register a3
  process(clk) begin
    if rising_edge(clk) then
      if we3 = '1' then
        mem(to_integer(unsigned(a3))) <= wd3;
      end if;
    end if;
  end process;

  -- Read out contents of register a1 to rd1
  process(a1) begin
    rd1 <= mem(to_integer(unsigned(a1)));
  end process;
end;
