import cocotb
from cocotb.triggers import Timer

import random

bit_width = 16
max_val = (2**(bit_width))-1

test_reps = 10000
eq_factor = 10 # every (test_reps/eq_factor) iteration, test for equality
cycles = test_reps

async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(cycles):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")

@cocotb.test()
async def comparator_test(dut):
    """Test Comparator"""

    random.seed(1)
    await cocotb.start(generate_clock(dut))

    for i in range(0, test_reps):
        if i % (test_reps/eq_factor) != 0:
            x = random.randint(0, max_val)
            threshold = random.randint(0, max_val)
        else:
            x = random.randint(0, max_val)
            threshold = x

        # compare x to threshold
        comp_less = int(x < threshold)
        # test for equality
        comp_eq = int(x == threshold)

        dut.x.value = x
        dut.threshold.value = threshold

        await Timer(2, units="ns")

        dut_less = int(dut.less.value)
        dut_eq = int(dut.eq.value)

        assert dut_less == comp_less, "Error when comparing for less"
        assert dut_eq == comp_eq, "Error when comparing for equality"
