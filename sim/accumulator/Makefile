# Variables

input_width = 4
data_width = 8

# Settings
SIM = ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../../rtl/accumulator/accumulator.vhdl

TOPLEVEL = accumulator

MODULE = accumulator_test

SIM_ARGS =--vcd=anyname.vcd
SIM_ARGS += -ginput_width=$(input_width) -gdata_width=$(data_width)

EXTRA_ARGS = --std=08

include $(shell cocotb-config --makefiles)/Makefile.sim
