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

architecture behavior of adder is
begin
  y <= std_logic_vector(unsigned(a) + unsigned(b));
end;
