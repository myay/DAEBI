# Variables

nr_xnor_gates = 64
acc_data_width = 32
nr_popc_bits_o = 7
nr_regs_accm = 4
addr_width_accm = 2

# Settings
SIM = ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../../rtl/xnor/xnor_gate.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/xnor_array/xnor_gate_array.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/adder/adder.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/register_dff/register_dff.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/popcount/popcount.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/regfile/regfile.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/accumulator_multiregs/accumulator_multiregs.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/comparator/comparator.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/computing_column_sm/computing_column_sm.vhdl

TOPLEVEL = computing_column_sm

MODULE = computing_column_sm_test

SIM_ARGS =--vcd=anyname.vcd
SIM_ARGS += -gnr_xnor_gates=$(nr_xnor_gates) -gacc_data_width=$(acc_data_width) -gnr_popc_bits_o=$(nr_popc_bits_o) -gnr_regs_accm=$(nr_regs_accm) -gaddr_width_accm=$(addr_width_accm)

EXTRA_ARGS = --std=08

include $(shell cocotb-config --makefiles)/Makefile.sim
