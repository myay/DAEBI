import cocotb
from cocotb.triggers import Timer, RisingEdge

import random

input_width = 64
# and_mask = int(0b1111111111111)

max_val_input = (2**64) - 1
cycles = 100000

async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(cycles):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")

# Random test
@cocotb.test()
async def popcount_test(dut):
    """Test Popcount"""

    random.seed(1)
    test_reps = 1000
    await cocotb.start(generate_clock(dut))

    # Set input signal and reset to 0
    dut.i_val.value = int(0)
    dut.rst.value = int(0)

    await Timer(1, units="ns")

    for i in range(0, test_reps):
        # Sample random input
        input = random.randint(0, max_val_input)
        ppop = bin(input).count('1')

        dut.i_val.value = int(1)
        dut.stream_i.value = input

        await RisingEdge(dut.o_val)
        returned_value = int(dut.stream_o.value)
        dut.i_val.value = int(~dut.o_val.value) # in design, also set to negation of o_val_acc
        assert returned_value == ppop
        await Timer(4, units="ns")

    # Test reset
    dut.rst.value = int(1)
    await Timer(5, units="ns")
    dut_result = int(dut.stream_o.value)
    assert dut_result == int(0), "Reset did not work as expected"
