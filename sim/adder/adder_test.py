import cocotb
from cocotb.triggers import Timer

import random

w_i = 4
max_val = (2**(w_i))-1
bitmask = 0xf

# corner cases test
@cocotb.test()
async def adder_test_cornercases(dut):
    """Test XNOR Array"""

    a_l = [0, max_val]
    b_l = [0, max_val]

    for i in range(len(a_l)):
        for j in range(len(b_l)):
            # Compute with python based addition
            y = a_l[i] + b_l[j]
            # Apply bitmask
            y = y & bitmask

            dut.a.value = a_l[i]
            dut.b.value = b_l[j]

            await Timer(1, units="ns")

            # Invert output of xnor array to match xor
            add_dut = dut.y.value
            assert add_dut == y, "Wrong addition"

# random test
@cocotb.test()
async def adder_test_random(dut):
    """Test Adder"""

    random.seed(1)
    test_reps = 1000

    for i in range(0, test_reps):
        a = random.randint(0, max_val)
        b = random.randint(0, max_val)

        # Compute with python-based addition
        y = a + b
        # Apply bitmask
        y = y & bitmask

        dut.a.value = a
        dut.b.value = b

        await Timer(1, units="ns")

        add_dut = dut.y.value
        assert add_dut == y, "Wrong addition"
