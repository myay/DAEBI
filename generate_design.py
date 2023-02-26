import os
import math
import argparse

from jinja2 import Environment, FileSystemLoader

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

reset_pipe_delay_dict_os = {
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

# TODO: generate neural elements for XNOR gates for arbitrary n

sources_ws = [
"rtl/xnor/xnor_gate.vhdl",
"rtl/xnor_array/xnor_gate_array.vhdl",
"rtl/adder/adder.vhdl",
"rtl/register_dff/register_dff.vhdl",
"rtl/popcount/popcountGenerator/popcount.vhdl",
"rtl/regfile/regfile.vhdl",
"rtl/accumulator_multiregs/accumulator_multiregs.vhdl",
"rtl/comparator/comparator.vhdl",
"rtl/computing_column_sm/computing_column_sm.vhdl",
]

parser = argparse.ArgumentParser()
parser.add_argument('--dataflow', type=str, default=None, help='Dataflow type in the design: OS or WS')
parser.add_argument('--n', type=int, default=64, help='Number of XNOR gates per column')
parser.add_argument('--dw', type=int, default=64, help='Width of datapath')
parser.add_argument('--alpha', type=int, default=64, help='alpha')
parser.add_argument('--beta', type=int, default=576, help='beta')
parser.add_argument('--delta', type=int, default=196, help='delta')
parser.add_argument('--debug', type=int, default=0, help='delta')
args = parser.parse_args()

# Create a folder for the design
directory = "design_df{}_n{}".format(args.dataflow, args.n)
if not os.path.exists(directory):
    os.makedirs(directory)

# Generate popcount unit with specified size
popc_bits_out = int(math.log2(args.n)) + 1
os.chdir("rtl/popcount/popcountGenerator/")
popc_gen_command = "python3 popcount_generator.py -i={} -o={}".format(args.n, popc_bits_out)
os.system(popc_gen_command)
os.chdir("../../../")

sources_tocopy = None
if args.dataflow == "OS":
    sources_tocopy = sources_os
if args.dataflow == "WS":
    sources_tocopy = sources_ws

for source in sources_tocopy:
    cp_command = "cp {} {}/{}".format(source, directory, os.path.basename(source))
    os.popen(cp_command)

# Create one VM column from template
design_params = {
"n": args.n,
"dw": args.dw,
"popc_o": popc_bits_out,
"reset_pipe_delay": reset_pipe_delay_dict_os[args.n],
"alpha": args.alpha,
"beta": args.beta,
"delta": args.delta,
"debug": args.debug
}

environment = Environment(loader=FileSystemLoader("templates/"))

template = environment.get_template("computing_column_vm.vhdl")

filename = directory + "/" + "computing_column_vm.vhdl"
content = template.render(
    design_params
)
with open(filename, mode="w", encoding="utf-8") as genfile:
    genfile.write(content)

template = environment.get_template("vm_rng_tb.vhdl")

filename = directory + "/" + "vm_rng_tb.vhdl"
content = template.render(
    design_params
)
with open(filename, mode="w", encoding="utf-8") as genfile:
    genfile.write(content)

print("Design is stored in the folder {}.".format(directory))

# os.rmdir(directory)
