library ieee;
use ieee.std_logic_1164.all;

entity xnor_gate is
  port(
    xnor_in_1    : in std_logic; -- First input
    xnor_in_2  : in std_logic;	-- Second input
    xnor_out : out std_logic	-- XNOR result
  );
end xnor_gate;

architecture rtl of xnor_gate is
signal xnor_o : std_logic;
begin
    -- Perform XNOR between the two inputs
    xnor_o  <= xnor_in_1 xnor xnor_in_2;
    xnor_out <= xnor_o;
end rtl;
