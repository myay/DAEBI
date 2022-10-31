library ieee;
use ieee.std_logic_1164.all;

entity register_dff_tb is
end register_dff_tb;

architecture test of register_dff_tb is
  component register_dff
    generic(w : integer);
    port(
      clk   : in std_logic;
      reset : in std_logic;
      d     : in std_logic_vector(w-1 downto 0); -- input data
      q     : out std_logic_vector(w-1 downto 0)
    );
  end component;

signal clk, reset: std_logic;
signal d, q: std_logic_vector(7 downto 0);
begin
  register_test: register_dff
    generic map(w => 8)
    port map(clk => clk, reset => reset, d => d, q => q);

  process begin
    clk <= '0';
    reset <= '0';

    wait for 10 ns;
    d <= x"0f";
    wait for 5 ns;
    clk <= '1';

    wait for 10 ns;
    clk <= '0';

    wait for 10 ns;
    reset <= '1';

    wait for 10 ns;
    d <= x"0d";
    wait for 5 ns;
    clk <= '1';

    wait for 10 ns;
    wait;
  end process;
end test;
