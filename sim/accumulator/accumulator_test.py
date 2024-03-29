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
    test_reps = 1000
    await cocotb.start(generate_clock(dut))
    acc_reg = 0
    # Set reset to zero
    dut.reset.value = int(0)
    # dut.i_val_acc.value = int(0)

    for i in range(0, test_reps):
        input_sample = random.randint(0, max_val_input)
        # Calculate Python-based accumulation
        acc_reg += input_sample
        acc_reg = acc_reg & and_mask
        # await Timer(2, units="ns")

        # Apply random value to accumulator
        dut.i_data.value = input_sample
        # Signal that accumulator can start processing input
        # dut.i_val_acc.value = int(1)
        await Timer(2, units="ns")
        # # Set input signal to zero (only one rectangle signal needed)
        # dut.i_val_acc.value = int(0)

        # Wait for accumulator to signal the completion
        # await Timer(8, units="ns")
        # await RisingEdge(dut.o_val_acc)
        # dut.i_val_acc.value = int(~dut.o_val_acc.value) # in design, also set to negation of o_val_acc
        dut_result = int(dut.o_data.value)
        # print("dut_result", dut_result)
        # print("acc_reg", acc_reg)
        assert dut_result == acc_reg, "Wrong addition"
        # await Timer(2, units="ns")


    # Test reset
    dut.reset.value = int(1)
    await Timer(2, units="ns")
    dut_result = int(dut.o_data.value)
    assert dut_result == int(0), "Reset did not work as expected"
