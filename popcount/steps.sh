#!/bin/bash

ghdl -a ../pkg.vhdl
ghdl -a ../adder/adder.vhdl
ghdl -a ../register_dff/register_dff.vhdl
ghdl -a popcount.vhdl
ghdl -a popcount_tb.vhdl
ghdl -e popcount_tb
ghdl -r popcount_tb --vcd=testbench.vcd
gtkwave testbench.vcd
