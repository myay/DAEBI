library ieee;
use ieee.std_logic_1164.all;

library work;
use work.pkg.all;

entity popcount_tb is
end popcount_tb;

architecture test of popcount_tb is
  component popcount
    port(
      i_val       : in std_logic; -- whether it is ready to compute
      clk         : in std_logic;
      rst         : in std_logic;
      stream_i    : in std_logic_vector(63 downto 0);	--input Vector
      o_val       : out std_logic; --Finish Signal
      stream_o    : out std_logic_vector(13 downto 0)	--output Result (how many ones in the input)
    );
  end component;

signal i_val_t, clk_t, rst_t, o_val_t: std_logic;
signal input_t: std_logic_vector(63 downto 0);
signal output_t: std_logic_vector(13 downto 0);

begin
  popcount_test: popcount
    port map(
      i_val => i_val_t,
      clk => clk_t,
      rst => rst_t,
      stream_i => input_t,
      o_val => o_val_t,
      stream_o => output_t
    );
  process begin
    i_val_t <= '0';
    clk_t <= '0';
    rst_t <= '0';
    wait for 10 ns;

    i_val_t <= '1';
    input_t <= x"ffffffffffffffff";
    wait for 5 ns;

    clk_t <= '1';
    wait for 10 ns;

    clk_t <= '0';
    wait for 1 ns;

    clk_t <= '1';
    wait for 1 ns;

    clk_t <= '0';
    wait for 1 ns;

    clk_t <= '1';
    wait for 1 ns;

    clk_t <= '0';
    wait for 1 ns;

    clk_t <= '1';
    wait for 1 ns;

    clk_t <= '0';
    wait for 1 ns;

    clk_t <= '1';
    wait for 1 ns;

    clk_t <= '0';
    wait for 1 ns;

    clk_t <= '1';
    wait for 1 ns;

    clk_t <= '0';
    wait for 1 ns;

    clk_t <= '1';
    wait for 1 ns;

    clk_t <= '0';
    wait for 1 ns;

    clk_t <= '1';
    wait for 1 ns;

    clk_t <= '0';
    wait for 1 ns;

    clk_t <= '1';
    wait for 1 ns;

    clk_t <= '0';
    wait for 1 ns;

    clk_t <= '1';
    wait for 1 ns;

    clk_t <= '0';
    wait for 1 ns;

    clk_t <= '1';
    wait for 1 ns;

    wait;
  end process;
end test;
