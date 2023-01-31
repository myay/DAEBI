library IEEE;
use IEEE.std_logic_1164.all;

entity comparator is
  generic(bit_width : integer := 16);
  port(
    clk : in std_logic;
    x : in std_logic_vector(bit_width-1 downto 0); -- Input value to compare
    threshold : in std_logic_vector(bit_width-1 downto 0); -- Threshold value to compare against
    less : out std_logic; -- '1' when x is less than threshold
    eq : out std_logic -- '1' when x is equal to threshold
  );
end comparator;

architecture bhv of comparator is
begin
  less <= '1' when x < threshold else '0';
  eq <= '1' when x = threshold else '0';
end bhv;
