library ieee;
use ieee.std_logic_1164.all;

entity regfile_tb is
end regfile_tb;

architecture test of regfile_tb is
  component regfile
    port (
      clk: in std_logic;
      we3: in std_logic;
      a1: in std_logic_vector(1 downto 0);
      a3: in std_logic_vector(1 downto 0);
      wd3: in std_logic_vector(31 downto 0);
      rd1: out std_logic_vector(31 downto 0)
    );
  end component;

signal clk, we3: std_logic;
signal a1, a3: std_logic_vector(1 downto 0);
signal wd3, rd1: std_logic_vector(31 downto 0);
begin
  regfile_test: regfile
    port map(
      clk => clk,
      we3 => we3,
      a1 => a1,
      a3 => a3,
      wd3 => wd3,
      rd1 => rd1
    );

  process begin
    clk <= '0';
    wait for 10 ns;
    a3 <= "00";
    we3 <= '1';
    wd3 <= x"ffffffff";
    clk <= '1';
    wait for 10 ns;

    clk <= '0';
    wait for 10 ns;

    a3 <= "01";
    we3 <= '1';
    wd3 <= x"0000000f";
    clk <= '1';
    wait for 10 ns;

    clk <= '0';
    we3 <= '0';
    a1 <= "00";
    wait for 10 ns;

    a1 <= "01";
    wait for 10 ns;

    wait;
  end process;
end test;
