library ieee;
use ieee.std_logic_1164.all;
use IEEE.MATH_REAL.all;
USE ieee.numeric_std.ALL;

entity vm_rng_tb is
end vm_rng_tb;

architecture test of vm_rng_tb is
  component computing_column_vm
    generic(
      nr_xnor_gates: integer;
      acc_data_width: integer;
      nr_popc_bits_o: integer
    );
    port(
      clk           : in std_logic;
      rst           : in std_logic;
      xnor_inputs_1 : in std_logic_vector(nr_xnor_gates-1 downto 0); -- First inputs
      xnor_inputs_2 : in std_logic_vector(nr_xnor_gates-1 downto 0); -- Second inputs
      threshold_in  : in std_logic_vector(acc_data_width-1 downto 0); -- Threshold data
      o_data_cc     : out std_logic_vector(acc_data_width-1 downto 0); -- Output data
      less_cc : out std_logic;
      eq_cc : out std_logic
    );
  end component;

-- Inputs
signal rst_t: std_logic;
signal input_1: std_logic_vector(63 downto 0);
signal input_2: std_logic_vector(63 downto 0);
signal input_threshold: std_logic_vector(31 downto 0);
-- Outputs
signal output_cc: std_logic_vector(31 downto 0);
signal less_cc_t, eq_cc_t: std_logic;
signal clk_t: std_logic := '0';
constant clk_period : time := 2 ns;
-- constant max_clock_cyles: integer := 60;
signal res_xnor : std_logic_vector(63 downto 0) := (others => '0');
-- Workload
constant alpha: integer := 64;
constant beta: integer := 576;
constant delta: integer := 196;
-- After how many clock cycles the accumulator should be reset
constant reset_it: integer := integer(ceil(real(beta)/real(64)));
-- Total amount of iterations (input applications) that need to be performed
constant max_clock_cyles: integer := integer(alpha*delta*reset_it);

begin
  computing_column_test: computing_column_vm
    generic map(
      nr_xnor_gates => 64,
      acc_data_width => 32,
      nr_popc_bits_o => 7
    )
    port map(
      clk => clk_t,
      rst => rst_t,
      xnor_inputs_1 => input_1,
      xnor_inputs_2 => input_2,
      threshold_in => input_threshold,
      o_data_cc => output_cc,
      less_cc => less_cc_t,
      eq_cc => eq_cc_t
    );

  -- Clock generation process
  clk_process: process
    variable i: integer := 0;
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

  -- RNG process
  rng_process: process
    variable seed1, seed2 : integer := 999; -- Seeds for reproducable random numbers
    variable rand_real_val : real; -- For storing random real value
    variable rand_int_val : integer; -- For storing random integer value
    variable j: integer := 0; -- For iterating until there are no more clock cycles
    -- Debug signals and variables
    variable res_popc: integer := 0;
    variable acc_result: integer := 0;

    -- Function for generating random std_logic_vector
    impure function rand_lv(len : integer) return std_logic_vector is
      variable x : real; -- Returned random value in rng function
      variable rlv_val : std_logic_vector(len - 1 downto 0); -- Returned random bit string of length len
    begin
      for i in rlv_val'range loop
        uniform(seed1, seed2, x);
        rlv_val(i) := '1' when x > 0.5 else '0';
      end loop;
      return rlv_val;
    end function;

    begin
    -- TODO: init column
    -- start calculations
      -- report "ceil:  " & integer'image(reset_it);
      -- report "ceil:  " & integer'image(total_it);
      wait for clk_period/2;
      while j < max_clock_cyles loop
        -- report "j" & integer'image(j);
        if ((j mod reset_it = 0) and (j /= 0)) then
          -- report "reset:  " & integer'image(j);
          -- Apply neutral elements
          input_1 <= "0101010101010101010101010101010101010101010101010101010101010101";
          input_2 <= "1010101010101010101010101010101010101010101010101010101010101010";
          rst_t <= '1';
          acc_result := 0;
          wait for clk_period;
        end if;
        rst_t <= '0';
        input_1 <= rand_lv(64);
        input_2 <= rand_lv(64);
        -- test result for printing
        res_xnor <= input_1 xnor input_2;
        for i in 0 to 63 loop
          if (res_xnor(i)='1') then
            res_popc := res_popc + 1;
          end if;
        end loop;
        acc_result := acc_result + res_popc;
        -- report "The value of 'res_popc' is " & integer'image(res_popc);
        -- report "The value of 'acc_popc' is " & integer'image(acc_result);
        res_popc := 0;
        j := j+1;
        wait for clk_period;
      end loop;
      wait;
    end process;
end test;
