import cocotb
from cocotb.triggers import Timer

import random

w = 4
max_val = (2**(w))-1
cycles = 1000

async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(cycles):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")

# random test
@cocotb.test()
async def register_dff_test(dut):
    """Test Register"""

    random.seed(1)
    test_reps = cycles

    await cocotb.start(generate_clock(dut))

    # store a random value in the register
    for i in range(0, test_reps):
        value_to_store = random.randint(0, max_val)

        # Set reset to 0
        dut.reset.value = 0
        # Apply value to d (input of dff)
        dut.d.value = value_to_store

        await Timer(2, units="ns")

        value_stored = int(dut.q.value)
        assert value_stored == value_to_store, "Wrong value stored"
