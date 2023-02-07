# Variables

input_width = 4
data_width = 8
addr_width = 2
nr_regs = 4

# Settings
SIM = ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES = $(PWD)/../../rtl/regfile/regfile.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/accumulator_multiregs/accumulator_multiregs_s.vhdl

TOPLEVEL = accumulator_multiregs_s

MODULE = accumulator_multiregs_s_test_notoken

SIM_ARGS =--vcd=anyname.vcd
SIM_ARGS += -ginput_width=$(input_width) -gdata_width=$(data_width) -gaddr_width=$(addr_width) -gnr_regs=$(nr_regs)

EXTRA_ARGS = --std=08

include $(shell cocotb-config --makefiles)/Makefile.sim
