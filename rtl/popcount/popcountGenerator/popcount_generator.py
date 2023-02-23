import sys
import argparse
import math
import random


def main():

	parser = argparse.ArgumentParser(description='Generate vhdl file for a popcount unit.')
	parser.add_argument("-i", "--bits_in", help="number of input bits (has to be a power of 2), default 64", type=int, default=64)
	parser.add_argument("-o", "--bits_out", help="number of output bits (has to be greater than log2 of input bits), default 6", type=int, default=6)
	parser.add_argument('-tb', '--testbench', help="generate a testbench for the popcount unit", action='store_true', default=True)
	# parser.add_argument("-n", "--name", help="name of the output file ", type=string, default='popcount')
	args = parser.parse_args()

	bits = args.bits_in
	bits_out = args.bits_out
	if bits < 4:
		bits = 4
		print("Number of input bits has to be a power of 2 greater than 2 (4,8,16,32,...)")
	generate_popcount(bits, bits_out)
	print("Generated: popcount unit with {in_bits} bits wide input and {out_bits} bits wide output.".format(in_bits=bits,out_bits=bits_out))

	testbench = args.testbench
	if testbench:
		generate_popcount_tb(bits, bits_out)
		print("Generated: testbench for popcount unit")


def generate_popcount_tb(bits, bits_out):
	# file header
	output = """library ieee;
use ieee.std_logic_1164.all;

library work;
use work.all;

entity popcount_tb is
end popcount_tb;

architecture test of popcount_tb is
  component popcount
    port(
      i_val       : in std_logic; -- whether it is ready to compute
      clk         : in std_logic;
      rst         : in std_logic;
      stream_i    : in std_logic_vector({bits_in} downto 0);	--input Vector
      o_val       : out std_logic; --Finish Signal
      stream_o    : out std_logic_vector({bits_out} downto 0)	--output Result (how many ones in the input)
    );
  end component;

signal i_val_t, rst_t, o_val_t: std_logic;
signal clk_t: std_logic := '0';
constant clk_period : time := 2 ns;
signal input_t: std_logic_vector({bits_in} downto 0);
signal output_t: std_logic_vector({bits_out} downto 0);
shared variable i: integer := 0;
shared variable max_clock_cyles: integer := 100;

begin
  popcount_test: popcount
    port map(
      i_val => i_val_t,
      clk => clk_t,
      rst => rst_t,
      stream_i => input_t,
      o_val => o_val_t,
      stream_o => output_t
    );

  process begin
    i_val_t <= '0';
    rst_t <= '0';
    wait for 1 ns;
""".format(bits_in=bits-1, bits_out=bits_out-1)


	# test values
	output += """    i_val_t <= '1';
    input_t <= x"{one}";
    wait for 2 ns;
""".format(one="f"*int(bits/4))
	for i in range(20):
		bin, count = randomBitvector(bits)
		output += """	input_t <= "{bin_val}"; -- popcount of {count}
    wait for 2 ns;
""".format(bin_val=bin, count=count)


	# rest of testbench
	output += """    wait;
  end process;

  -- Clock generation process
  clk_process: process
    begin
      while i<max_clock_cyles loop
        -- clk_t <= not clk_t after clk_period/2;
        clk_t <= '0';
        wait for clk_period/2;  -- Signal is '0'.
        clk_t <= '1';
        wait for clk_period/2;  -- Signal is '1'
        i := i+1;
      end loop;
      wait;
    end process;
end test;"""

	# write file
	with open('popcount_tb.vhdl', 'w') as file:
		file.write(output)


