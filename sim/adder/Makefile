# Variables

w_i = 4
w_o = 4

# Settings
SIM = ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../../rtl/adder/adder.vhdl

TOPLEVEL = adder

MODULE = adder_test

SIM_ARGS =--vcd=anyname.vcd
SIM_ARGS += -gw_i=$(w_i) -gw_o=$(w_o)

EXTRA_ARGS = --std=08

include $(shell cocotb-config --makefiles)/Makefile.sim
