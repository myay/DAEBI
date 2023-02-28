#!/bin/bash

ghdl -a ../xnor/xnor_gate.vhdl
ghdl -a ../xnor_array/xnor_gate_array.vhdl
ghdl -a ../adder/adder.vhdl
ghdl -a ../register_dff/register_dff.vhdl
ghdl -a ../popcount/popcount.vhdl
ghdl -a ../regfile/regfile.vhdl
ghdl -a ../accumulator_multiregs/accumulator_multiregs.vhdl
ghdl -a ../comparator/comparator.vhdl
ghdl -a computing_column_sm.vhdl
ghdl -a sm_rng_tb.vhdl
ghdl -e sm_rng_tb
ghdl -r sm_rng_tb --vcd=testbench.vcd
