library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accumulator is
  generic(
    input_width: integer;
    data_width: integer
  );
  port(
    clk    : in std_logic;
    reset  : in std_logic;
    i_data : in std_logic_vector(input_width-1 downto 0);
    o_data : out std_logic_vector(data_width-1 downto 0)
  );
end accumulator;

architecture bhv of accumulator is
  signal tmp: std_logic_vector(data_width-1 downto 0) := (others => '0');
begin
  process (clk) begin
    if rising_edge(clk) then
      if reset = '1' then
        tmp <= (others => '0');
      else
        tmp <= std_logic_vector(unsigned(tmp) + unsigned(i_data));
      end if;
    end if;
  end process;
  o_data <= tmp;
end bhv;
