#!/bin/bash

ghdl -a ../pkg.vhdl
ghdl -a register_dff.vhdl
ghdl -a register_dff_tb.vhdl
ghdl -e register_dff_tb
ghdl -r register_dff_tb --vcd=testbench.vcd
gtkwave testbench.vcd
