import os
import math
import argparse

dataflow = "OS"

sources_os = [
"rtl/xnor/xnor_gate.vhdl",
"rtl/xnor_array/xnor_gate_array.vhdl",
"rtl/adder/adder.vhdl",
"rtl/register_dff/register_dff.vhdl",
"rtl/accumulator/accumulator.vhdl",
"rtl/popcount/popcountGenerator/popcount.vhdl",
"rtl/comparator/comparator.vhdl",
"rtl/computing_column_vm/computing_column_vm.vhdl",
]

parser = argparse.ArgumentParser()
parser.add_argument('--dataflow', type=str, default=None, help='Dataflow type in the design: OS or WS')
parser.add_argument('--n', type=int, default=32, help='Number of XNOR gates per column')
args = parser.parse_args()

# Create a folder for the design
directory = "design_df{}_n{}".format(args.dataflow, args.n)
if not os.path.exists(directory):
    os.makedirs(directory)

# print(os.path.basename(sources_os[0]))
# Generate popcount unit with specifed size
popc_bits_out = int(math.log2(args.n)) + 1
os.chdir("rtl/popcount/popcountGenerator/")
popc_gen_command = "python3 popcount_generator.py -i={} -o={}".format(args.n, popc_bits_out)
os.system(popc_gen_command)
os.chdir("../../../")

if args.dataflow == "OS":
    for source in sources_os:
        cp_command = "cp {} {}/{}".format(source, directory, os.path.basename(source))
        os.popen(cp_command)

print("Design is stored in the folder {}.".format(directory))

# os.rmdir(directory)
