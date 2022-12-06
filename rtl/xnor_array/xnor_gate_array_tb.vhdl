library ieee;
use ieee.std_logic_1164.all;

entity xnor_gate_array_tb is
end xnor_gate_array_tb;

architecture test of xnor_gate_array_tb is
  component xnor_gate_array
    generic(nr_xnor_gates: integer);
    port(
      xnor_inputs_1 : in std_logic_vector(nr_xnor_gates-1 downto 0); -- First inputs
      xnor_inputs_2 : in std_logic_vector(nr_xnor_gates-1 downto 0); -- Second inputs
      xnor_outputs  : out std_logic_vector(nr_xnor_gates-1 downto 0) -- XNOR results
    );
  end component;

signal a, b, r: std_logic_vector(3 downto 0);
begin
  xnor_gate_array_test: xnor_gate_array
  generic map(nr_xnor_gates => 4)
  port map(
    xnor_inputs_1 => a,
    xnor_inputs_2 => b,
    xnor_outputs => r
  );
  process begin
    a <= "0000";
    b <= "0000";
    wait for 10 ns;

    a <= "0001";
    b <= "0000";
    wait for 10 ns;

    a <= "0011";
    b <= "0000";
    wait for 10 ns;

    a <= "0111";
    b <= "0000";
    wait for 10 ns;

    wait;
  end process;
end test;
