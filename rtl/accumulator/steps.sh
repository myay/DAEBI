#!/bin/bash

ghdl -a ../pkg.vhdl
ghdl -a accumulator.vhdl
ghdl -a accumulator_tb.vhdl
ghdl -e accumulator_tb
ghdl -r accumulator_tb --vcd=testbench.vcd
gtkwave testbench.vcd
