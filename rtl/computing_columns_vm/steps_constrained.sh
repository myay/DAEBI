#!/bin/bash

ghdl -a ../pkg.vhdl
ghdl -a ../xnor/xnor_gate.vhdl
ghdl -a ../xnor_array/xnor_gate_array.vhdl
ghdl -a ../adder/adder.vhdl
ghdl -a ../register_dff/register_dff.vhdl
ghdl -a ../popcount/popcount.vhdl
ghdl -a ../accumulator/accumulator.vhdl
ghdl -a ../comparator/comparator.vhdl
ghdl -a ../computing_column_vm/computing_column_vm.vhdl
ghdl -a computing_columns_vm_constrained.vhdl
ghdl -a -frelaxed-rules computing_columns_vm_tb_constrained.vhdl
ghdl -e -frelaxed-rules computing_columns_vm_tb_constrained
ghdl -r -frelaxed-rules computing_columns_vm_tb_constrained --vcd=testbench.vcd
# gtkwave testbench.vcd
