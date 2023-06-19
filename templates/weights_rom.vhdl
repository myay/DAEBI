library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library work;
--use work.pkg.all;


entity weights_rom is
generic(
	output_size: integer := 512;		-- Number of output bits
	index_size:  integer := 1;		-- Number of indexing bits (based on output_size)
	max_index:   integer := 1		-- Maximum index allowed = beta_gamma / output_bits = 576 / 64
);
port(	
    clk         : in std_logic;									
	reset       : in std_logic;										
	address	    : in std_logic_vector({{weights_addr_size-1}} downto 0);				-- Address
	index		: in std_logic_vector(index_size-1 downto 0);	-- Index inside the vector specified by address
	weights_out : out std_logic_vector(output_size-1 downto 0)	-- Weights Rom Output
);
end weights_rom;

architecture rtl of weights_rom is
	-- Array to save the Values of the Weights Matrix
    type weights_Array is array (0 to {{alpha-1}}) of std_logic_vector({{beta-1}} downto 0);
	
	-- The Values of the Weights Matrix
    constant Content: weights_Array := (
{{weights_rom_data}}
	);       

begin
	-- Read Process 
    process(clk, Reset)
    variable i : integer;
    begin
        if rising_edge(clk) then
            if( Reset = '1' ) then
                Weights_out <= (others => '1');
            else 
				i := to_integer(unsigned(index));
				if i < max_index-1 then
					Weights_out <= Content(to_integer(unsigned(address)))( (output_size*(i+1))-1 downto output_size*i );
				else
					Weights_out(({{beta-1}} - output_size*i) downto 0) <= Content(to_integer(unsigned(address)))({{beta-1}} downto output_size*i);
					Weights_out(output_size-1 downto ({{beta}} - output_size*i)) <= (others => '1');
				end if;
            end if;
        end if;
    end process;
end rtl;
