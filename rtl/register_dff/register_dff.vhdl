library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register_dff is
  generic(w : integer);
  port(
    clk   : in std_logic;
    reset : in std_logic;
    d     : in std_logic_vector(w-1 downto 0); -- input data
    q     : out std_logic_vector(w-1 downto 0)
  );
end register_dff;

architecture rtl of register_dff is
begin
  process(clk, reset) begin
    if reset = '1' then q <= (others=>'0');
    elsif rising_edge(clk) then
      q <= d;
    end if;
  end process;
end rtl;
