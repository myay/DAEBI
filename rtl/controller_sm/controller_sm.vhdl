library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- library work;
-- use work.pkg.all;
use ieee.numeric_std.all;
use work.array_pack.all;

entity controller_sm is
  generic(
    nr_xnor_gates        : integer := 64; -- Number of XNOR gates used in each computing column
    nr_computing_columns : integer := 64; -- Number of computing columns used in this controller
    acc_data_width       : integer := 13; -- Width of the output of each computing column
    nr_popc_bits_o       : integer := 7;  -- Nr of bits for the popcount result
	nr_regs_accm		 : integer := 2;  -- Number of registers in the multiregs accumulator
    addr_width_accm		 : integer := 1   -- Number of addresses neeed in the multiregs accumulator
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
end controller_sm;

architecture rtl of controller_sm is

  -- type mem_in is array (0 to nr_computing_columns-1) of std_logic_vector(nr_xnor_gates-1 downto 0);
  -- type mem_out is array (0 to nr_computing_columns-1) of std_logic_vector(acc_data_width-1 downto 0);
  signal mem_w : array_2d(nr_computing_columns-1 downto 0)(nr_xnor_gates-1 downto 0);                     -- signals that store the weights
  signal mem_i : array_2d(nr_computing_columns-1 downto 0)(nr_xnor_gates-1 downto 0);                     -- signals that store the inputs
  signal mem_o : array_2d(nr_computing_columns-1 downto 0)(acc_data_width-1 downto 0);                    -- signals that store the output for each computing column (currently unused)
  signal mem_t : array_2d(nr_computing_columns-1 downto 0)(acc_data_width-1 downto 0);                    -- signals that store the thresholds
  signal reg_sel: array_2d(nr_computing_columns-1 downto 0)(addr_width_accm-1 downto 0);				  -- Addresses of registers
  signal mem_eq, mem_l : std_logic_vector(nr_computing_columns-1 downto 0);                               -- signals that store the equal and less outputs
  signal cnt : integer := 0;                															  -- signal to store the currently used computing column
  signal reg_cnt : integer := 0;          	     														  -- signal to store the currently used register

begin

  -- Generate component of computing columns
  inst_cc : entity work.computing_columns_sm(rtl)
    generic map(
      nr_computing_columns => nr_computing_columns,
      nr_xnor_gates => nr_xnor_gates,
      acc_data_width => acc_data_width,
      nr_popc_bits_o => nr_popc_bits_o,
	  nr_regs_accm => nr_regs_accm,
      addr_width_accm => addr_width_accm
    )
    port map(
      clk => clk,
      reset => reset,
      xnor_inputs_1 => mem_w,
      xnor_inputs_2 => mem_i,
	  thresholds_in => mem_t,
	  register_select => reg_sel,
      o_result => mem_o,
	  less_results => mem_l,
      eq_results => mem_eq
    );

  -- Calculate address for input (currently unused)
  -- o_addr_inputs <= (others => '0');

  -- Calculate address for weights (currently unused)
  -- o_addr_weights <= (others => '0');

  -- control data flow
  process(clk) begin
    if rising_edge(clk) then
      if(reset = '1') then
        cnt <= 0;

      elsif (i_valid = '1') then
        -- set xnor-inputs of current computing column to weights and inputs
        for i in 0 to nr_computing_columns-1 loop
          if i = cnt then
            mem_w(cnt) <= i_weights;
            mem_i(cnt) <= i_inputs;
			mem_t(cnt) <= i_threshold;
			reg_sel(cnt) <=  std_logic_vector(to_unsigned(reg_cnt, addr_width_accm));

            -- test output for vivado testing
            o_result <= mem_o(cnt);
			o_less   <= mem_l(cnt);
			o_equal  <= mem_eq(cnt);
          else
            -- xnor will calculate 0 -> idle all other computing columns
            mem_w(i) <= (others => '0');
            mem_i(i) <= (others => '1');
			-- mem_t(i) <= (others => '0');
          end if;
        end loop;

        -- increase counter to use next computing column
        if cnt < nr_computing_columns-1 then
          cnt <= cnt + 1;
        else
          cnt <= 0;
		  -- increase register address to use next accumulator register
		  if reg_cnt < nr_regs_accm-1 then
		    reg_cnt <= reg_cnt + 1;
		  else
		    reg_cnt <= 0;
		  end if;
        end if;

      else
        -- Idle all computing columns
        for i in 0 to nr_computing_columns-1 loop
          -- xnor will calculate 0 -> idle this computing column
          mem_w(i) <= (others => '0');
          mem_i(i) <= (others => '1');
        end loop;
      end if;
    end if;
  end process;
end rtl;