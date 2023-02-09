#!/bin/bash

ghdl -a --std=08 ../pkg.vhdl
ghdl -a --std=08 ../xnor/xnor_gate.vhdl
ghdl -a --std=08 ../xnor_array/xnor_gate_array.vhdl
ghdl -a --std=08 ../adder/adder.vhdl
ghdl -a --std=08 ../register_dff/register_dff.vhdl
ghdl -a --std=08 ../popcount/popcount.vhdl
ghdl -a --std=08 ../regfile/regfile.vhdl
ghdl -a --std=08 ../accumulator_multiregs/accumulator_multiregs.vhdl
ghdl -a --std=08 ../comparator/comparator.vhdl
ghdl -a --std=08 ../computing_column_sm/computing_column_sm.vhdl
ghdl -a --std=08 computing_columns_sm.vhdl
ghdl -a --std=08 -frelaxed-rules computing_columns_sm_tb.vhdl
ghdl -e --std=08 -frelaxed-rules computing_columns_sm_tb
ghdl -r --std=08 -frelaxed-rules computing_columns_sm_tb --vcd=testbench.vcd
# gtkwave testbench.vcd
