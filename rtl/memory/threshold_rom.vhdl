library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library work;
--use work.pkg.all;
 
entity threshold_rom is
port(	
    clk           : in std_logic;
	reset         : in std_logic;	
	add	          : in std_logic_vector(6 downto 0);	-- Adress
	threshold_out : out std_logic_vector(12 downto 0)	-- Threshold Rom Output
);
end threshold_rom;



architecture rtl of threshold_rom is

    type threshold_array is array (natural range <>) of std_logic_vector(12 downto 0);
	-- The Values of the Threshold Matrix
    constant Content: threshold_array(0 to 63) := (
        0   => "0000000110110",
        1   => "0000100010001",
        2   => "0000110100101",
        3   => "0000110001011",
        4   => "0000000100010",
        5   => "0000100101000",
        6   => "0000011000110",
        7   => "0000100010110",
        8   => "0000011101111",
        9   => "0000101001001",
        10  => "0001000011110",
        11  => "0000001000101",
        12  => "0000011010011",
        13  => "0000000010101",
        14  => "0000000000110",
        15  => "0000111000100",
        16  => "0000101011111",
        17  => "0000010110011",
        18  => "0000100011000",
        19  => "0000001101111",
        20  => "0000001010110",
        21  => "0000111001100",
        22  => "0000100101101",
        23  => "0000101111011",
        24  => "0000010010000",
        25  => "0001000111111",
        26  => "0000101110111",
        27  => "0000110110001",
        28  => "0000100001001",
        29  => "0001000010001",
        30  => "0000001010100",
        31  => "0000100010010",
        32  => "0000000000110",
        33  => "0000010011101",
        34  => "0001000110111",
        35  => "0000001000110",
        36  => "0000011111100",
        37  => "0000010100110",
        38  => "0001000000101",
        39  => "0001000011011",
        40  => "0000010000111",
        41  => "0000101000111",
        42  => "0000101111110",
        43  => "0000111011010",
        44  => "0000110010001",
        45  => "0000001111100",
        46  => "0000000110100",
        47  => "0000000111111",
        48  => "0000001100100",
        49  => "0000111111111",
        50  => "0000011001000",
        51  => "0000011100000",
        52  => "0000101101011",
        53  => "0000101110001",
        54  => "0000101111110",
        55  => "0000000001011",
        56  => "0000011010001",
        57  => "0000000111000",
        58  => "0000010010010",
        59  => "0000010010001",
        60  => "0000011100000",
        61  => "0000011101001",
        62  => "0000111111100",
        63  => "0000000111011"       
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