library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
  generic(w : integer);
  port(
    a: in std_logic_vector(w-1 downto 0);
    b: in std_logic_vector(w-1 downto 0);
    y: out std_logic_vector(w-1 downto 0)
  );
end;

architecture behavior of adder is
begin
  y <= std_logic_vector(unsigned(a) + unsigned(b));
end;
