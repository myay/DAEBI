# Variables

w = 4

# Settings
SIM = ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../../rtl/register_dff/register_dff.vhdl

TOPLEVEL = register_dff

MODULE = register_dff_test

SIM_ARGS =--vcd=anyname.vcd
SIM_ARGS += -gw=$(w)

EXTRA_ARGS = --std=08

include $(shell cocotb-config --makefiles)/Makefile.sim
