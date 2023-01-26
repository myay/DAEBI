#!/bin/bash

ghdl -a --std=08 ../pkg.vhdl
ghdl -a --std=08 ../xnor/xnor_gate.vhdl
ghdl -a --std=08 ../xnor_array/xnor_gate_array.vhdl
ghdl -a --std=08 ../adder/adder.vhdl
ghdl -a --std=08 ../register_dff/register_dff.vhdl
ghdl -a --std=08 ../popcount/popcount.vhdl
ghdl -a --std=08 ../accumulator/accumulator_s.vhdl
ghdl -a --std=08 ../computing_column_vm/computing_column_vm.vhdl
ghdl -a --std=08 ../computing_columns_vm/computing_columns_vm.vhdl
ghdl -a --std=08 controller_vm_v2.vhdl
ghdl -a --std=08 -frelaxed-rules controller_vm_v2_tb.vhdl
ghdl -e --std=08 -frelaxed-rules controller_vm_v2_tb
ghdl -r --std=08 -frelaxed-rules controller_vm_v2_tb --vcd=testbench.vcd
gtkwave testbench.vcd
