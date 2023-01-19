import sys
import argparse
import math
import random


def main():

	parser = argparse.ArgumentParser(description='Generate tcl file from template')
	parser.add_argument("-t", "--template", help="path/name of the template file", default="template.tcl")
	parser.add_argument("-o", "--output", help="path/name of the output file", default="output.tcl")
	parser.add_argument("-p", "--param", help="path/name of the parameter file", default="param.txt")
	parser.add_argument('-i', '--iteration', help="generate a testbench for the popcount unit", type=int, default=0)
	args = parser.parse_args()
	
	generate(args.template, args.output, args.param, args.iteration)
	
	
def generate(templatePath, outputPath, paramPath, iteration):


	# read parameters from file
	pf = open(paramPath, "r")
	params = pf.readlines()
	
	# lines: 
	# number of registers per accumulator
	# number of crossbars
	# number of xnor gates
	
	par = []
	for p in params:
		if "#" not in p: # do not process lines with # -> comment lines
			par.append(p.split())
	
	# generate permutation of all paramters
	maxIterations = 1
	for p in par:
		maxIterations = int(maxIterations * len(p))
		
	
	if iteration >= maxIterations:
		exit(1)
		
		
	configs = []
	for p0 in par[0]:
		for p1 in par[1]:
			for p2 in par[2]:
				for p3 in par[3]:
					configs.append(( int( p0 ), int( p1 ), int( p2 ), int( p3 ) ));
				
	config = configs[iteration]
	
	print("Using config: {a}, {b}, {c}, {d}".format(a=config[0],b=config[1],c=config[2], d=config[3]))

	tf = open(templatePath, "r")
	output = tf.read()
	
	registers_accumulator_multireg = config[0]
	address_bits_accumulator_multireg = int(math.log2(registers_accumulator_multireg))
	
	output = (output + "").format(registers = registers_accumulator_multireg, address_bits = address_bits_accumulator_multireg, crossbars = config[1], xnor_gates = config[2], popcount_bits = config[3],
			popcount_output_bits = int(math.log2(config[3])))
	
	with open(outputPath, 'w') as file:
		file.write(output)
	
	
	
	# generate popcount unit
	generate_popcount(config[3],int(math.log2(config[3])), "build/popcount.vhdl")
	
	
	
def generate_popcount(bits, bits_out, output_file):
	# file header
	output = """library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity popcount is
"""

	# ports
	output_size = bits_out
	if bits_out < math.log2(bits):
		output_size = math.log2(bits)
	output += """  port(
    i_val       : in std_logic; -- whether it is ready to compute
    clk         : in std_logic;
    rst         : in std_logic;
    stream_i    : in std_logic_vector({bits} downto 0);	--input Vector
    o_val       : out std_logic; --Finish Signal
    stream_o    : out std_logic_vector({bit_out} downto 0)	--output Result (how many ones in the input)
  );
end popcount;

architecture rtl of popcount is
  -- Buffer memory definitions for intermediate storage of partial sums
""".format(bits=bits-1,bit_out=output_size)
	
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
  signal P           : std_logic_vector({bit_out} downto 0):=(others => '0'); -- Vector for final result
  signal delay_val    : std_logic_vector({delay} downto 0):= (others => '0'); --Delay signal

""".format(delay=delay_amount+1,input_bits=bits-1,bits1=bit_amount-1,bit_out=output_size)
	
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
  --Extend the {bits} Bits Vector to {bits_out} Bits Vector
  process(mem1_o) begin
    P <= mem1_o({bits1} downto 0) ;
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

end rtl;""".format(delay=delay_amount,bits=bit_amount,bits1=bit_amount-1,bits_out=bits_out)
		
	
	with open(output_file, 'w') as file:
		file.write(output)
		

	
	
	
if __name__ == "__main__":
    main()