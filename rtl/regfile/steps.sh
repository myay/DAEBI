#!/bin/bash

ghdl -a ../pkg.vhdl
ghdl -a regfile.vhdl
ghdl -a regfile_tb.vhdl
ghdl -e regfile_tb
ghdl -r regfile_tb --vcd=testbench.vcd
gtkwave testbench.vcd
