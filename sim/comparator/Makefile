# Variables

bit_width = 16

# defaults
SIM = ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../../rtl/comparator/comparator.vhdl
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = comparator

# MODULE is the basename of the Python test file
MODULE = comparator_test

SIM_ARGS=--vcd=anyname.vcd
SIM_ARGS += -gbit_width=$(bit_width)

EXTRA_ARGS = --std=08

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
