#!/bin/bash
tb_filename="rng_tb"

ghdl -s $@
if [ $? -eq 0 ]; then
    echo Syntax check ok
else
    exit 1
fi

ghdl -a $@
if [ $? -eq 0 ]; then
    echo Analysis ok
else
    exit 1
fi

ghdl -e ${tb_filename}
if [ $? -eq 0 ]; then
    echo Build ok
else
    exit 1
fi

ghdl -r ${tb_filename} --vcd=testbench.vcd
if [ $? -eq 0 ]; then
    echo VCD dump ok
else
    exit 1
fi

echo "---Success---"

sleep 1
