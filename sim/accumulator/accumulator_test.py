import cocotb
from cocotb.triggers import Timer

import random

input_width = 4
data_width = 8
and_mask = 0xff

max_val_input = (2**(input_width))-1
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
async def accumulator_random_test(dut):
    """Test Accumulator"""

    random.seed(1)
    test_reps = 1000
    await cocotb.start(generate_clock(dut))
    # Set reset to zero
    dut.reset.value = int(0)

    input_sample = random.randint(0, max_val_input)
    print(input_sample)

    # Apply random value to accumulator
    dut.i_data.value = input_sample
    # Signal that accumulator can start
    dut.i_val_acc = int(1)

    await Timer(8, units="ns")
