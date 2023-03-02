library ieee;
use ieee.std_logic_1164.all;
use IEEE.MATH_REAL.all;
USE ieee.numeric_std.ALL;

entity sm_rng_tb is
end sm_rng_tb;

architecture test of sm_rng_tb is
  component computing_column_sm
    generic(
      nr_xnor_gates: integer := {{ n }}; -- Number of XNOR gates
      acc_data_width: integer := {{ dw }}; -- Width of registers in accumulator
      nr_popc_bits_o: integer := {{ popc_o }}; -- Number of output bits from the popcount unit
      nr_regs_accm: integer := {{ nr_regs }}; -- Number of registers in the multiregs accumulator
      addr_width_accm: integer := {{ awa }} -- Number of addresses neeed in the multiregs accumulator
    );
    port(
      clk           : in std_logic;
      rst           : in std_logic;
      xnor_inputs_1 : in std_logic_vector({{ n-1 }} downto 0); -- First inputs
      xnor_inputs_2 : in std_logic_vector({{ n-1 }} downto 0); -- Second inputs
      threshold_in  : in std_logic_vector({{ dw-1 }} downto 0); -- Threshold data
      register_select: in std_logic_vector({{ awa-1 }} downto 0);
      o_data_cc     : out std_logic_vector({{ dw-1 }} downto 0); -- Output data
      less_cc : out std_logic;
      eq_cc : out std_logic
    );
  end component;

-- Typedef for register file in vhdl
type reg_file is array(0 to {{ nr_regs-1 }}) of integer;

-- Inputs
signal rst_t: std_logic := '0';
signal input_1: std_logic_vector({{ n-1 }} downto 0) := "{{ neutral_input_1 }}";
signal input_2: std_logic_vector({{ n-1 }} downto 0) := "{{ neutral_input_2 }}";
signal input_threshold: std_logic_vector({{ dw-1 }} downto 0) := (others => '0');
signal reg_sel: std_logic_vector({{ awa-1 }} downto 0) := (others => '0');
-- Outputs
signal output_cc: std_logic_vector({{ dw-1 }} downto 0);
signal less_cc_t, eq_cc_t: std_logic := '0';
signal clk_t: std_logic := '0';
constant clk_period : time := 2 ns;
-- Workload definition
constant alpha: integer := {{ alpha }};
constant beta: integer := {{ beta }};
constant delta: integer := {{ delta }};
constant rrf: integer := {{ rrf }}; -- Register reduction factor
constant beta_minus_half : real := 0.5*real(beta/2);
constant beta_plus_half : real := 1.5*real(beta/2);
-- After how many clock cycles the accumulator should be reset
constant reset_it: integer := integer(ceil(real(delta)/real(rrf)))*integer(ceil(real(beta)/real({{ n }})));
-- Total amount of iterations (input applications) that need to be performed
constant max_iterations: integer := 1000;--100000;--rrf*integer(alpha*reset_it);
constant delay_cycles: integer := integer(floor(real(max_iterations)/real(reset_it)));
constant total_clockc: integer := 1000;--100000;--max_iterations + delay_cycles + {{ reset_pipe_delay }};

begin
  computing_column_test: computing_column_sm
    generic map(
      nr_xnor_gates => {{ n }},
      acc_data_width => {{ dw }},
      nr_popc_bits_o => {{ popc_o }},
      nr_regs_accm => {{ nr_regs }},
      addr_width_accm => {{ awa }}
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

  -- Register select process
  regsel_process: process
    variable i: integer := 0;
    begin
      -- Wait until first input is applied, and one cycle before that
      -- Wait until right timing
      wait for ({{ sm_reset_delay_to_64 }})*clk_period;
      while i<total_clockc loop
        if (i = (reset_it-3)) then
          reg_sel <= (others => '0');
          wait for 3*clk_period;
        else
          reg_sel <= std_logic_vector(unsigned(reg_sel) + 1);
        end if;
        wait for 3*clk_period;
        i := i+1;
      end loop;
      wait;
    end process;

  -- RNG process
  rng_process: process
    variable seed1, seed2 : integer := 999; -- Seeds for reproducable random numbers
    variable rand_real_val : real; -- For storing random real value
    variable rand_int_val : integer; -- For storing random integer value
    variable rand_int_1 : std_logic_vector({{ n-1 }} downto 0) := "{{ neutral_input_1 }}";
    variable rand_int_2 : std_logic_vector({{ n-1 }} downto 0) := "{{ neutral_input_2 }}";
    variable res_xnor : std_logic_vector({{ n-1 }} downto 0);
    variable j: integer := 0; -- For iterating until there are no more clock cycles
    variable k: integer := 0; -- For counting the number of additions performed
    variable m: integer := 0; -- For counting number of iterations until new weights should be applied
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
      -- Initialize all registers to 0
      for i in 0 to (integer(ceil(real(delta)/real(rrf)))-1) loop
        reg_file_sim(i) := 0;
      end loop;

      wait for clk_period/2;
      while j < max_iterations loop

        -- Only apply new weights when the iterations went through all registers
        if m = integer(ceil(real(delta)/real(rrf))) then
          if j > 1 then
            rand_int_2 := rand_lv({{ n }});
            input_2 <= rand_int_2;
            m := 0;
          end if;
        end if;
        m := m + 1;

        if k = reset_it then
          report "Reset!!!";
          for i in 0 to (integer(ceil(real(delta)/real(rrf)))-1) loop
            reg_file_sim(i) := 0;
          end loop;
          k := 0;
          -- Apply neutral elements
          input_1 <= "{{ neutral_input_1 }}";
          input_2 <= "{{ neutral_input_2 }}";
          reg_sel_sim := 0;
          rst_t <= '1';
          wait for clk_period;
          rst_t <= '0';
          wait for 2*clk_period;
          -- Apply next threshold
          -- report "The value of 'beta_minus' is " & real'image(beta_minus_half);
          -- report "The value of 'beta_plus' is " & real'image(beta_plus_half);
          rand_threshold := rand_int(beta_minus_half,beta_plus_half);
          input_threshold <= std_logic_vector(to_unsigned(rand_threshold, input_threshold'length));
        else
          rst_t <= '0';
          -- Apply new inputs every third clock cycle
          rand_int_1 := rand_lv({{ n }});
          -- rand_int_2 := rand_lv({{ n }});
          if j > 1 then
            -- DUT
            input_1 <= rand_int_1;
            -- input_2 <= rand_int_2;
            -- Simulation
            res_xnor := rand_int_1 xnor rand_int_2;
            for i in 0 to {{ n-1 }} loop
              if (res_xnor(i)='1') then
                res_popc := res_popc + 1;
              end if;
            end loop;
            reg_file_sim(reg_sel_sim) := reg_file_sim(reg_sel_sim) + res_popc;
            report "The popc val is " & integer'image(res_popc);
            report "The address is " & integer'image(reg_sel_sim);
            report "The value of register is " & integer'image(reg_file_sim(reg_sel_sim));
            report "---";
            reg_sel_sim := reg_sel_sim + 1;
            reg_sel_sim := reg_sel_sim mod integer(ceil(real(delta)/real(rrf)));
          end if;
          k := k + 1;
          res_popc := 0;
          wait for 3*clk_period;
        end if;
        j := j+1;
      end loop;
      wait;
    end process;
end test;
