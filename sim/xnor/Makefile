# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../../rtl/xnor/xnor_gate.vhdl
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = xnor_gate

# MODULE is the basename of the Python test file
MODULE = xnor_test

SIM_ARGS=--vcd=anyname.vcd

EXTRA_ARGS = --std=08

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
