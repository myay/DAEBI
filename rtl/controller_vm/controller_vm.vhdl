library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.numeric_std.all; 
-- library work;
-- use work.pkg.all;
 
entity controller_vm is 
	generic(
		nr_xnor_gates        : integer := 64;		-- Number of XNOR gates used in each computing column
		nr_computing_columns : integer := 64;       -- Number of computing columns used in this controller
		acc_data_width       : integer := 16		-- Width of the output of each computing column
	);
    port (  
        clk            : in std_logic; 								
        reset          : in std_logic; 	
		i_valid        : in std_logic;									 -- Only calculate values while this signal is set
		i_inputs       : in std_logic_vector( nr_xnor_gates-1 downto 0); -- Data input for input values
		i_weights      : in std_logic_vector( nr_xnor_gates-1 downto 0); -- Data input for weight values
		-- o_addr_inputs  : out std_logic_vector(31 downto 0);				 -- Address output for input memory
		-- o_addr_weights : out std_logic_vector(31 downto 0);				 -- Address output for weight memory
		o_result       : out std_logic_vector( acc_data_width-1 downto 0)
        ); 
    end controller_vm; 
 
architecture rtl of controller_vm is 

	type mem_in is array (0 to nr_computing_columns-1) of std_logic_vector(nr_xnor_gates-1 downto 0);
	type mem_out is array (0 to nr_computing_columns-1) of std_logic_vector(acc_data_width-1 downto 0);
	signal mem_w          : mem_in;										 -- signals that store the weights
	signal mem_i          : mem_in;										 -- signals that store the inputs
	signal mem_o          : mem_out;									 -- signals that store the output for each computing column (currently unused)
	signal cnt            : integer := 0;								 -- signal to store the currently used computing column

begin 
 
 
	-- Calculate address for input (currently unused)
	-- o_addr_inputs <= (others => '0');
	
	
	-- Calculate address for weights (currently unused)
	-- o_addr_weights <= (others => '0');
	
	
	-- control data flow
	process(clk)
	begin
		if rising_edge(clk) then
			if(reset = '1') then 
				cnt <= 0;
			
			elsif (i_valid = '1') then
				-- set xnor-inputs of current computing column to weights and inputs
				for i in 0 to nr_computing_columns-1 loop
					if i = cnt then
						mem_w(cnt) <= i_weights;
						mem_i(cnt) <= i_inputs;
						
						-- test output for vivado testing
						o_result <= mem_o(cnt);
					else
						-- xnor will calculate 0 -> idle all other computing columns
						mem_w(i) <= (others => '0');
						mem_i(i) <= (others => '1');
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
 
 
	-- Generate computing columns
	gen_cc: for i in 1 to nr_computing_columns generate 
		cc_inst: entity work.computing_column_vm(rtl)
		generic map(nr_xnor_gates => nr_xnor_gates,
					acc_data_width => acc_data_width)
		port map (
			clk           => clk,
			rst           => reset,
			xnor_inputs_1 => mem_w(i-1),
			xnor_inputs_2 => mem_i(i-1),
			o_data_cc     => mem_o(i-1)
		);
	end generate;

end rtl;