library ieee;
use ieee.std_logic_1164.all;

entity xnor_gate_tb is
end xnor_gate_tb;

architecture test of xnor_gate_tb is
  component xnor_gate
    port(
      xnor_in_1    : in std_logic;
      xnor_in_2  : in std_logic;
      xnor_out : out std_logic
    );
  end component;

signal a, b, r: std_logic;
begin
  xnor_gate_test: xnor_gate port map(xnor_in_1 => a, xnor_in_2 => b, xnor_out => r);
  process begin
    a <= '0';
    b <= '0';
    wait for 10 ns;

    a <= '1';
    b <= '0';
    wait for 10 ns;

    a <= '0';
    b <= '1';
    wait for 10 ns;

    a <= '1';
    b <= '1';
    wait for 10 ns;

    wait;
  end process;
end test;
