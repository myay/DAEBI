# Variables

input_width = 4
data_width = 8

# Settings
SIM = ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../../rtl/adder/adder.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/register_dff/register_dff.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/popcount/popcount.vhdl

TOPLEVEL = popcount

MODULE = popcount_test

SIM_ARGS =--vcd=anyname.vcd
# SIM_ARGS += -ginput_width=$(input_width) -gdata_width=$(data_width)

EXTRA_ARGS = --std=08

include $(shell cocotb-config --makefiles)/Makefile.sim
