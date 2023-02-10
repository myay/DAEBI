#!/bin/bash

# use this to execute
# ./steps.sh ../../rtl/xnor/xnor_gate.vhdl rng_tb.vhdl

tb_filename="rng_tb"

ghdl -s --std=08 $@
if [ $? -eq 0 ]; then
    echo Syntax check ok
else
    exit 1
fi

ghdl -a --std=08 $@
if [ $? -eq 0 ]; then
    echo Analysis ok
else
    exit 1
fi

ghdl -e --std=08 ${tb_filename}
if [ $? -eq 0 ]; then
    echo Build ok
else
    exit 1
fi

ghdl -r --std=08 ${tb_filename} --vcd=testbench.vcd
if [ $? -eq 0 ]; then
    echo VCD dump ok
else
    exit 1
fi

echo "---Success---"

sleep 1
