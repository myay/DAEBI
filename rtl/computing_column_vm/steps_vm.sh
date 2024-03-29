#!/bin/bash

ghdl -a ../pkg.vhdl
ghdl -a ../xnor/xnor_gate.vhdl
ghdl -a ../xnor_array/xnor_gate_array.vhdl
ghdl -a ../adder/adder.vhdl
ghdl -a ../register_dff/register_dff.vhdl
ghdl -a ../popcount/popcount.vhdl
ghdl -a ../accumulator/accumulator.vhdl
ghdl -a ../comparator/comparator.vhdl
ghdl -a computing_column_vm.vhdl
ghdl -a computing_column_vm_tb.vhdl
ghdl -e computing_column_vm_tb
ghdl -r computing_column_vm_tb --vcd=testbench.vcd
gtkwave testbench.vcd
