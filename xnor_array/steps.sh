#!/bin/bash

ghdl -a ../pkg.vhdl
ghdl -a ../xnor/xnor_gate.vhdl
ghdl -a xnor_gate_array.vhdl
ghdl -a xnor_gate_array_tb.vhdl
ghdl -e xnor_gate_array_tb
ghdl -r xnor_gate_array_tb --vcd=testbench.vcd
gtkwave testbench.vcd
