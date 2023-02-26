library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.MATH_REAL.all;
use work.array_pack.all;

entity vm_multicol_rng_tb is
end vm_multicol_rng_tb;

architecture test of vm_multicol_rng_tb is
  component computing_columns_vm_constrained
    generic(
      nr_computing_columns : integer := 64; -- Number of computing columns used in this controller
      nr_xnor_gates : integer := 64; -- Number of XNOR gates used in each computing column
      acc_data_width : integer := 16; -- Width of the output of each computing column
      nr_popc_bits_o: integer := 7
    );
    port(
      clk : in std_logic;
      reset : in std_logic;
      xnor_inputs_1 : in array_2d_data; -- First inputs
      xnor_inputs_2 : in array_2d_data; -- Second inputs
      thresholds_in : in array_2d_th;
      o_result : out array_2d_out; -- Outputs
      less_results : out std_logic_vector(nr_computing_columns-1 downto 0);
      eq_results : out std_logic_vector(nr_computing_columns-1 downto 0)
    );
  end component;

signal rst_t: std_logic := '0';
signal inputs_1: array_2d_data := (others => (others => '0'));
signal inputs_2: array_2d_data := (others => (others => '0'));
signal input_thresholds: array_2d_th := (others => (others => '0'));
signal outputs_cc: array_2d_out := (others => (others => '0'));

signal less_t: std_logic_vector(1 downto 0);
signal eq_t: std_logic_vector(1 downto 0);

signal clk_t: std_logic := '0';
constant clk_period : time := 2 ns;
-- Workload definition
constant alpha: integer := 64;
constant beta: integer := 576;
constant delta: integer := 196;
constant beta_minus_half : real := 0.5*real(beta/2);
constant beta_plus_half : real := 1.5*real(beta/2);
-- After how many clock cycles the accumulator should be reset
constant reset_it: integer := integer(ceil(real(beta)/real(64)));
-- After how many clock cycles the reset value (0) is at the output
constant reset_delay: integer := 11;
-- Total amount of iterations (input applications) that need to be performed
constant max_iterations: integer := 50;--integer(alpha*delta*reset_it);
constant delay_cycles: integer := integer(floor(real(max_iterations)/real(reset_it)));
constant total_clockc: integer := 50;--max_iterations + delay_cycles + 10;

begin
  computing_columns_test: computing_columns_vm_constrained
    generic map(
      nr_computing_columns => 2,
      nr_xnor_gates => 64,
      acc_data_width => 16,
      nr_popc_bits_o => 7
    )
    port map(
      clk => clk_t,
      reset => rst_t,
      xnor_inputs_1 => inputs_1,
      xnor_inputs_2 => inputs_2,
      thresholds_in => input_thresholds,
      o_result => outputs_cc,
      less_results => less_t,
      eq_results => eq_t
    );

  -- Clock generation process
  clk_process: process
    variable i: integer := 0;
    begin
      while i<total_clockc loop
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
    variable rand_int_1 : std_logic_vector(63 downto 0);
    variable rand_int_2 : std_logic_vector(63 downto 0);
    variable res_xnor : std_logic_vector(63 downto 0);
    variable j: integer := 0; -- For iterating until there are no more clock cycles
    variable k: integer := 0; -- For counting the number of additions performed
    variable rand_threshold : integer;
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
        if x > 0.5 then
          rlv_val(i) := '1';
        else
          rlv_val(i) := '0';
        end if;
      end loop;
      return rlv_val;
    end function;

    -- Function for generating random integer
    impure function rand_int(min_val, max_val : real) return integer is
      variable x : real; -- Returned random value in rng function
    begin
      uniform(seed1, seed2, x);
      return integer(round(x * (max_val - min_val + 1.0) + (min_val) - 0.5));
    end function;

    begin
      -- report "ceil:  " & integer'image(reset_it);
      -- report "ceil:  " & integer'image(total_it);
      wait for clk_period/2;
      while j < max_iterations loop
        -- report "j = " & integer'image(j);
        if k = reset_it then
          acc_result := 0;
          k := 0;
          -- Apply neutral elements to all columns
          for i in 0 to 1 loop
            inputs_1(i) <= "0101010101010101010101010101010101010101010101010101010101010101";
            inputs_2(i) <= "1010101010101010101010101010101010101010101010101010101010101010";
          end loop;
          rst_t <= '1';
          wait for clk_period;
          -- Apply next threshold
          -- report "The value of 'beta_minus' is " & real'image(beta_minus_half);
          -- report "The value of 'beta_plus' is " & real'image(beta_plus_half);
          rand_threshold := rand_int(beta_minus_half,beta_plus_half);
          for i in 0 to 1 loop
            input_thresholds(i) <= std_logic_vector(to_unsigned(rand_threshold, 16));
          end loop;
        else
          rst_t <= '0';
          rand_int_1 := rand_lv(64);
          rand_int_2 := rand_lv(64);
          for i in 0 to 1 loop
            inputs_1(i) <= rand_int_1;
            inputs_2(i) <= rand_int_2;
          end loop;
          -- Compute for comparison
          res_xnor := rand_int_1 xnor rand_int_2;
          for i in 0 to 63 loop
            if (res_xnor(i)='1') then
              res_popc := res_popc + 1;
            end if;
          end loop;
          -- report "The value of 'res_popc' is " & integer'image(res_popc);
          acc_result := acc_result + res_popc;
          -- Increment number of additions
          k := k + 1;
          res_popc := 0;
          report "The value of 'acc_result' is " & integer'image(acc_result);
          wait for clk_period;
        end if;
        -- assert to_integer(unsigned(output_cc)) = acc_result report "Assertion violation. acc_result = " & integer'image(acc_result);
        j := j+1;
      end loop;
      wait;
    end process;
end test;
