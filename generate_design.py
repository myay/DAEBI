import os
import math
import argparse
import random

from jinja2 import Environment, FileSystemLoader

# Non-template files for OS
sources_os = [
"rtl/xnor/xnor_gate.vhdl",
"rtl/xnor_array/xnor_gate_array.vhdl",
"rtl/adder/adder.vhdl",
"rtl/register_dff/register_dff.vhdl",
"rtl/popcount/popcountGenerator/popcount.vhdl",
"rtl/accumulator/accumulator.vhdl",
"rtl/comparator/comparator.vhdl",
# "rtl/computing_column_vm/computing_column_vm.vhdl",
]

reset_pipe_delay_dict = {
8: 6,
16: 7,
32: 8,
64: 9,
128: 10,
256: 11,
512: 12,
1024: 13,
2048: 14,
}

reset_delay_to_64_wm = {
8: 14,
16: 15,
32: 16,
64: 17,
128: 18,
256: 19,
512: 20,
1024: 21,
2048: 22,
}

# Non-template files for WS
sources_ws = [
"rtl/xnor/xnor_gate.vhdl",
"rtl/xnor_array/xnor_gate_array.vhdl",
"rtl/adder/adder.vhdl",
"rtl/register_dff/register_dff.vhdl",
"rtl/popcount/popcountGenerator/popcount.vhdl",
"rtl/regfile/regfile.vhdl",
"rtl/accumulator_multiregs/accumulator_multiregs.vhdl",
"rtl/comparator/comparator.vhdl",
# "rtl/computing_column_sm/computing_column_sm.vhdl",
]

parser = argparse.ArgumentParser()
parser.add_argument('--dataflow', type=str, default=None, help='Dataflow type in the design: OS or WS')
parser.add_argument('--n', type=int, default=64, help='Number of XNOR gates per column')
parser.add_argument('--m', type=int, default=1, help='Number of columns in accelerator')
parser.add_argument('--dw', type=int, default=64, help='Width of datapath')
parser.add_argument('--nrregs', type=int, default=1, help='Number of registers')
parser.add_argument('--rrf', type=int, default=1, help='Register reduction factor, calculate by ceil(delta/nrregs)')
parser.add_argument('--alpha', type=int, default=64, help='alpha')
parser.add_argument('--beta', type=int, default=576, help='beta')
parser.add_argument('--delta', type=int, default=196, help='delta')
parser.add_argument('--memory', type=int, default=0, help='Generate with or without memory')
parser.add_argument('--debug', type=int, default=0, help='Debug mode or production mode')
args = parser.parse_args()

# TODO set seed

# Create a folder for the design
directory = "design_df{}_m{}_n{}_dw{}_alpha{}_beta{}_delta{}_nrregs{}".format(args.dataflow, args.m, args.n, args.dw, args.alpha, args.beta, args.delta, args.nrregs)
if not os.path.exists(directory):
    os.makedirs(directory)

# Generate popcount unit with specified size
popc_bits_out = int(math.log2(args.n)) + 1
os.chdir("rtl/popcount/popcountGenerator/")
popc_gen_command = "python3 popcount_generator.py -i={} -o={}".format(args.n, popc_bits_out)
os.system(popc_gen_command)
os.chdir("../../../")

sources_tocopy = None
rst_pipe_delay = None
if args.dataflow == "OS":
    sources_tocopy = sources_os
if args.dataflow == "WS":
    sources_tocopy = sources_ws

for source in sources_tocopy:
    cp_command = "cp {} {}/{}".format(source, directory, os.path.basename(source))
    os.popen(cp_command)

# create neutral inputs with correct lenths
neutral_input_1 = ""
neutral_input_2 = ""

for i in range(args.n):
    if i % 2 == 0:
        neutral_input_1 += "1"
        neutral_input_2 += "0"
    else:
        neutral_input_1 += "0"
        neutral_input_2 += "1"
		
