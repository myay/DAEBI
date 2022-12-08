import cocotb
from cocotb.triggers import Timer, RisingEdge

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
    test_reps = 1
    await cocotb.start(generate_clock(dut))
    # Set reset to zero
    dut.reset.value = int(0)

    for i in range(0, test_reps):
        acc_reg = 0
        input_sample = random.randint(0, max_val_input)
        acc_reg += input_sample
        acc_reg = acc_reg & and_mask

        # Apply random value to accumulator
        dut.i_data.value = input_sample
        # Signal that accumulator can start
        dut.i_val_acc.value = int(1)

        # Wait for accumulator to signal the completion
        # await Timer(8, units="ns")
        await RisingEdge(dut.o_val_acc)
        dut_result = dut.o_data.value
        assert dut_result == acc_reg, "Wrong addition"

        # reset input state
        dut.i_val_acc.value = int(0)
        await Timer(2, units="ns")
