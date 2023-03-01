#!/bin/bash

ghdl -a xnor_gate.vhdl
ghdl -a xnor_gate_array.vhdl
ghdl -a adder.vhdl
ghdl -a register_dff.vhdl
ghdl -a popcount.vhdl
ghdl -a regfile.vhdl
ghdl -a accumulator_multiregs.vhdl
ghdl -a comparator.vhdl
ghdl -a computing_column_sm.vhdl
ghdl -a sm_rng_tb.vhdl
ghdl -e sm_rng_tb
ghdl -r sm_rng_tb --vcd=testbench.vcd
