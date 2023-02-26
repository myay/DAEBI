#!/bin/bash

ghdl -a ../xnor/xnor_gate.vhdl
ghdl -a ../xnor_array/xnor_gate_array.vhdl
ghdl -a ../adder/adder.vhdl
ghdl -a ../register_dff/register_dff.vhdl
ghdl -a ../popcount/popcount.vhdl
ghdl -a ../accumulator/accumulator.vhdl
ghdl -a ../comparator/comparator.vhdl
ghdl -a ../computing_column_vm/computing_column_vm.vhdl
ghdl -a computing_columns_vm_constrained.vhdl
ghdl -a vm_multicol_rng_tb.vhdl
ghdl -e vm_multicol_rng_tb
ghdl -r vm_multicol_rng_tb --vcd=testbench.vcd
