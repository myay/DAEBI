#!/bin/bash

ghdl -a ../pkg.vhdl
ghdl -a adder.vhdl
ghdl -a adder_tb.vhdl
ghdl -e adder_tb
ghdl -r adder_tb --vcd=testbench.vcd
gtkwave testbench.vcd
