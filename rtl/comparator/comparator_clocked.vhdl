library IEEE;
use IEEE.std_logic_1164.all;

entity comparator_clocked is
  generic(bit_width : integer := 16);
  port(
    clk : in std_logic;
    x : in std_logic_vector(bit_width-1 downto 0); -- Input value to compare
    threshold : in std_logic_vector(bit_width-1 downto 0); -- Threshold value to compare against
    less : out std_logic; -- '1' when x is less than threshold
    eq : out std_logic -- '1' when x is equal to threshold
  );
end comparator_clocked;

architecture behavioral of comparator_clocked is
begin
  process(clk) begin
    if rising_edge(clk) then
      if x < threshold then
        less <= '1';
        eq <= '0';
      elsif x = threshold then
        less <= '0';
        eq <= '1';
      else
        less <= '0';
        eq <= '0';
      end if;
     end if;
   end process;
end behavioral;