def generate_popcount(bits, bits_out):
	# file header
	output = """library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity popcount is
"""

	# ports
	output_size = int(math.log2(bits)) + 1
	# if bits_out < math.log2(bits):
		# output_size = math.log2(bits)
	output += """  port(
    i_val       : in std_logic; -- whether it is ready to compute
    clk         : in std_logic;
    rst         : in std_logic;
    stream_i    : in std_logic_vector({bits} downto 0);	--input Vector
    o_val       : out std_logic; --Finish Signal
    stream_o    : out std_logic_vector({bits_out} downto 0)	--output Result (how many ones in the input)
  );
end popcount;

architecture rtl of popcount is
  -- Buffer memory definitions for intermediate storage of partial sums
""".format(bits=bits-1,bits_out=output_size-1)

	# memory signals
	array_amount = int(bits/2)
	bit_amount = 2

	while array_amount > 1:
		output += """  type ram_type{array_amount} is array ({array_amount1} downto 0) of std_logic_vector({bits1} downto 0); -- {array_amount} arrays of {bits} bits (buffer memory for results of level {bits1} additions)
  signal mem{array_amount}_i      : ram_type{array_amount} := (others => (others => '0'));
  signal mem{array_amount}_o      : ram_type{array_amount} := (others => (others => '0'));

""".format(array_amount=array_amount, array_amount1 = array_amount-1, bits=bit_amount, bits1 = bit_amount-1)

		bit_amount = bit_amount+1
		array_amount = int(array_amount/2)


	output += """  type ram_type1 is array (0 downto 0) of std_logic_vector({bits1} downto 0); -- 1 array of {bits} bits (buffer memory for results of {bits1}th level additions)
""".format(bits=bit_amount,bits1=bit_amount-1)


	# input/output and delay signal
	delay_amount = int(math.log2(bits))+1
	output += """
  signal mem1_i       : std_logic_vector({bits1} downto 0);
  signal mem1_o       : std_logic_vector({bits1} downto 0);

  signal dff_stream   : std_logic_vector({input_bits} downto 0); -- Vector for inputs
  signal P           : std_logic_vector({output_size} downto 0):=(others => '0'); -- Vector for final result
  signal delay_val    : std_logic_vector({delay} downto 0):= (others => '0'); --Delay signal

""".format(delay=delay_amount+1,input_bits=bits-1,bits1=bit_amount-1,output_size=output_size-1)

	# connecting input signal
	alternating_input = "10"*(int(bits/2))
	output += """begin
  --Assign the input to the Signal
  process(clk)begin
    if rising_edge(clk) then
      if rst = '1' then
        dff_stream <= "{alternating_input}";
      elsif ((i_val = '1') and ((stream_i(0) = '0') or (stream_i(0) = '1' ))) then
            dff_stream <= stream_i;
      end if;
    end if;
  end process;

""".format(alternating_input=alternating_input)

	# top layer of adders

	output += """	  -- Generate {bits2} adders to add neighbouring bits of input and buffer the results (1st level additions)
  gen_add_1_2 : for i in 0 to {bits1} generate
    inst_adder_1_2:  entity work.adder(rtl)
      generic map(w_i => 1, w_o => 2)
      port map(
        a(0) => dff_stream(i*2),
        b(0) => dff_stream(i*2+1),
        y => mem{bits2}_i(i)
      );
    inst_dff_2 : entity work.register_dff(rtl)
    generic map(w => 2)
      port map(
        clk => clk,
        reset => rst,
        d => mem{bits2}_i(i),
        q => mem{bits2}_o(i)
      );
  end generate;

""".format(bits2=int(bits/2),bits1=int(bits/2)-1)


	# mid levels of adders
	adder_amount = int(bits/4)
	bit_amount = 3

	while adder_amount > 1:
		output += """  -- Generate {adder_amount} adders to add neighbouring bits of input and buffer the results (level {bit1} additions)
  gen_add_{bit1}_{bit} : for i in 0 to {adder_amount1} generate
    inst_adder_{bit1}_{bit} : entity work.adder(rtl)
      generic map(w_i => {bit1}, w_o => {bit})
      port map(
        a => mem{adder_amount2}_o(i*2),
        b => mem{adder_amount2}_o(i*2+1),
        y => mem{adder_amount}_i(i)
      );
    inst_dff_{bit} : entity work.register_dff(rtl)
      generic map(w => {bit})
      port map(
        clk => clk,
        reset => rst,
        d => mem{adder_amount}_i(i),
        q => mem{adder_amount}_o(i)
      );
  end generate;

""".format(adder_amount1=adder_amount-1 ,adder_amount=adder_amount, adder_amount2 = adder_amount*2, bit1=bit_amount-1, bit = bit_amount)

		bit_amount = bit_amount+1
		adder_amount = int(adder_amount/2)



	# last adder
	output += """  -- Generate 1 adder to add neighbouring bits of input and buffer the results ({bits1}th level addition)
  inst_adder_{bits1}_{bits} : entity work.adder(rtl)
    generic map(w_i => {bits1}, w_o => {bits})
    port map(
      a => mem2_o(0),
      b => mem2_o(1),
      y => mem1_i
    );
  inst_dff_{bits} : entity work.register_dff(rtl)
    generic map(w => {bits})
    port map(
      clk => clk,
      reset => rst,
      d => mem1_i,
      q => mem1_o
    );
""".format(bits=bit_amount,bits1=bit_amount-1)


	# Finish signal, output and end of file

	output += """
-------------------------------------------
  process(mem1_o) begin
    P <= mem1_o;
  end process;

  --Calculate the Finish Signal with help of delay Signal
  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        delay_val <= (others => '0');
        o_val <= '0';
      else
        delay_val <= delay_val({delay} downto 0) & i_val;
        if (delay_val({delay}) = '1') then
          o_val <= '1';
        else
          o_val <= '0';
        end if;
      end if;
    end if;
  end process;

  --Assign The results Vector to the Output
  process(clk)
    begin
      if rising_edge(clk) then
        if rst = '1'then
          stream_o <= (others => '0');
        elsif delay_val({delay}) = '1' then
          stream_o <= P;
        end if;
      end if;
  end process;

end rtl;""".format(delay=delay_amount,bits=bit_amount,bits1=output_size)


	with open('popcount.vhdl', 'w') as file:
		file.write(output)



# d: number to convert
# n: number of digits of result
def dez_to_hex(d, n):
	chars = ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"]
	output = ""
	for i in range(n-1, 0, -1):
		div = 16**i
		dDiv = d // div
		dNext = d % div
		if dDiv > 0:
			output += chars[dDiv]
		else:
			output += "0"

	output += chars[dNext]
	return output


# n: length of the random bitvector
def randomBitvector(n):
	vec = ""
	count = 0
	for i in range(n):
		if bool(random.getrandbits(1)):
			vec += "1"
			count += 1
		else:
			vec += "0"

	return (vec,count)

if __name__ == "__main__":
    main()
