#!/bin/bash

ghdl -a xnor_gate.vhdl
ghdl -a xnor_gate_array.vhdl
ghdl -a adder.vhdl
ghdl -a register_dff.vhdl
ghdl -a popcount.vhdl
ghdl -a accumulator.vhdl
ghdl -a comparator.vhdl
ghdl -a computing_column_vm.vhdl
ghdl -a vm_rng_tb.vhdl
ghdl -e vm_rng_tb
ghdl -r vm_rng_tb --vcd=testbench.vcd
