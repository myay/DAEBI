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

signal i_val_t, rst_t, o_val_t: std_logic;
signal clk_t: std_logic := '0';
constant clk_period : time := 2 ns;
signal input_t: std_logic_vector(63 downto 0);
signal output_t: std_logic_vector(13 downto 0);
shared variable i: integer := 0;
shared variable max_clock_cyles: integer := 20;

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
    rst_t <= '0';
    wait for 1 ns;

    i_val_t <= '1';
    input_t <= x"ffffffffffffffff";
    wait for 50 ns;
    wait;
  end process;

  -- clock generation process
  clk_process: process
    begin
      while i<max_clock_cyles loop
        -- clk_t <= not clk_t after clk_period/2;
        clk_t <= '0';
        wait for clk_period/2;  -- Signal is '0'.
        clk_t <= '1';
        wait for clk_period/2;  -- Signal is '1'
        i := i+1;
      end loop;
      wait;
    end process;
end test;
