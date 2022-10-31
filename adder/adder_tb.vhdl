library ieee;
use ieee.std_logic_1164.all;

entity adder_tb is
end adder_tb;

architecture test of adder_tb is
  component adder
    generic(w : integer);
    port(
      a: in std_logic_vector(w-1 downto 0);
      b: in std_logic_vector(w-1 downto 0);
      y: out std_logic_vector(w-1 downto 0)
    );
  end component;

signal a, b, y: std_logic_vector(31 downto 0);
begin
  adder_test: adder
  generic map(w => 32)
  port map(a => a, b => b, y => y);

  process begin
    wait for 10 ns;
    a <= x"00000001";
    b <= x"00000001";
    wait for 10 ns;
    wait;
  end process;
end test;
