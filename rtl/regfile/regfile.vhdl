library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
  generic(
    data_width: integer := 13;
    addr_width: integer := 8;
    nr_regs: integer := 196
  );
  port(
    clk: in std_logic;
    we3: in std_logic;
    reset: in std_logic;
    a1: in std_logic_vector(addr_width-1 downto 0);
    a3: in std_logic_vector(addr_width-1 downto 0);
    wd3: in std_logic_vector(data_width-1 downto 0);
    rd1: out std_logic_vector(data_width-1 downto 0)
  );
end;

architecture behavior of regfile is
  type ramtype is array (nr_regs-1 downto 0) of std_logic_vector(data_width-1 downto 0);
  signal mem: ramtype := (others => (others => '0'));
begin
  -- If write enable is 1, then store value wd3 to register a3
  process(clk) begin
    if rising_edge(clk) then
      if we3 = '1' then
        mem(to_integer(unsigned(a3))) <= wd3;
      end if;
      -- Reset all register contents
      if reset = '1' then
        mem <= (others => (others => '0'));
      end if;
    end if;
  end process;

  -- Read out contents of register a1 to rd1
  process(clk) begin
    if rising_edge(clk) then
      rd1 <= mem(to_integer(unsigned(a1)));
    end if;
  end process;
end;
