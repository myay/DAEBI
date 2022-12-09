import cocotb
from cocotb.triggers import Timer, RisingEdge

import random

input_width = 4
data_width = 8
addr_width = 2
nr_regs = 4

and_mask = 0xff

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
    test_reps = 1000
    await cocotb.start(generate_clock(dut))

    # Create simulation of register file in Python
    regs_py = [int(0) for y in range(nr_regs)]

    # dut.i_val_acc.value = int(0)
    dut.reset.value = int(0)

    for i in range(0, test_reps):
        # print(i)
        value_to_store = random.randint(0, max_val_input)
        addr_to_store_value = random.randint(0, addr_width)
        regs_py[addr_to_store_value] += value_to_store
        regs_py[addr_to_store_value] = regs_py[addr_to_store_value] & and_mask

        dut.i_val_acc.value = int(1)
        dut.r_s.value = addr_to_store_value
        dut.i_data.value = value_to_store

        await RisingEdge(dut.o_val_acc)
        dut.i_val_acc.value = int(~dut.o_val_acc.value) # in design, also set to negation of o_val_acc
        returned_value = int(dut.o_data.value)
        await Timer(4, units="ns")
        assert returned_value == regs_py[addr_to_store_value]
