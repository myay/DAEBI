{# templates/controller_sm_mem.vhdl #}

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- library work;
-- use work.pkg.all;
use ieee.numeric_std.all;
use work.array_pack.all;

entity controller_sm is
  generic(
    nr_xnor_gates        : integer := {{ n }}; 		-- Number of XNOR gates used in each computing column
    nr_computing_columns : integer := 1; 			-- Number of computing columns used in this controller
    acc_data_width       : integer := {{ dw }}; 	-- Width of the output of each computing column
    nr_popc_bits_o       : integer := {{ popc_o }}; -- Nr of bits for the popcount result
    nr_regs_accm: integer := {{ nr_regs }}; 		-- Number of registers in the multiregs accumulator
    addr_width_accm: integer := {{ awa }}			-- Number of addresses neeed in the multiregs accumulator
  );
  port(
    clk            : in std_logic;
    reset          : in std_logic;
    i_valid        : in std_logic;                   -- Only calculate values while this signal is set
    i_inputs       : in std_logic_vector(nr_xnor_gates-1 downto 0); -- Data input for input values
    i_weights      : in std_logic_vector(nr_xnor_gates-1 downto 0); -- Data input for weight values
	i_threshold    : in std_logic_vector(acc_data_width-1 downto 0); -- Threshold value to compare accumulated result
    o_addr_inputs  : out std_logic_vector(11 downto 0);         -- Address output for input memory
    o_addr_weights : out std_logic_vector(10 downto 0);         -- Address output for weight memory
    o_result       : out std_logic_vector(acc_data_width-1 downto 0);
    o_less         : out std_logic;
    o_equal        : out std_logic;
	o_finished	   : out std_logic
  );
end controller_sm;

architecture rtl of controller_sm is

  -- type mem_in is array (0 to nr_computing_columns-1) of std_logic_vector(nr_xnor_gates-1 downto 0);
  -- type mem_out is array (0 to nr_computing_columns-1) of std_logic_vector(acc_data_width-1 downto 0);
  signal mem_w : array_2d_data;                     -- signals that store the weights
  signal mem_i : array_2d_data;                     -- signals that store the inputs
  signal mem_o : array_2d_out;                    -- signals that store the output for each computing column (currently unused)
  signal mem_t : array_2d_th;                    -- signals that store the thresholds
  signal reg_sel: array_2d_regsel;				  -- Addresses of registers
  signal mem_eq, mem_l : std_logic_vector(nr_computing_columns-1 downto 0);                               -- signals that store the equal and less outputs
  signal cnt : integer := 0;                															  -- signal to store the currently used computing column
  signal reg_cnt : integer := 0;          	     														  -- signal to store the currently used register
  
  
  signal reset_cc : std_logic := '0';
  signal rst : std_logic := '0';
  
  signal addr_weights : integer := 0;
  signal ind : integer := 0;
  
  signal write_delay : integer := 0;
  
  signal ind_max : integer := {{ ind_max }};
  signal addr_weights_max : integer := 9;
  signal addr_inputs_max : integer := 9;

  signal addr_inputs : integer := 0;

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
      reset => reset_cc or reset,
      xnor_inputs_1 => mem_w,
      xnor_inputs_2 => mem_i,
	  thresholds_in => mem_t,
	  register_select => reg_sel,
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
			write_delay  <= 0;
			cnt          <= 0;
			reset_cc	 <= '0';
			rst          <= '0';
			o_finished   <= '0';
			
			
		elsif (i_valid = '1') then
			if write_delay <= 0 then
				-- set address for memory
				o_addr_inputs <= std_logic_vector(to_unsigned(addr_inputs, 8)) & std_logic_vector(to_unsigned(ind, 4));
				o_addr_weights <= std_logic_vector(to_unsigned(addr_weights, 7)) & std_logic_vector(to_unsigned(ind, 4));
				
				-- send data from memory to computing column
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
                  end if;
				end loop;
				
				
				if rst = '1' then
					reset_cc <= '0';
					rst <= '0';
				end if;
				
				
				if reg_cnt < nr_regs_accm-1 then
					reg_cnt <= reg_cnt+1;
					addr_inputs <= addr_inputs+1;
				else
					reg_cnt <= 0;
					addr_inputs <= 0;
					if ind < ind_max-1 then
						ind <= ind+1;
					else
						ind <= 0;
						if addr_weights < addr_weights_max-1 then
							addr_weights <= addr_weights+1;
						else
							addr_weights <= 0;
							o_finished <= '1';
						end if;
						
					end if;
				end if;
				write_delay <= 2;
				
			else 
				write_delay <= write_delay - 1;
				mem_w(cnt) <= (others => '0');
				mem_i(cnt) <= (others => '1');
			end if;
			
		else
			mem_w(cnt) <= (others => '0');
			mem_i(cnt) <= (others => '1');
		end if;
	end if;
  end process;
  
  

end rtl;