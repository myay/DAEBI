library ieee;
use ieee.std_logic_1164.all;

entity regfile_tb is
end regfile_tb;

architecture test of regfile_tb is
  component regfile
    generic(
      data_width: integer;
      addr_width: integer;
      nr_regs: integer
    );
    port(
      clk: in std_logic;
      we3: in std_logic;
      a1: in std_logic_vector(addr_width-1 downto 0);
      a3: in std_logic_vector(addr_width-1 downto 0);
      wd3: in std_logic_vector(data_width-1 downto 0);
      rd1: out std_logic_vector(data_width-1 downto 0)
    );
  end component;

signal clk, we3: std_logic;
signal wd3, rd1: std_logic_vector(31 downto 0);
signal a1, a3: std_logic_vector(1 downto 0);
begin
  regfile_test: regfile
    generic map(
      data_width => 32,
      addr_width => 2,
      nr_regs => 4
    )
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

    -- Write ffffffff into register 0
    a3 <= "00";
    we3 <= '1';
    wd3 <= x"ffffffff";
    wait for 1 ns;
    clk <= '1';
    wait for 10 ns;

    clk <= '0';
    wait for 10 ns;

    -- Write 0000000f into register 1
    a3 <= "01";
    we3 <= '1';
    wd3 <= x"0000000f";
    wait for 1 ns;
    clk <= '1';
    wait for 10 ns;

    clk <= '0';
    wait for 10 ns;

    -- Read register 0
    we3 <= '0';
    a1 <= "01";
    wait for 1 ns;
    clk <= '1';
    wait for 10 ns;

    clk <= '0';
    wait for 10 ns;

    -- Read register 1
    a1 <= "00";
    wait for 1 ns;
    clk <= '1';
    wait for 10 ns;

    wait;
  end process;
end test;
