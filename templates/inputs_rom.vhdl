library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library work;
--use work.pkg.all;

entity inputs_rom is
generic (
	output_size: integer := 512;		-- Number of output bits
	index_size:  integer := 1;		-- Number of indexing bits (based on output_size)
	max_index:   integer := 1		-- Maximum index allowed = beta_gamma / output_bits = 576 / 64
);
port(	
    clk       : in std_logic;
	reset     : in std_logic;	
	address	  : in std_logic_vector({{inputs_addr_size-1}} downto 0);				-- Address
	index	  : in std_logic_vector(index_size-1 downto 0);	-- Index inside the vector specified by address
	inputs_out: out std_logic_vector(output_size-1 downto 0)	-- Input Rom Output
);
end inputs_rom;



architecture rtl of inputs_rom is

	-- Array to save the Values of the Input Matrix
    type inputs_Array is array (0 to {{delta-1}}) of std_logic_vector({{beta-1}} downto 0);
	
	-- The Values of the Input Matrix
    constant Content: inputs_Array := (
{{inputs_rom_data}}   
		);       
    
    
begin
	-- Read Process 
    process(clk, reset) 
    variable i : integer;
    begin
        if rising_edge(clk) then
            if( Reset = '1' ) then
                inputs_out <= (others => '0');
            else 
				i := to_integer(unsigned(index));
				if i < max_index-1 then
					inputs_out <= Content(to_integer(unsigned(address)))( (output_size*(i+1))-1 downto output_size*i );
				else
					inputs_out(({{beta-1}} - output_size*i) downto 0) <= Content(to_integer(unsigned(address)))({{beta-1}} downto output_size*i);
					inputs_out(output_size-1 downto ({{beta}} - output_size*i)) <= (others => '0');
				end if;
            end if;
        end if;
    end process;
end rtl;
