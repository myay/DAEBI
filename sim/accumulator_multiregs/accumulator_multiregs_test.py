import cocotb
from cocotb.triggers import Timer, RisingEdge, Lock

import random

input_width = 4
data_width = 8
addr_width = 2
nr_regs = 4

and_mask = 0xff

max_val_input = (2**(input_width))-1
max_val_addr = (2**(addr_width))-1
reps = 100
cycles = 1000

lock = Lock()

async def generate_clock_param(dut, cycles_param):
    """Generate clock pulses."""

    for cycle in range(cycles_param):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")

async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(cycles):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")

async def check_res(dut, regs_py, addr_to_store_value, value_to_store, p):
    # Wait for delay of pipeline
    # if rep == 0:
    #     await Timer(6, units="ns")
    # else:
    #     await Timer(6, units="ns")
    await Timer(6, units="ns")
    returned_value = int(dut.o_data.value)
    # print("---")
    # print("Before: Python value", regs_py)
    # Update python version
    async with lock:
        regs_py[addr_to_store_value] += value_to_store
        regs_py[addr_to_store_value] = regs_py[addr_to_store_value] & and_mask
    # print("address", addr_to_store_value)
    # print("value", value_to_store)
    # print("After: Python value", regs_py)
    # print("DUT value", returned_value)
    assert returned_value == regs_py[addr_to_store_value]

async def set_inputs(dut, regs_py):
    """Check outputs."""
    for rep in range(reps):
        value_to_store = random.randint(0, max_val_input)
        addr_to_store_value = int(rep % (nr_regs))
        # Update python regs
        dut.r_s.value = addr_to_store_value
        await Timer(2, units="ns")
        dut.i_data.value = value_to_store
        await cocotb.start(check_res(dut, regs_py, addr_to_store_value, value_to_store, rep))
        await Timer(4, units="ns")
        # await Timer(2, units="ns")

# Random test
@cocotb.test()
async def accumulator_multiregs_random_test(dut):
    """Test Acc Multiregs with no token"""

    random.seed(1)
    await cocotb.start(generate_clock(dut))

    # Create simulation of register file in Python
    regs_py = [int(0) for y in range(nr_regs)]

    # dut.i_val_acc.value = int(0)
    dut.reset.value = int(0)
    dut.i_val_acc.value = int(1)

    # Add delay of 1 to change inputs at every rising edge
    # await Timer(1, units="ns")
    await cocotb.start(set_inputs(dut, regs_py))
    await Timer(1000, units="ns")

    # Test reset
    dut.reset.value = int(1)
    await cocotb.start(generate_clock_param(dut, 100))
    await Timer(6, units="ns")
    dut_result = int(dut.o_data.value)
    assert dut_result == int(0), "Reset did not work as expected"

    for i in range(len(regs_py)):
        regs_py[i] = 0

    # Run tests again, with reset set to 0, but with less cycles
    dut.reset.value = int(0)
    # await Timer(1, units="ns")
    await cocotb.start(set_inputs(dut, regs_py))
    await Timer(1000, units="ns")
