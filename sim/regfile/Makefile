# Variables

data_width = 4
addr_width = 2
nr_regs = 4

# Settings
SIM = ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../../rtl/regfile/regfile.vhdl

TOPLEVEL = regfile

MODULE = regfile_test

SIM_ARGS =--vcd=anyname.vcd
SIM_ARGS += -gdata_width=$(data_width) -gaddr_width=$(addr_width) -gnr_regs=$(nr_regs)

EXTRA_ARGS = --std=08

include $(shell cocotb-config --makefiles)/Makefile.sim
