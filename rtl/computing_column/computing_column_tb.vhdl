library ieee;
use ieee.std_logic_1164.all;

library work;
use work.pkg.all;

entity computing_column_tb is
end computing_column_tb;

architecture test of computing_column_tb is
  component computing_column
    generic(nr_xnor_gates: integer);
    port(
      clk           : in std_logic;
      rst           : in std_logic;
      xnor_inputs_1 : in std_logic_vector(nr_xnor_gates-1 downto 0); -- First inputs
      xnor_inputs_2 : in std_logic_vector(nr_xnor_gates-1 downto 0); -- Second inputs
      o_data_cc     : out std_logic_vector(31 downto 0) -- Output data
    );
  end component;

signal rst_t: std_logic;
signal input_1: std_logic_vector(63 downto 0);
signal input_2: std_logic_vector(63 downto 0);
signal output_cc: std_logic_vector(31 downto 0);

signal clk_t: std_logic := '0';
constant clk_period : time := 2 ns;
shared variable i: integer := 0;
shared variable max_clock_cyles: integer := 40;

begin
  computing_column_test: computing_column
    generic map (nr_xnor_gates => 64)
    port map(
      clk => clk_t,
      rst => rst_t,
      xnor_inputs_1 => input_1,
      xnor_inputs_2 => input_2,
      o_data_cc => output_cc
    );

  process begin
    input_1 <= "1010101010101010101010101010101010101010101010101010101010101010";
    input_2 <= "1010101010101010101010101010101010101010101010101010101010101010";
    wait for 50 ns;

    input_1 <= "1010101010101010101010101010101010101010101010101010101010101011";
    input_2 <= "1010101010101010101010101010101010101010101010101010101010101011";
    wait for 50 ns;
    wait;
  end process;

  -- Clock generation process
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
