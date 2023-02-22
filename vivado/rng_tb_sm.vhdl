library ieee;
use ieee.std_logic_1164.all;
use IEEE.MATH_REAL.all;
USE ieee.numeric_std.ALL;
-- use ieee.math_real.uniform;
-- use ieee.math_real.floor;
-- use ieee.math_real.round;

entity rng_tb is
end rng_tb;

architecture test of rng_tb is
  component controller_sm
	  generic(
		nr_xnor_gates        : integer := 64; -- Number of XNOR gates used in each computing column
		nr_computing_columns : integer := 64; -- Number of computing columns used in this controller
		acc_data_width       : integer := 13; -- Width of the output of each computing column
		nr_popc_bits_o       : integer := 7;  -- Nr of bits for the popcount result
		nr_regs_accm		 : integer := 64;  -- Number of registers in the multiregs accumulator
		addr_width_accm		 : integer := 6   -- Number of addresses neeed in the multiregs accumulator
	  );
	  port(
		clk            : in std_logic;
		reset          : in std_logic;
		i_valid        : in std_logic;                   -- Only calculate values while this signal is set
		i_inputs       : in std_logic_vector(nr_xnor_gates-1 downto 0); -- Data input for input values
		i_weights      : in std_logic_vector(nr_xnor_gates-1 downto 0); -- Data input for weight values
		i_threshold    : in std_logic_vector(acc_data_width-1 downto 0); -- Threshold value to compare accumulated result
	  -- o_addr_inputs  : out std_logic_vector(31 downto 0);         -- Address output for input memory
	  -- o_addr_weights : out std_logic_vector(31 downto 0);         -- Address output for weight memory
		o_result       : out std_logic_vector(acc_data_width-1 downto 0);
		o_less         : out std_logic;
		o_equal        : out std_logic
	  );
  end component;

  
  
-- generic constants
constant nr_xnor_gates: integer := 64;
constant nr_computing_columns: integer := 64;
constant acc_data_width: integer := 16;
constant nr_popc_bits_o: integer := 7;

constant alpha: integer := 64;
constant beta: integer := 576;
constant delta: integer := 196;
-- delta * (alpha/nr_computing_columns) * (beta/nr_xnor_gates) = 1764

-- signals  
signal clk, reset, i_valid: std_logic;
signal less, equal: std_logic;


signal inputs, weights : std_logic_vector(nr_xnor_gates-1 downto 0);
signal threshold : std_logic_vector(acc_data_width-1 downto 0) := x"8000";
signal result : std_logic_vector(acc_data_width-1 downto 0);


--- rng stuff
constant clk_period: time := 4 ns;
constant max_clock_cyles: integer := 1768;  -- delta * (alpha/nr_computing_columns) * (beta/nr_xnor_gates) + 4

begin
  controller_sm_test: controller_sm generic map( nr_xnor_gates => nr_xnor_gates,
													nr_computing_columns => nr_computing_columns,
													acc_data_width => acc_data_width,
													nr_popc_bits_o => nr_popc_bits_o)
										port map(	clk => clk,
													reset => reset,
													i_valid => i_valid,
													i_inputs => inputs,
													i_weights => weights,
													i_threshold => threshold,
													o_result => result,
													o_less => less,
													o_equal => equal
										);

  clk_process: process
	variable i: integer := 0;
    begin
      while i<max_clock_cyles loop
        -- clk_t <= not clk_t after clk_period/2;
        clk <= '0';
        wait for clk_period/2;  -- Signal is '0'.
        clk <= '1';
        wait for clk_period/2;  -- Signal is '1'
        i := i+1;
      end loop;
      wait;
    end process;
	
  -- process begin
    -- a <= '0';
    -- b <= '0';
    -- wait for 10 ns;

    -- a <= '1';
    -- b <= '0';
    -- wait for 10 ns;

    -- a <= '0';
    -- b <= '1';
    -- wait for 10 ns;

    -- a <= '1';
    -- b <= '1';
    -- wait for 10 ns;

    -- wait;
  -- end process;

  rng_process: process
    variable seed1, seed2 : integer := 999; -- Seeds for reproducable random numbers
    variable rand_real_val : real; -- For storing random real value
    variable rand_int_val : integer; -- For storing random integer value
    variable j: integer := 0;

    -- Function for generating random float
    impure function rand_real(min_val, max_val : real) return real is
      variable x : real; -- Returned random value in rng function
    begin
      uniform(seed1, seed2, x);
      return x * (max_val - min_val) + min_val;
    end function;

    -- Function for generating random integer
    impure function rand_int(min_val, max_val : real) return integer is
      variable x : real; -- Returned random value in rng function
    begin
      uniform(seed1, seed2, x);
      return integer(round(x * (max_val - min_val + 1.0) + (min_val) - 0.5));
    end function;

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
	  -- init controller
	  i_valid <= '0';
	  reset <= '1';
	  wait for clk_period;
	  reset <= '0';
	  wait for clk_period;
	  -- start calculations
      while j < max_clock_cyles loop
        j := j+1;
		i_valid <= '1';
        -- report "The value of 'j' is " & integer'image(j);
        -- rand_real_val := rand_real(2.0,3.0);
        -- rand_int_val := rand_int(2.0,3.0);
        -- rlv_val_8 <= rand_lv(8);
        -- report "The value of 'rand_real_val' is " & real'image(rand_real_val);
        -- report "The value of 'rand_int_val' is " & integer'image(rand_int_val);
        -- report "The value of 'rlv_val_8' is " & integer'image(to_integer(unsigned(rlv_val_8)));
		inputs <= rand_lv(nr_xnor_gates);
		weights <= rand_lv(nr_xnor_gates);
        wait for clk_period;
      end loop;
	  i_valid <= '0';
      wait;
    end process;
end test;
