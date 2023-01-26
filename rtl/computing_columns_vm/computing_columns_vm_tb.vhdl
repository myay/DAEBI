library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- library work;
-- use work.pkg.all;

-- package array_pack is
--   type array_2d is array(integer range<>) of std_logic_vector;
-- end package;

-- library IEEE;
-- use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.array_pack.all;

entity computing_columns_vm_tb is
end computing_columns_vm_tb;

architecture test of computing_columns_vm_tb is
  component computing_columns_vm
    generic(
      nr_computing_columns : integer := 64; -- Number of computing columns used in this controller
      nr_xnor_gates : integer := 64; -- Number of XNOR gates used in each computing column
      acc_data_width : integer := 16; -- Width of the output of each computing column
      nr_popc_bits_o: integer := 7
    );
    port(
      clk : in std_logic;
      reset : in std_logic;
      xnor_inputs_1 : in array_2d(nr_computing_columns-1 downto 0)(nr_xnor_gates-1 downto 0); -- First inputs
      xnor_inputs_2 : in array_2d(nr_computing_columns-1 downto 0)(nr_xnor_gates-1 downto 0); -- Second inputs
      o_result : out array_2d(nr_computing_columns-1 downto 0)(acc_data_width-1 downto 0) -- Outputs
    );
  end component;

signal rst_t: std_logic;
signal input_1: array_2d(1 downto 0)(63 downto 0) := (others => (others => '0'));
signal input_2: array_2d(1 downto 0)(63 downto 0) := (others => (others => '0'));
signal output_cc: array_2d(1 downto 0)(15 downto 0) := (others => (others => '0'));

signal clk_t: std_logic := '0';
constant clk_period : time := 2 ns;
shared variable i: integer := 0;
shared variable max_clock_cyles: integer := 40;

begin
  computing_columns_test: computing_columns_vm
    generic map(
      nr_computing_columns => 2,
      nr_xnor_gates => 64,
      acc_data_width => 16,
      nr_popc_bits_o => 7
    )
    port map(
      clk => clk_t,
      reset => rst_t,
      xnor_inputs_1 => input_1,
      xnor_inputs_2 => input_2,
      o_result => output_cc
    );

  process begin

  -- input (cycle 0) to output (cycle 10) -> 10 cycles

  -- reset
  input_1(0) <= "1010101010101010101010101010101010101010101010101010101010101010";
  input_2(0) <= "1010101010101010101010101010101010101010101010101010101010101010";
  input_1(1) <= "1010101010101010101010101010101010101010101010101010101010101010";
  input_2(1) <= "1010101010101010101010101010101010101010101010101010101010101010";
  rst_t <= '1';
  wait for 2 ns;

  -- add 1
  input_1(0) <= "0101010111010101010101010101010101010101010101010101010101010101";
  input_2(0) <= "1010101010101010101010101010101010101010101010101010101010101010";
  input_1(1) <= "0101010111010101010101010101010101010101010101010101010101010101";
  input_2(1) <= "1010101010101010101010101010101010101010101010101010101010101010";
  rst_t <= '0';
  wait for 2 ns;

  -- add 2
  input_1(0) <= "0101010111010101010101010101010001010101010101010101010101010101";
  input_2(0) <= "1010101010101010101010101010101010101010101010101010101010101010";
  input_1(1) <= "0101010111010101010101010101010001010101010101010101010101010101";
  input_2(1) <= "1010101010101010101010101010101010101010101010101010101010101010";
  wait for 2 ns;

  -- add 64
  input_1(0) <= "1010101010101010101010101010101010101010101010101010101010101010";
  input_2(0) <= "1010101010101010101010101010101010101010101010101010101010101010";
  input_1(1) <= "1010101010101010101010101010101010101010101010101010101010101010";
  input_2(1) <= "1010101010101010101010101010101010101010101010101010101010101010";
  wait for 2 ns;

  -- reset
  rst_t <= '1';
  wait for 2 ns;
  rst_t <= '0';
  wait for 2 ns;

  -- add 63
  input_1(0) <= "1010101010101010101010101010101010101010101010101010101010101011";
  input_2(0) <= "1010101010101010101010101010101010101010101010101010101010101010";
  input_1(1) <= "1010101010101010101010101010101010101010101010101010101010101011";
  input_2(1) <= "1010101010101010101010101010101010101010101010101010101010101010";
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
