library ieee;
use ieee.std_logic_1164.all;

library work;
use work.pkg.all;

entity xnor_gate_array is
  port(
    xnor_inputs_1 : in std_logic_vector(xnor_gates_per_column-1 downto 0); -- First inputs
    xnor_inputs_2 : in std_logic_vector(xnor_gates_per_column-1 downto 0); -- Second inputs
    xnor_outputs  : out std_logic_vector(xnor_gates_per_column-1 downto 0) -- XNOR results
  );
end xnor_gate_array;

architecture rtl of xnor_gate_array is
signal xnor_o : std_logic_vector(xnor_gates_per_column-1 downto 0);
begin
  -- Create a certain number of XNOR gates, number specified in xnor_gates_per_column
  xnor_gen: for i in 0 to xnor_gates_per_column-1 generate
    inst_xnor : entity work.xnor_gate(rtl)
      port map(
        xnor_in_1 => xnor_inputs_1(i),
        xnor_in_2 => xnor_inputs_2(i),
        xnor_out  => xnor_outputs(i)
      );
   end generate;
end rtl;