# create random memory data
weights_rom_data = ""
inputs_rom_data = ""
threshold_rom_data = ""
# weights rom
for i in range(args.alpha):
	data = ""
	for j in range(args.beta):
		data += str(random.randint(0,1))
	weights_rom_data += '\t\t{index} => "{data}" '.format(index = i, data = data)
	if i < args.alpha-1:
		weights_rom_data += ", \n"
		
# inputs rom
for i in range(args.delta):
	data = ""
	for j in range(args.beta):
		data += str(random.randint(0,1))
	inputs_rom_data += '\t\t{index} => "{data}" '.format(index = i, data = data)
	if i < args.delta-1:
		inputs_rom_data += ", \n"
		
# threshold rom
for i in range(args.alpha):
	data = ""
	for j in range(args.dw):
		data += str(random.randint(0,1))
	threshold_rom_data += '\t\t{index} => "{data}" '.format(index = i, data = data)
	if i < args.alpha-1:
		threshold_rom_data += ", \n"

ind_max = int(math.ceil(args.beta/args.n))
ind_bits = int(math.ceil(math.log2(ind_max)))



# Create design from template
design_params = {
"n": args.n,
"m": args.m,
"dw": args.dw,
"popc_o": popc_bits_out,
"reset_pipe_delay": reset_pipe_delay_dict[args.n],
"alpha": args.alpha,
"beta": args.beta,
"delta": args.delta,
"debug": args.debug,
"neutral_input_1": neutral_input_1,
"neutral_input_2": neutral_input_2,
"nr_regs": args.nrregs,
"awa": int(math.ceil(math.log2(args.nrregs))),
"rrf": args.rrf,
"sm_reset_delay_to_64": reset_delay_to_64_wm[args.n],
"ind_max": ind_max,
"ind_bits": ind_bits,
"weights_addr_size": int(math.ceil(math.log2(args.alpha))),
"inputs_addr_size": int(math.ceil(math.log2(args.delta))),
"weights_rom_data": weights_rom_data,
"inputs_rom_data": inputs_rom_data,
"threshold_rom_data": threshold_rom_data
}

environment = Environment(loader=FileSystemLoader("templates/"))

template_files = []
if args.dataflow == "OS":
    if args.m == 1:
        template_files.append("computing_column_vm.vhdl")
        template_files.append("vm_rng_tb.vhdl")
        template_files.append("steps_vm_rng.sh")
    elif args.m > 1:
        if args.memory == 1:
            template_files.append("controller_multi_vm_mem.vhdl")
            template_files.append("controller_vm_v2_mem.vhdl")
        else:
            template_files.append("controller_vm_v2.vhdl")
		
        template_files.append("computing_columns_vm.vhdl")
        template_files.append("computing_column_vm.vhdl")
        template_files.append("computing_columns_vm_constrained.vhdl")
        template_files.append("vm_multicol_rng_tb.vhdl")
        template_files.append("steps_vm_multicol_rng.sh")
if args.dataflow == "WS":
    if args.m == 1:
        template_files.append("computing_column_sm.vhdl")
        template_files.append("sm_rng_tb.vhdl")
        template_files.append("steps_sm_rng.sh")
    elif args.m > 1:
        if args.memory == 1:
            template_files.append("controller_multi_sm_mem.vhdl")
            template_files.append("controller_sm_mem.vhdl")
        else:
            template_files.append("controller_sm.vhdl")
        template_files.append("computing_columns_sm.vhdl")
        template_files.append("computing_column_sm.vhdl")
        template_files.append("computing_columns_sm_constrained.vhdl")
        template_files.append("sm_multicol_rng_tb.vhdl")
        template_files.append("steps_sm_multicol_rng.sh")

if args.memory == 1:
    template_files.append("weights_rom.vhdl")
    template_files.append("inputs_rom.vhdl")
    template_files.append("threshold_rom.vhdl")

for idx, template_file in enumerate(template_files):
    template = environment.get_template(template_file)

    filename = directory + "/" + template_file
    content = template.render(
        design_params
    )
    with open(filename, mode="w", encoding="utf-8") as genfile:
        genfile.write(content)

print("Design is stored in the folder {}.".format(directory))

# os.rmdir(directory)
