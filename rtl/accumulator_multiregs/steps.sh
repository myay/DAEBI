#!/bin/bash

ghdl -a ../pkg.vhdl
ghdl -a ../regfile/regfile.vhdl
ghdl -a ../adder/adder.vhdl
ghdl -a ../register_dff/register_dff.vhdl
ghdl -a accumulator_multiregs.vhdl
ghdl -a accumulator_multiregs_tb.vhdl
ghdl -e accumulator_multiregs_tb
ghdl -r accumulator_multiregs_tb --vcd=testbench.vcd
gtkwave testbench.vcd
