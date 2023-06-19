library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library work;
--use work.pkg.all;
 
entity threshold_rom is
port(	
    clk           : in std_logic;
	reset         : in std_logic;	
	add	          : in std_logic_vector({{weights_addr_size-1}} downto 0);	-- Adress
	threshold_out : out std_logic_vector({{dw-1}} downto 0)	-- Threshold Rom Output
);
end threshold_rom;



architecture rtl of threshold_rom is

    type threshold_array is array (natural range <>) of std_logic_vector({{dw-1}} downto 0);
	-- The Values of the Threshold Matrix
    constant Content: threshold_array(0 to {{alpha-1}}) := (
{{threshold_rom_data}}
	);       
    
begin
	-- Read Process 
    process(clk, Reset)
    begin
        if rising_edge(clk) then
            if( Reset = '1' ) then
                Threshold_out  <= (others => '0');
            else 
                Threshold_out  <= Content(to_integer(unsigned(add)));
            end if;
        end if;
    end process;
end rtl;

