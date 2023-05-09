{# templates/controller_multi_sm_mem.vhdl #}

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- library work;
-- use work.pkg.all;
use ieee.numeric_std.all;
use work.array_pack.all;

entity controller_multi_sm is
  generic(
    nr_controller        : integer := {{ m }};  
    nr_xnor_gates        : integer := {{ n }}; 		-- Number of XNOR gates used in each computing column
    nr_computing_columns : integer := 1; 			-- Number of computing columns used in this controller
    acc_data_width       : integer := {{ dw }}; 	-- Width of the output of each computing column
    nr_popc_bits_o       : integer := {{ popc_o }}; -- Nr of bits for the popcount result
    nr_regs_accm: integer := {{ nr_regs }}; 		-- Number of registers in the multiregs accumulator
    addr_width_accm: integer := {{ awa }} 			-- Number of addresses neeed in the multiregs accumulator
  );
  port(
    clk            : in std_logic;
    reset          : in std_logic;
    i_valid        : in std_logic;                   -- Only calculate values while this signal is set
    o_result       : out std_logic_vector((acc_data_width*nr_controller)-1 downto 0);
    o_less         : out std_logic_vector(nr_controller-1 downto 0);
    o_equal        : out std_logic_vector(nr_controller-1 downto 0)
  );
end controller_multi_sm;

architecture rtl of controller_multi_sm is

	signal inputs       : std_logic_vector( nr_xnor_gates-1 downto 0); -- Data input for input values
    signal weights      : std_logic_vector( (nr_xnor_gates*nr_controller)-1 downto 0); -- Data input for weight values
	signal threshold    : std_logic_vector( (acc_data_width*nr_controller)-1 downto 0); -- Threshold value to compare accumulated result
	signal addr_inputs  : std_logic_vector( (nr_controller*12)-1 downto 0);         -- Address output for input memory
    signal addr_weights : std_logic_vector( (nr_controller*11) - 1 downto 0);         -- Address output for weight memory
	signal addr_threshold : std_logic_vector( (nr_controller*7) - 1 downto 0);         -- Address output for threshold memory


begin

  -- Generate controllers
  controller_vm_gen: for i in 0 to nr_controller-1 generate
	  inst_controller : entity work.controller_sm(rtl)
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
		  i_valid => i_valid,
		  i_inputs => inputs,
		  i_weights => weights((nr_xnor_gates*(i+1))-1 downto (nr_xnor_gates*i)),
		  i_threshold => threshold((acc_data_width*(i+1))-1 downto (acc_data_width*i)),
		  o_addr_inputs => addr_inputs( (12*(i+1)) - 1 downto 12*i ),
		  o_addr_weights => addr_weights( (11*(i+1)) - 1 downto 11*i ),
		  o_result => o_result((acc_data_width*(i+1))-1 downto (acc_data_width*i)),
		  o_less => o_less(i),
		  o_equal => o_equal(i)
		);
  end generate;
  
    weights_rom_gen: for i in 0 to nr_controller-1 generate
	  inst_weights_rom : entity work.weights_rom(rtl)
		generic map(
			output_size => {{ n }},
			index_size => 4,
			max_index => {{ ind_max }}
		)
		port map(	
			clk => clk,							
			reset => reset,
			address => addr_weights( (11*(i+1)) - 1 downto 11*i + 4),
			index => addr_weights( 11*i + 3 downto 11*i),
			weights_out => weights( (nr_xnor_gates*(i+1))-1 downto nr_xnor_gates*i)
		);
  end generate;
  
    threshold_rom_gen: for i in 0 to nr_controller-1 generate
	  inst_threshold_rom : entity work.threshold_rom(rtl)
		port map(	
			clk => clk,							
			reset => reset,
			add => addr_threshold( (7*(i+1)) - 1 downto 7*i),
			threshold_out => threshold( (acc_data_width*(i+1))-1 downto acc_data_width*i)
		);
  end generate;
  
  
    inst_inputs_rom : entity work.inputs_rom(rtl)
		generic map(
			output_size => {{ n }},
			index_size => 4,
			max_index => {{ ind_max }}
		)
		port map(	
			clk => clk,							
			reset => reset,
			address => addr_inputs( 11 downto 4),
			index => addr_inputs( 3 downto 0),
			inputs_out => inputs
		);

end rtl;
