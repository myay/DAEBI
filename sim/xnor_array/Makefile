# Variables

nr_xnor_gates = 4

# Settings
SIM = ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../../rtl/xnor/xnor_gate.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/xnor_array/xnor_gate_array.vhdl

TOPLEVEL = xnor_gate_array

MODULE = xnor_array_test

SIM_ARGS =--vcd=anyname.vcd
SIM_ARGS += -gnr_xnor_gates=$(nr_xnor_gates)

EXTRA_ARGS = --std=08

include $(shell cocotb-config --makefiles)/Makefile.sim
