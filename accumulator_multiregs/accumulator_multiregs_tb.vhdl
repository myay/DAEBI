library ieee;
use ieee.std_logic_1164.all;

library work;
use work.pkg.all;

entity accumulator_multiregs_tb is
end accumulator_multiregs_tb;

architecture test of accumulator_multiregs_tb is
  component accumulator_multiregs
    port(
      i_val_acc   : std_logic; -- Signals whether accumulator is ready to receive new input data
      reset       : in std_logic; -- Reset signal
      clk         : in std_logic; -- Clock signal
      r_s         : in std_logic_vector(1 downto 0); -- Register selector
      i_data      : in std_logic_vector(8 downto 0); -- Input data
      o_data      : out std_logic_vector(31 downto 0); -- Output data
      o_val_acc   : out std_logic -- Signal for completion of computations
    );
  end component;

signal i_val_acc_t, rst_t, o_val_acc_t: std_logic;
signal r_s_t: std_logic_vector(1 downto 0);
signal clk_t: std_logic := '0';
constant clk_period : time := 10 ns;
shared variable i: integer := 0;
shared variable max_clock_cyles: integer := 20;
signal input_t: std_logic_vector(8 downto 0);
signal output_t: std_logic_vector(31 downto 0);

begin
  accumulator_multiregs_test: accumulator_multiregs
    port map(
      i_val_acc => i_val_acc_t,
      clk => clk_t,
      reset => rst_t,
      r_s => r_s_t,
      i_data => input_t,
      o_data => output_t,
      o_val_acc => o_val_acc_t
    );

  process begin
    i_val_acc_t <= '0';
    rst_t <= '0';
    wait for 1 ns;

    i_val_acc_t <= '1';
    r_s_t <= "00";
    input_t <= "000000001";
    wait for 20 ns;

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
