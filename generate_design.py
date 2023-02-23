import os
import math
import argparse

sources_os = [
"rtl/xnor/xnor_gate.vhdl",
"rtl/xnor_array/xnor_gate_array.vhdl",
"rtl/adder/adder.vhdl",
"rtl/register_dff/register_dff.vhdl",
"rtl/popcount/popcountGenerator/popcount.vhdl",
"rtl/accumulator/accumulator.vhdl",
"rtl/comparator/comparator.vhdl",
"rtl/computing_column_vm/computing_column_vm.vhdl",
]

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

print("Design is stored in the folder {}.".format(directory))

# os.rmdir(directory)
