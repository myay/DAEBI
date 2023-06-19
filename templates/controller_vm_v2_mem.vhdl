{# templates/controller_vm_v2.vhdl #}

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- library work;
-- use work.pkg.all;
use ieee.numeric_std.all;
use work.array_pack.all;

entity controller_vm_v2 is
  generic(
    nr_xnor_gates        : integer := {{ n }}; -- Number of XNOR gates used in each computing column
    nr_computing_columns : integer := 1; -- Number of computing columns used in this controller
    acc_data_width       : integer := {{ dw }}; -- Width of the output of each computing column
    nr_popc_bits_o       : integer := {{ popc_o }}   -- Nr of bits for the popcount result
  );
  port(
    clk            : in std_logic;
    reset          : in std_logic;
    i_valid        : in std_logic;                   -- Only calculate values while this signal is set
    i_inputs       : in std_logic_vector(nr_xnor_gates-1 downto 0); -- Data input for input values
    i_weights      : in std_logic_vector(nr_xnor_gates-1 downto 0); -- Data input for weight values
	i_threshold    : in std_logic_vector(acc_data_width-1 downto 0); -- Threshold value to compare accumulated result
    o_addr_inputs  : out std_logic_vector({{inputs_addr_size + ind_bits -1}} downto 0);         -- Address output for input memory
    o_addr_weights : out std_logic_vector({{weights_addr_size + ind_bits -1}} downto 0);         -- Address output for weight memory
    o_addr_threshold : out std_logic_vector({{weights_addr_size-1}} downto 0);         -- Address output for threshold memory
    o_result       : out std_logic_vector(acc_data_width-1 downto 0);
    o_less         : out std_logic;
    o_equal        : out std_logic;
	o_finished	   : out std_logic
  );
end controller_vm_v2;

architecture rtl of controller_vm_v2 is
   
--  type mem_in is array (0 to nr_computing_columns-1) of std_logic_vector(nr_xnor_gates-1 downto 0);
--  type mem_out is array (0 to nr_computing_columns-1) of std_logic_vector(acc_data_width-1 downto 0);
  signal mem_w : array_2d_data;                  -- signals that store the weights
  signal mem_i : array_2d_data;                  -- signals that store the inputs
  signal mem_o : array_2d_out;                   -- signals that store the output for each computing column (currently unused)
  signal mem_t : array_2d_th;                    -- signals that store the thresholds
  signal mem_eq, mem_l : std_logic_vector(nr_computing_columns-1 downto 0);                               -- signals that store the equal and less outputs
  signal cnt : integer := 0;                 -- signal to store the currently used computing column
  
  signal reset_cc : std_logic := '0';
  signal rst : std_logic := '0';
  
  signal addr_weights : integer := 0;
  signal ind : integer := 0;
  
  signal ind_max : integer := {{ ind_max }};			-- beta_gamma / output_bits
  signal addr_weights_max : integer := {{alpha-1}};	-- nr of weights
  signal addr_inputs_max : integer := {{delta-1}};	-- nr of inputs

  signal addr_inputs : integer := 0;
  
  

begin

  -- Generate component of computing columns
  inst_cc : entity work.computing_columns_vm(rtl)
    generic map(
      nr_computing_columns => nr_computing_columns,
      nr_xnor_gates => nr_xnor_gates,
      acc_data_width => acc_data_width,
      nr_popc_bits_o => nr_popc_bits_o
    )
    port map(
      clk => clk,
      reset => reset_cc or reset,
      xnor_inputs_1 => mem_w,
      xnor_inputs_2 => mem_i,
	  thresholds_in => mem_t,
      o_result => mem_o,
	  less_results => mem_l,
      eq_results => mem_eq
    );

  -- Calculate address for input
  process(clk) begin
	if rising_edge(clk) then
		if(reset = '1') then
			addr_weights <= 0;
			addr_inputs  <= 0;
			ind          <= 0;
			o_finished   <= '0';
			
		elsif (i_valid = '1') then
			o_addr_inputs <= std_logic_vector(to_unsigned(addr_inputs, {{inputs_addr_size}})) & std_logic_vector(to_unsigned(ind, {{ind_bits}}));
			o_addr_weights <= std_logic_vector(to_unsigned(addr_weights, {{weights_addr_size}})) & std_logic_vector(to_unsigned(ind, {{ind_bits}}));
			
			if rst = '1' then
				reset_cc <= '0';
				rst <= '0';
			end if;
			
			if ind < ind_max-1 then
				ind <= ind + 1;
			else
				ind <= 0;
				-- reset computing column
				reset_cc <= '1';
				rst <= '1';
				if addr_weights < addr_weights_max-1 then
					addr_weights <= addr_weights + 1;
				else
					addr_weights <= 0;
					if addr_inputs < addr_inputs_max-1 then
						addr_inputs <= addr_inputs + 1;
					else
						addr_inputs <= 0;
						o_finished <= '1';
					end if;
				end if;
			end if;
		end if;
	end if;
  end process;


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
