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
	address	    : in std_logic_vector(6 downto 0);				-- Address
	index		: in std_logic_vector(index_size-1 downto 0);	-- Index inside the vector specified by address
	weights_out : out std_logic_vector(output_size-1 downto 0)	-- Weights Rom Output
);
end weights_rom;

architecture rtl of weights_rom is
	-- Array to save the Values of the Weights Matrix
    type weights_Array is array (0 to 63) of std_logic_vector(575 downto 0);
	
	-- The Values of the Weights Matrix
    constant Content: weights_Array := (
        0 => "111101011011110001111101010110010101111100101100001010001000001000101010111000000001101011010100101010110111010110101111111101001010001111101001110111010101110010111100101000100110011011111000011000000100001011101001001111010110110010000001101010100001111011100001110100110101111101100010010010100111110000001010001001110000001100010111001000001010111001110001011010101110110011011011111010000101000001011000100000000001110010101001011010100110001111010010101100010000101111111110000001011101101000010011011000001111001110010011000010001111011110111010011000111011111111100010",
        1 => "010101001000011111010001001010001000100011010111111100000111001111100011100100100001010000101100101111000001011110101010001100000000010110000101110101111010000101000100101111011101000010001110111000100011001100000010101100000100111011010100001100000101101011101001000101100111011100001100110010101000001110111011010001101100100011000010101100101101111010100001000100010010110100000111010000010110111010011111101101000110110110010110011000000011011111001000111000010011001101000010011110001001100100100111010111011100110101110101111000000000101111101111010010101101000100010101",
        2 => "001101011001001011000111001011100011111100011000011110110101101100111110100101000000100000101111101101100111010111101100111110110100010000011001101010011110111000111111100011100101101011000111110001000110001111011110111110010100101011100001011111110000110011011000000100000011110000010111000100111110110111101101110011010100101100011111000101100000010011111100011011011111110101011001111001000011011110010011110110000011000001111111111010110001011010011010111000111000001111111101000010110010111010000110101110101001001100111000111000011110100101011110010001000100010111001000",
        3 => "000000000110110111000010100011010101011110110100000111101000101101111110101000101111111100111001111100010110101011001101000000100110100000011111000100101000100101111101110111101111110100001100010011011000010100101101100011110101110001101000101000010110110110001101010110111010101000000000010100011000101100111110100101101010101001100011100011011000101100111110100001001001001111110000001111001000100110011100100011001110111101001000011111001101010110111010111011111111010001011011111011100001100110011110010000001100001101111001011011110101000110010011011101110110010100111110",
        4 => "011011111010110010111001101000111001001111000000001011000100011000000100111100000001001110000011110111010011100000000101010001101101000100110111101010101001010111001100110100010111011101101010110110111000011101111100001100101001111110101101011101011101110011001000000110101001011111000001010000110111011110111010001001111110111010111000111010101011001000111101001010110111101111001101100101000110011110011111000011000010101100101010000100110010010000100010011010010010000010010010110110111001011000001101000110100010100110101100100110000111011010010000111101000101100100010010",
        5 => "101101111010111100100011101000001000110111101010000100111110011011000110000110100111000101010000010110010110110001011011011110100101000011101011110011010001000110100100010011101100011011101001001000011010000110111110110001011011100101000110110110000000110111100100110111110100011110000111011010000000000111010000111111111011000110010001101000100100100011001111001110011010101000101111010011000111011100000011110001100101001110110110101000000011011010110101110010000110010010001000101110110101001011101111110011100101011101000100001110000100111100111001111010010100010000101010",
        6 => "001010011111000010001100101111000011100100011010110010111001010110110100000001001001110100100000100111011011101101101001110010000110011010000110011100111110000010110100100011001010010100011100111100011000110011000111000111010000010111001100010110011111111100000000000000100100001101010001010011101101001101011110011101001010101010101011010101000100100001111100100001110000111100001110001110100101100001010000011110110011001010111110000011100010100000101001100010100100010100011010000011000100010100110010110101000101110111000010010000000000011001000001110011110110111110100110",
        7 => "000110001000010100100101101101101001111011100001100000111010010001000110101100100111110110001011010011010110110110111101001110010001001001001011100110100010101101110100100101101011100100001111011110100010100110111011010011101011111111010100101100100000000010101010111010011100000101111000100010101101011001010111111110000101011000101101001000011111110000011011110000010011001100100010010000100001010101010101100010011110101111100010011100101111011110101111110100110100010110010011010101101110111100000000100111101100110100011001000110111100001100101001101110101001001001000011",
        8 => "011100100111110011100111110011010100010011001001000000111100001101010010111000010100101001101010101010011111000111101001000100101110000001100111101001010010101000001111000000000101111100111001011010001101001000000001001101000011000001010101110001101101111000101110010111110110111101101001011011000010011101000101010101101100110000001111010011010100001100010001001011001101110101010000001000010000010000111001101111000100011111001101010001100101010111111011010001100110001001111101011100111100101100011110111100000001001011010110001101001000001010010000001000100010101000010011",
        9 => "110010010000111010001001010011100001001011000111101110101011000011000011101111000110011011110111101100110001011111011001110100101010101110110011101100111010001001010010010001110000010010111110110010001010011010110000110000011011110100011000111000001110100111010111011101001001000101100000011110011111011000110111011001101101000100101011100111010111111011111110011101111100110010001101010011000111010010010110101011000011101111110110011010011001101001111000001110011000000111011101001110000100010100000100111010011100000001001001010000010101100000110010101010100110001111011001",
        10 => "100111011110101011100111111010110110000011101011101000111001000100011010100100000010110000001000111001010010111110010111010101010010101001000011101111010100100011010101110011011100100000010011000010111101000110011000110011111100010011000100001100001101110110101101000111000000111110010001000110111100100001111001101011000000101111011011011010101010010000110100000111011100001111110010011101000100000001000110110111010001111010010010111101010100000100100110101100001100010001111101110110110110011101101001000011110100111111111100001000100011111111111100110100011101101100101110",
        11 => "101000000101010111100000111101001011100101000111010010110010100001100001100111000111011110011101011101100000101100001110001111010001011011101111001010010100001010100101001100000111000000110111001101101010001011110010100100011101010001111000101010100111001000101100100011000110000000000101100100010100010010001001010000110011101110010101100111101011000110110110100010100111001001111100000100100010110010000001000001110001111010011110011111010011110111101000100110110010101110101010011010011001001001010110100100100011001110011001111101001001110100111110111110111101011010011110",
        12 => "110101001011010101000101001010110000001000001000001001001010010100111000101111110110011111110100011000100101011010010101001000110100000100010000101110011100101011011111100010100010101000011000001010011000101000001011001111110110001101111010001010001110010001111111001010011010010011111111011011101101000011101010011000001110111101010111011001101010100010000110001100100011001000010110110010111010111011000110100111111000011111110011011100010100110110011110001110110101001111010010111110111000011110110111000110000100111011001110101101101010101100011000101011101001001001000100",
        13 => "100101011001100101011111010011000010101100110111011101010100011001101011000010001110110110010010100001011101000010100110010100000001111111010110110001110110010100001110000110100100000001110100110001010100111011111100000000001000110110100111010110001001100001100010111010011110010100101000100101000100100010110101110100110101011100010101011111111111001000010011000001011111000111111000101000001000000011110010100110010110010111111010010000101010001001000101110110110101110111001111000010001101010101011010101111110010000011010110111000111001011010110111001001100001111100000000",
        14 => "010001010111100101010011000000001011101101001110000110101001011011110100100111110100100100101000001111110100011000011110010011110010010101100110010111110000110111100001101001111000101001100100001000001101011000001010000010111010010011001100001011010010010010111111010100001101011011000000000100011101100010110010100011010101111101101101110101110000101011010100101111001001000101110101101101000111111100111011110101011000111000111101011011101011010011011001000100010000001110110011010010000110110010001011101000111110000001111110010111010010110010010111000110000101111011000010",
        15 => "011100011010100010111011100111110010011100101000101001001101111111000111111010101000111011001011011110010100100001111011001100000000110110111000000010010110111010010110110111101110000101100001011000110101101111001011010110011000100101010001101100000111111010100110001000100000101111100100111111010011100000001011000011100100000101111101110001101000111001010011111001010101110000011011001001001101100101001010101111110101000110010011101001000011100001001101000000011101000010001000000101110010000110101111100001101000001010000101111111001011011111100100010000000001110000100111",
        16 => "011001111011111010011010001001010001000110100010111000110111110010100011101100110000010110111010111111011010000101000101111101001110000100111100001100111101110101001010110010010000010001101111000111000101100111101100110000110011110000000100011011100010110100101010001001100100011100000100100010000100101001100100110101011111110111001110010001010010111110001101001001100101010100100010100010110000100101011011000111101010000111101101001001010000010110110100010011101011011111011000100110111010111001101001101101010000101011101110111000111111100101011111110100110001101110011100",
        17 => "100101100110000101011110110110111011111101001001101010100111010001110101111010100110011100110110010010110110101110011100100011101100111011011100100001100001110001000010101000001101011100110111101111100011010110000100011010100010110111100010110100111011100100001011000111110101010001001100000010101101001010011110101000010000000001110111011001101110111101000010011000011110001000100100010100101011110000101101110000011011110100000001000110011111011100011000101110000101101010101011100001001100001000001100000010111000011100110100001111110101111100100010000011110010100010100001",
        18 => "001100011110011000010100000000011110111110010000111111010000011101011000100111011011001001000110110000101110100001111000110111101011111001011100010010011111100111001101100000010010110011111000011000001010111010111101101000101101111010101101110000111110011001011101000100101110001000001111101010100001101111010000001101011000010100010000100000110010100000011110110100010001110000000110000100000100011001100110001111110011010011100011011110110100010010000110111111010111101111100011101010010111110100001010010101010000000100101100110010100001100111000011001100001101100010001110",
        19 => "010010111101001100000011101111111110110010100000110000100000111100110001101010010010011010000101100101110111010000001011100010010111111011001011111011110100101010100100001001010011011110010100101010111111110000101010101100010110001011100010111110100000010010110101100111111010001110011011111101000110011000000001100011111101111001011011111101101011000001111100100000011110000100001100101000010011110010011100001001110011100111100101010110101110011001000100101101010010001010111100101101101101001010000100110000010001011100000010000001100000011001000011000011010110101110110101",
        20 => "110001110111110110000111000101001101011010111111101110000110000001101010001001111001111110111010110011000001000000011010100011010001010000010001100100100100111010101111100011010101110001011100100011100000000100110010110011001100000110011001001101111100000101001111010001000010101011100100100100101011110010011111101011101001100111010101011001111111001101010101010101111110100001001010001010010100011000001101010000101011011101011100100001011111010111100001111110101001000101100111110000111101110111000111110011110101000001111100010011011100001000011100100010110101000001000011",
        21 => "001000111111001101000101000000001000011001101011001010110101011110000100001010100000010011011101000110001000001101111101001111000101001011001011101011011010101111100000010101011010000101010011010000100101101001101001001111111100101100001001100010111000101110010101101011111001011000011001100000100000110000110101100110011101001001001100110100101101001011010101101110011011100001000110100111100001000100101111110011000101011111111001011001010011000100001110001100001001000111010011011000101111100001100011101011111001011101101111001011111001110110001011110100001111001010101011",
        22 => "111001100000100000001010101011010011011100000011100101111000110011000000111000101111001001101100111100010000010101111111110100011010010011101100010000111011100101101011011111010010000111110100100010110011101111001110000001111111111101110101010111110111110101011110011001110101011000110100000001111000101101010010110011000101011100010001010101001111000100010010100100010001000100110010110011100110111100100111101101100101001001100001010010110010101101111000011111110010000001000110101101110100000001100011000001100101100101011000100100000111100010000101011100000000010010011010",
        23 => "110100011111111010000100011101101100001011101010001101011111001001110110100101101111111000111110100101100100000010001001011101111000110100100000111101000100101010101001101000011110111111011110100101100110100001000110101001000101111000110100000101100110110010111111010100011011011100000011000011000010111101001011111001110011110000001001011001001100110101011111000111101111100111111111001001110000000111110111001100000011011010100000011001110001100111011010000101000101010001110111101101110110111011110100101001110101011000100000111001111000001000101111111000111001111001101011",
        24 => "010110101110101010001010010001111100011100011100010101110101000001101101100110000000111101101100011101100100101111110101111000111110101001011100010111011110010100010010110111100001001011001001000111100001000110001000011110011100001000111100001100111100000000011010010101101111110001000110100100111010110010000110000010110010110101101101011000001101111111100110110100101111110110010100000100110110111000111100000100101111000110100010111100011100010110000000000100111111001101101110000110111111010000000110000100001000001101100110000000101100001011000000001110110110000111010010",
        25 => "010001001110001010111001001110100000111010000000110100101000010101111010111101100101100001100000001100010011010001111110100110101010000010101010110000100010100011110100011011100101001010111100001000011101110110110011000001010110110111110100010010101010111011100000000110000001001010010101101001101011001011101101010110100010111011110000001000011010111100000000001110000101101101110101010010101111000101111000011110000001101111000000001010110110011100010100000101101111011001101111101001101011001011100001011100011011010000001000100001110101010110001011111001001100001011110110",
        26 => "110011010101100000100100011011110000011001100101001010011010100010000001111001110000100101101000100111111010100101100101111111000101000001100010011100110111000011110100111110111000101001011111101000000110101110111111011110111001111000000101001011110011110100110000010011111011100000011010010001110011000110110011111101000011101111001000110010111000001000010011011101001101011111101100010001101000010010001100101100011110001011001111001000001010001100001001110110001000111101100101010111101011010111010010101011001001000101010001111000001111110111111100000101000001100111100000",
        27 => "011110011000100000111101010100111101111000010001100100000001101000000100101001010100110010011000010010001110100100100010000011011110100101110100101000000110101010011000001011011010010000000110110110110110101110000101000000101001110010001110011011001110001000111000000010010100000111101010101001000000101100111001000110100001010100000100100100000111010000111010101000011001101011000100001101001010110101001110100011011110010100110110101011100111001001000000110101000010101111000111011011100100000110011111000110000110110111001011101001101000110011010101000011100000011110111000",
        28 => "011110010111000101110100101110100011111101100000011100000100011111000000000111111101011001010101111001010011111101000010011001100110000111101011100010110000110000100011101110011110001111000001000100010101000001111111110101100110110101000000011101011111001011111000011101110110100110101100111010111111100000010100000100010000010100010101001111001101100011111001110100101111010010111010101101100000010010010110001001111110101000100100001110111110100111101000010001111111100100000111011001010010010011110011000111111010010101101111110010100101100001011000000101000100110111111101",
        29 => "010000011100011100100110010011011100001101101111111110000110010000100110000011011001100100111111000110100100101110000010101010101010100000101001110011000100001011110010100101010110000011000111010011001011111111101010011011110001010111011010100011110011010010011000010010010010100111000110101010111010101100110110000101110010110100110100001010001000001001000110011000011000000110100011101000101101111011011110110010001110111010011101011011100111001000100010000011110000101101100100011000001110111011001011100110110001010100111111101000010110010011011001011110101101110101111000",
        30 => "000101111101001001001100111010100100101000011110011110110000010001001010110110111100001001011101101001100100100100100011010100000101100110111001100010111000100101111010110110001111010100000100111100111011111111011100100111101101100001001100011101010110101100110101010000101100101010111011011000011000111000111010011111101001010100010001000110001101110010010010111010011111000111010100101000101101110001011000100110010011100111000110110011010000101101101110101111101011001100010100101111000001010111111101101101010100101011010010111110110101101111101100010100000001011110011101",
        31 => "001101010100101111011010000001011101101011010010100101100110011000101111100101110001111010001011010011111100100001101100100111101001100010101101110001010010011000111001110010111100010101110000001110000101011010101100110001100000100110110001100000101111000000001110100011101100001111001111001101010111111100111010100101011101011010101001111101101111111011000100111101001011111110111110110110111110001110001110101011011101100000011000101101010001100001010100111101001001011010110101011101000010001101001110110111101110010010101001010000010000101111001100100011001011011000111000",
        32 => "100110001011111011111001010010001000001001001010000011100010000101000011010101000101111001011100010000000011011100001100110001110110001111010100010000111110110001011100101010100011010011000111000101011101000111010111000011001101110000110000100001000100011111011001010111011000010101111001101111100111100101011010011000100011111111001111010111111110110100110001011010111100001110000100001000101100100001010100011101110101010110101011101010010110110000011101100111000000111011110000000111110001100000101010001011011011100000110101001011100101000011010011110111101110100101000001",
        33 => "110101000011011110110111000110101100011101001000010100101111110110100000111001111011111110110101110000101010110110001111110000111101100110010111000101001001101011110001100011000111111110101111000100111001101011000101010011111100000010001100111011110000000001001110111100111111000001101000100111110111101011001111100110111111101011110110101000100011000001010111011001100001111010010000110011111000110011000100011010111111110011010110110001010011100101010001011011110001101110111100010000000100001001011111111011110000011101010100110001100101100100001000001101011110100000010101",
        34 => "010110001101001101110100101000101111010010101010100001011110011010000010101100100101101010111001110110101010101000101000101101011011100111000101100000110111100100111101010100011010111000110110011111100011100111010100101000001111001011100110111000010100100101101011111111010101001010001000110111101101011010001010111110001011010000001110111001111000011111001001100110001010001010110000100110001011001101010111111100010010111110111001011000000000000110000010011011010010110111010010001100110010011000110110111111011000100001111001111011110010010111101001011001000101100100110001",
        35 => "000010101000101100110000100011101000101101011000010110110011011010001000001011100101111001111011101110100010101001000111010000011001111100001110111011111011000100010111000101010110101101101101110001110101100100101101000110001010001101111110111011111011010101110000111111010010000000101010001101001100100001010011010000011011010111010100110010111110001001010010101111111111000010001111101011101000101100110011000111010101101000101010110001101110110001110010110001111101010000011100010101011111110010111000100010011100100010000001110110111001000111000010001010111100000110011011",
        36 => "011011001101110111110001100011111001111111001100111001000011111000010011001101111110000100011111111101101010000110101001011110011110101110001010000011101110110101010111001101000100011011111001111010000011100011100101011101101111110011000111111001111010100101011011101111010100011111110101001000110001101001011100011110011111101010101100011000000011110010001011001011011111001101110101011011111010101001111001011101101111111001011010100011101011100111000110100010100100101010010100101111010001000100101101101001100101111000100100101011011001000001000111110100101111001110111111",
        37 => "111000011111011001011001001111111110111011111000011011100111000100011011001111010011110110111000100011001110101101000110011110111010100000101100000000000001101100110110010110010101100011010011011011001111100001010100010110101000001010110011000010111010011100111000111101110001010000001101110101100010011100110100001111011100111110011001010001100101111011000100010101011101001101011011111000001100001110101110101010001100101101001110101100000101111011101010010001011010100111010111000110110111101000111010011001111001110011010100000001010110000010101111010101101000010100011000",
        38 => "001111010011100010110001011001101100001110100010001111101110110010000101101110011000100011110000110000111101110110011010001011100001111010000000100111010000100110010100010111100010010011100001000100101011110001100110100010110001000011110101010101000011111010100111111000011010100101111111100000110001110010001010000011101001110000000101111000000000101111000100101111111100000110111101110001100110000100001000111000101111001000011101011001101011110000101100001001001010000010001011110101000100110011001111001010001010111011101010110001001111100101101111111111010110101110111110",
        39 => "001011011010111010100110010111111000100011111011111110001101010111011101011010111001011000000100001001000101000001100001110110000000001101111000000100010100010010010110001111101001000000011111111010101011100110101100101010000101010011110001101000100111100110111000010011001110101000101111010010111111010100000100101001000011110000110111011010010110111110100000111100001010000000111001010110011010111111100001011010010011011110110001100110101001100001111111111110011101100000111100100010110110000001101001001111000001001110101100101010000000000111101010111001010111100101000101",
        40 => "101111011000111110010010111110100111000101111010100001110100000000000000111111100100101000001110000111111001011111000010000111010000010100011110001110111011011100101000001110111001010001100001010001000001110100100000101011110001010001111101100001001011111011000111000010111001000011100101000101000001011100001010100110010101100010001001110011110011011011001111001000101100010010011110001010010001000011110111010011010100100100011011011000110100001000011011100110111110100011110011100110101011011000110011101110001111101101011000111110001110100000111010010011000100100111100011",
        41 => "011110101111000101100110100011110100011001010001101110101001010010000000000010000000010001001000110010000010001010100000110110101000000011011100001100001010111011111100000011000101110011101100111101101000001100001001010110010010010001111010001110101100001111010101110101101010101110010101110111101011001110111100110111001101000001100001001000010000111010100000000011111101001110111000000001110000111110110001101010111101001110101111001010000111010010000101101101111111010100100011111010100000000011001100101001001110111101101110010111101001111110100111110100100100011000010000",
        42 => "100110001010101011100111100100011001010011011010011111111001010111100000010000100001100011000010111001010100011011101000111101001011110101001010110011110110001010011011011111010000011111100101110100101000011100000110010111110110001111101111010100011011011100010011000001011100101011101101011110101110100010001000101001101110000111000000100111011111101110100111001100110011000100100011111101011010010111110111111111001100101111100111100101111110110101111000000011001101011111011010110001100101010100010011111010111011110011010101100101001011011100100101100000111000110001010110",
        43 => "110101000000100000101110110010110010001001101110101110111001101100100100110011001011101101111100101011000100000001100111000000001100100011010101101110001110001011101110011110011010001111010111100001001001001010011001111001101100111011111101011010001100101001101000011101010111111010001101001110000101101100110101111110011100001010000100011010100010111011000001001010101001001010011011010010001001010000100110010101111111001000001110000101101011100101010100111010010100001000001110001110010111101101000111100011101001111100010010011110100110010111011101010000010001100010111101",
        44 => "000101100010110000000101011000111110011011000010101011010011011000001100000100000010111110011110010100001101000101010111001000001110000100001010010010100111111111101100101010011001100000010101010011011000000011011101110100010111101111100100101111101100010001111011010000001100111100001011011000110011001001101011000010111011011110010100110111111010011111011100111111100001111110100100001001010010011011101100100010101000101010000011000000011111010110011011100000001110001100100111000011110101010011011000000110011000010110101000001001011101110011101101101110110000000111010000",
        45 => "110110011101001100111111101001010010101000111101011100111110000100110000110100100000101101111010101101110110001111111011111110111111111000101101110001000010111110010101001100100000101001010010100101111001110011001001011000010100011000000100010001110100100100010110011111101001100001011101101000011011111110110010111100011001011100010010110111101010011111100100111100000110101000000011101010000110000101110101110010011101111010100101101011111100011010110010010011001011010100010111011111001001110111101111101110110011101111010010001111001010011101110111010111110100100000100001",
        46 => "001011101010011101010010011110101111110001000001001010010010000111000011111011100110000010100011110000100010010001000011010001100101110100100110100101110011111011110000001010100110011010110011101111110010000101010000000011100011101001110100100111011001110011010001110001111000001111100011101001110011100000101101111101111100111110100100000101100011111111001111011100100110000010101011110011101110111110111100001000011110100101011110111011110000000100010000111111000010010110101100001110010000001111000000110111011100111111000111110000100001001010110001000011001001110110111100",
        47 => "000111110010100000101000110001001110011101010110101001000101111111101011000100101011101110011000010011010001111000001010101100110011000100011000110101000011110111000110100011010110100110000001010110101000011110100001100100110110000001111101100100011100010010011110000010111101101100000000000011000110011100111010001100110000101010110110101101010110010011010101110110010011100101001011011110011100010101111001100001011000011000001110000100110000011000101111111100011001011111100101110100011000111111100000001100100000100000111011010100100011010001111101000101101111001000000011",
        48 => "001000000101101001100010001110111011000101101101111000110101100010001010011110100100010111111100101110111011000110101011111000101111000101111001011111111111101111111010001111101110011010111110011101001100001010011111100100010110010101011101001111111000101001110001010100110111101101111110001101100101001011000100101101001000110101011001010010100110110011010111010011000101011000100101111110110111000110001001100110000000110011101010010010010100100101110100001111100100000010000001100100010101011010001010000110001001101101001000110100100111010000111110000011110001010010000000",
        49 => "111000011100010101101111110001010011111111101000101100110011001011000100110001110101110000011100111111011010110101111111001101100010100111110111001110001111010100001110001110100101100110011101010100010000001010110110101101001001001101011110110001100101111001111011000101010101111000101101100111110011011010000100100101100001100110110100110110110010001111010001000110100010101000110101000011101011001010101110110011100001010100110111100101010111100011111010001110100111111111000000100111101001110000101101010110101011001000010001111100010000110010000001100001010001111011110001",
        50 => "000110100011001100000100101111001001110100011100110011110111000100011110100001010001111100101011001011101110010010111000101000001111111100100101110001011111011000011010100011110011011001101000111110110010010000010010011110010001001011111110110010000011001011101001110100101001100110000000000001001110011101011001101000111110100011110011111010111101100100011110101101101001100011101010100011101100100111001001100000001011010001111010011110010101111110000101010010101100100001010000001000111001001100110011111111101101011101101001011101001001110100110111001111010011001111111101",
        51 => "110001111100101110011101111010001111100111100001101011001001100001001000000011011111010101111100110100110101100000001110001110000110100100101000101111001100011100000100101110100001010111100111011001111101110001100101000100111101011110100011011101010001110111111001011001000101111000011101000011101110101001000110101000000001110011011110111111001001010100101000011100110000100100001101001001101100101111010010101101100111111101101100010100011110110101000110110101110000000111111010000100101001000110011011111101101111101110110100010100101011111110101111001000011001011000010010",
        52 => "011101001111110111011110010001000110010111111111110111110100001100100110101100011111010011101000001111101010000011010101101101001001111000000010001010110101100111010101101001011000011010000001100110101001010100011111111010000100111111110001011101110101111001000111101100011100001011010100000010000001111101010110100001001101001101010110010011101001001001010100011101011000001110011100011110110011001101110000001010000110000000100000001001110110011100010011101100011110010000100001110100111111011100001100100000010011111011010001010010001001010111000000100001110000101001001111",
        53 => "101010010011101000010001101011101011101100100100000001101100101011001100001101100101100100101010101010011000110001011011011001011000010111110110000100010111111100111000110001010010111100111000010000010111011111010111001111101101011110010001100101011001011011101111010000001010011011110000000110010101111011000100001011100000011001000100111000000100000110111000001110101101011001000001010111001011101001001000001010000101100101101010000100101001011011111011110010010000001100001110011010001111111010111111010101100100101000000111001100100110011111101111100111000100010001001111",
        54 => "111111010100101111011110100011011001011000111001111000110111000111110110000101001100001110001000001010100001100011110110100100011011001100101110101000101011010101010001100101111001011101001111001100010001101000110011111000101001101001111000111000001000010100010011010000110010011100000001001001100010100111110110001001110010000110101010100010000100000100111101100101111000010011000111001100101111110111101000110111100100000101011110101011000101000011110110100011011100110110110000110001001010001011001101000011100010110000001010110010111100000110110001000011111000111001111110",
        55 => "000110100110110010010001010111001100001011010101101110101100100100000010001011110111100010101111110111110111001001101101001001111010100101111010011101000001111110000010100011010001011111001101000011000001011000101101110111001011101110101001100111111100100011010010110100101111101100000010000111100000000011000110001010100000101010110000010000001100001100101110010100011111010000110010110111100000001100110000000100110001100000011110010101101100111001101110100011101010100111111000100101101100000101000001010010000001011100001101101000011101011111001100111111101001010110110100",
        56 => "100001011000001101101001101001110110010011111000100001111001010010111101001001011011011011001111011111001101101011110010101011010001110111110100101011111001110101000010100001010011100000010101100110110100010100001000011110111100110000111010010101101110100111001000100101100010010111001111001110011001111010000010001110110001110011101110011111000011101011000011111001000001010011011001100101010111011110110100101111011111010010000100110110011001001010110000111101011100001110001110010011100000100101100100000011110110000110101000100101000110101011100000100011110010011001111011",
        57 => "110000111010010111110001011000101010100101110010010000111000000001010011111001101111000111001101000001001101011011001011110000100011000101100111001011010110100010100111101010011110000110001010001001010111110001100111111010001011001011110000001111001001110011100000000010001100111110100100001011000100111010101111111000100000000010011010001110001011011110111010100000000100111101010010111010100111110110100100111001010101011001110011011011110011101111110000111001101100011000000111010010101011001101001101001010000110011101101101101110000110010101011110011101001110000010100000",
        58 => "100101100110100000001111001010000000100110101010001101110011110001101011101101101101001001001010011001110001100000111011101000111111101000101110010101010100010100001010000101101101010011010101011100000110001001000101000111011011110111010111000100100110000010100111110001010001101100001110000011000110010110011101000111001000000011010111101100111000100000111100000111111011110111010110000101110111110110000011001111010101010010111110001110010111000001010101001001100000000110000100011011011110101100000011010001101010010011111010001100010100101100110010110000011100011011011000",
        59 => "110000111110000100000111110100101100101110011011110111010110001001010100011110111101011101001010110011001100010101010100111101000101111100010011100101110010000000001110111000110010100100101000010010101011111101100001111101010111011001001010000111110110100001000101010100011010000110011110100101011100000111010111001101110101101110100100100011111100110101000001010000100111111101110001011110101100101110101101011100100101110101100101000111111100100010111001111011010001100101110100110010001010110011010010001000110101001110101101011000111110100010101110110000111000000001100011",
        60 => "000011001001101110001100111011010110010010010110000101001100111001100101001111001000011001000110111111001011101101001010100000111100011111101000011001111001010100101111000001011110010100101010001110100100010011100011100111110110001001001110100011011111111010110101011101111010011011100100111111110010000001000000001111011000000100000010011101001000000001100110110010100111011011101110001110110000010111111000101100101100000011100100000101011000111111011100010101011111111011011001001101000111110111110011100110001100100010110011011101110100011101110001010001110010011100100101",
        61 => "110011100101101100101000100110100111010111101111010010001110101101100101010110110011011100110010000001101000100001000101010100000011100111101000010011100111011000011111000101111011001000001010010110010101010011101010001111111111000001010100110001100101001000011101100001011011000000111110010111101000100010111100100110100011000011001100001111011110011100111001101011000110001010000011001010010110111100010101000111110111011011010001000100100101110100011010010100001100101001101100001000010101100110010010000110110011010001001000001101100000100101100111101000100101101100110101",
        62 => "100101010101000111110101010101001001110100111101011001000110100101101100101001100001001101111010000100000100011110110111001011001000000000011000010010000010110001011000000111010011010001101001110101110101101100110110010000110000110111111001010010100000011011101111110010101000001110011101000110001100001101101000001000101001011111001001111100110111111011111011011100110101011011011011110000101011000111010001101000001011100100000100001110111101100110011101010100100100000110010000010010011011010001101010111000010111110001101110001001100000000110111010100101000110110101100011",
        63 => "011011100101010011011011010010010011001100100001011101011011111000101001001111011100111110110001000001111011111101111001111111001100001101111110010110101011111111110011101011100010010101010101100011000000100101000101110000000101000111011110010000101100111001000110101100111110001000011100111110000110100110011001111110000111010010110100110101011100111100101001010001101100011100000100001001011100000000011011001110111110010001110010111101110001100010001111111101001110000100010100110110101010000000100101110011010110100101010110010011111101010010100100111110101101000101011101"
        );       

begin
	-- Read Process 
    process(clk, Reset)
    variable i : integer;
    begin
        if rising_edge(clk) then
            if( Reset = '1' ) then
                Weights_out <= (others => '0');
            else 
				i := to_integer(unsigned(index));
				if i < max_index-1 then
					Weights_out <= Content(to_integer(unsigned(address)))( (output_size*(i+1))-1 downto output_size*i );
				else
					Weights_out((575 - output_size*i) downto 0) <= Content(to_integer(unsigned(address)))(575 downto output_size*i);
					Weights_out(output_size-1 downto (576 - output_size*i)) <= (others => '1');
				end if;
            end if;
        end if;
    end process;
end rtl;
