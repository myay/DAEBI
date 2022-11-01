library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
  generic(
    w_i : integer;
    w_o : integer
  );
  port(
    a: in std_logic_vector(w_i-1 downto 0);
    b: in std_logic_vector(w_i-1 downto 0);
    y: out std_logic_vector(w_o-1 downto 0)
  );
end;

architecture rtl of adder is
  signal i_1 : std_logic_vector(w_o-1 downto 0):=(others => '0');
  signal i_2 : std_logic_vector(w_o-1 downto 0):=(others => '0');
begin
  i_1(w_i-1 downto 0) <= a;
  i_2(w_i-1 downto 0) <= b;
  y <= std_logic_vector(unsigned(i_1)+unsigned(i_2));
end;
