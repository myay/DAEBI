import cocotb
from cocotb.triggers import Timer, RisingEdge

import random

input_width = 4
data_width = 8
addr_width = 2
nr_regs = 4

max_val_input = (2**(input_width))-1
max_val_addr = (2**(addr_width))-1
cycles = 10000

async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(cycles):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")

# Random test
@cocotb.test()
async def accumulator_multiregs_s_random_test(dut):
    """Test Acc Multiregs"""

    random.seed(1)
    test_reps = 1
    await cocotb.start(generate_clock(dut))

    # dut.i_val_acc.value = int(0)
    dut.reset.value = int(0)

    for i in range(0, test_reps):
        print(i)
        value_to_store = random.randint(0, max_val_input)
        addr_to_store_value = random.randint(0, addr_width)

        await Timer(0.5, units="ns")

        dut.i_val_acc.value = int(1)
        dut.r_s.value = addr_to_store_value
        dut.i_data = value_to_store

        await RisingEdge(dut.o_val_acc)
        dut.i_val_acc.value = int(~dut.o_val_acc.value) # in design, also set to negation of o_val_acc
        await Timer(20, units="ns")
