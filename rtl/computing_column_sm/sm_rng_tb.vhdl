library ieee;
use ieee.std_logic_1164.all;
use IEEE.MATH_REAL.all;
USE ieee.numeric_std.ALL;

entity sm_rng_tb is
end sm_rng_tb;

architecture test of sm_rng_tb is
  component computing_column_sm
    generic(
      nr_xnor_gates: integer := 64; -- Number of XNOR gates
      acc_data_width: integer := 13; -- Width of registers in accumulator
      nr_popc_bits_o: integer := 7; -- Number of output bits from the popcount unit
      nr_regs_accm: integer := 196; -- Number of registers in the multiregs accumulator
      addr_width_accm: integer := 8 -- Number of addresses neeed in the multiregs accumulator
    );
    port(
      clk           : in std_logic;
      rst           : in std_logic;
      xnor_inputs_1 : in std_logic_vector(nr_xnor_gates-1 downto 0); -- First inputs
      xnor_inputs_2 : in std_logic_vector(nr_xnor_gates-1 downto 0); -- Second inputs
      threshold_in  : in std_logic_vector(acc_data_width-1 downto 0); -- Threshold data
      register_select: in std_logic_vector(addr_width_accm-1 downto 0);
      o_data_cc     : out std_logic_vector(acc_data_width-1 downto 0); -- Output data
      less_cc : out std_logic;
      eq_cc : out std_logic
    );
  end component;

-- Typedef for register file in vhdl
type reg_file is array(0 to 3) of integer;

-- Inputs
signal rst_t: std_logic := '0';
signal input_1: std_logic_vector(63 downto 0) := "0101010101010101010101010101010101010101010101010101010101010101";
signal input_2: std_logic_vector(63 downto 0) := "1010101010101010101010101010101010101010101010101010101010101010";
signal input_threshold: std_logic_vector(15 downto 0) := (others => '0');
signal reg_sel: std_logic_vector(1 downto 0) := (others => '0');
-- Outputs
signal output_cc: std_logic_vector(15 downto 0);
signal less_cc_t, eq_cc_t: std_logic := '0';
signal clk_t: std_logic := '0';
constant clk_period : time := 2 ns;
-- constant max_clock_cyles: integer := 60;
-- Workload definition
constant alpha: integer := 64;
constant beta: integer := 576;
constant delta: integer := 196;
constant beta_minus_half : real := 0.5*real(beta/2);
constant beta_plus_half : real := 1.5*real(beta/2);
-- After how many clock cycles the accumulator should be reset
constant reset_it: integer := delta*integer(ceil(real(beta)/real(64)));
-- After how many clock cycles the reset value (0) is at the output
constant reset_delay: integer := 11;
-- Total amount of iterations (input applications) that need to be performed
constant max_iterations: integer := 100;--100000;--integer(alpha*delta*reset_it);
constant delay_cycles: integer := integer(floor(real(max_iterations)/real(reset_it)));
constant total_clockc: integer := 100;--100000;--max_iterations + delay_cycles + 10;

begin
  computing_column_test: computing_column_sm
    generic map(
      nr_xnor_gates => 64,
      acc_data_width => 16,
      nr_popc_bits_o => 7,
      nr_regs_accm => 4,
      addr_width_accm => 2
    )
    port map(
      clk => clk_t,
      rst => rst_t,
      xnor_inputs_1 => input_1,
      xnor_inputs_2 => input_2,
      threshold_in => input_threshold,
      register_select => reg_sel,
      o_data_cc => output_cc,
      less_cc => less_cc_t,
      eq_cc => eq_cc_t
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
    variable reg_file_sim : reg_file;
    variable reg_sel_sim: integer := 0;
    -- Debug signals and variables
    variable res_popc: integer := 0;

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

      -- Init all registers to 0
      for i in 0 to 3 loop
        reg_file_sim(i) := 0;
      end loop;

      wait for clk_period/2;
      while j < max_iterations loop
        if k = reset_it then
          report "Reset.";
          for i in 0 to 3 loop
            reg_file_sim(i) := 0;
          end loop;
          k := 0;
          -- Apply neutral elements
          input_1 <= "0101010101010101010101010101010101010101010101010101010101010101";
          input_2 <= "1010101010101010101010101010101010101010101010101010101010101010";
          reg_sel <= "00";
          rst_t <= '1';
          wait for 3*clk_period;
          -- Apply next threshold
          -- report "The value of 'beta_minus' is " & real'image(beta_minus_half);
          -- report "The value of 'beta_plus' is " & real'image(beta_plus_half);
          rand_threshold := rand_int(beta_minus_half,beta_plus_half);
          input_threshold <= std_logic_vector(to_unsigned(rand_threshold, input_threshold'length));
        else
          rst_t <= '0';
          -- Apply new inputs every third clock cycle
          rand_int_1 := rand_lv(64);
          -- Only apply new weights when
          rand_int_2 := rand_lv(64);
          input_1 <= rand_int_1;
          input_2 <= rand_int_2;
          -- Compute for comparison
          res_xnor := rand_int_1 xnor rand_int_2;
          for i in 0 to 63 loop
            if (res_xnor(i)='1') then
              res_popc := res_popc + 1;
            end if;
          end loop;
          -- report "The value of 'res_popc' is " & integer'image(res_popc);
          if j /= 0 then
            reg_file_sim(reg_sel_sim) := reg_file_sim(reg_sel_sim) + res_popc;
          end if;
          -- Increment number of additions
          report "The address is " & integer'image(reg_sel_sim);
          report "The popc val is " & integer'image(res_popc);
          report "The value of register is " & integer'image(reg_file_sim(reg_sel_sim));
          report "---";
          k := k + 1;
          res_popc := 0;
          if j /= 0 then
            reg_sel <= std_logic_vector(unsigned(reg_sel) + 1);
            reg_sel_sim := to_integer(unsigned(reg_sel));
          end if;  
          wait for 3*clk_period;
        end if;
        j := j+1;
      end loop;
      wait;
    end process;
end test;
