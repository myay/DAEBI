# Variables

nr_computing_columns = 2
nr_xnor_gates = 64
acc_data_width = 32
nr_popc_bits_o = 7

# Settings
SIM = ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../../rtl/xnor/xnor_gate.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/xnor_array/xnor_gate_array.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/adder/adder.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/register_dff/register_dff.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/accumulator/accumulator.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/popcount/popcount.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/comparator/comparator.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/computing_column_vm/computing_column_vm.vhdl
VHDL_SOURCES += $(PWD)/../../rtl/computing_columns_vm/computing_columns_vm.vhdl

TOPLEVEL = computing_columns_vm

MODULE = computing_columns_vm_test

SIM_ARGS =--vcd=anyname.vcd
SIM_ARGS += -gnr_computing_columns=$(nr_computing_columns) -gnr_xnor_gates=$(nr_xnor_gates) -gacc_data_width=$(acc_data_width) -gnr_popc_bits_o=$(nr_popc_bits_o)

EXTRA_ARGS = --std=08

include $(shell cocotb-config --makefiles)/Makefile.sim
