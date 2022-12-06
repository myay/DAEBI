import cocotb
from cocotb.triggers import Timer

import random

nr_xnor_gates = 4
max_xnor_val = (2**(nr_xnor_gates))-1

# corner cases test
@cocotb.test()
async def xnor_array_test_cornercases(dut):
    """Test XNOR Array"""

    xnor_inputs_1 = [0, max_xnor_val]
    xnor_inputs_2 = [0, max_xnor_val]

    for i in range(len(xnor_inputs_1)):
        for j in range(len(xnor_inputs_2)):
            # Compute with python-based xor
            xor_outputs = (xnor_inputs_1[i] ^ xnor_inputs_2[j])

            dut.xnor_inputs_1.value = xnor_inputs_1[i]
            dut.xnor_inputs_2.value = xnor_inputs_2[j]

            await Timer(1, units="ns")

            # Invert output of xnor array to match xor
            xor_dut = int(~dut.xnor_outputs.value, 2)
            assert xor_dut == xor_outputs, "Wrong XNOR output"

# random test
@cocotb.test()
async def xnor_array_test_random(dut):
    """Test XNOR Array"""

    random.seed(1)
    test_reps = 1000

    for i in range(0, test_reps):
        xnor_inputs_1 = random.randint(0, max_xnor_val)
        xnor_inputs_2 = random.randint(0, max_xnor_val)

        # Compute with python-based xor
        xor_outputs = (xnor_inputs_1 ^ xnor_inputs_2)

        dut.xnor_inputs_1.value = xnor_inputs_1
        dut.xnor_inputs_2.value = xnor_inputs_2

        await Timer(1, units="ns")

        # Invert output of xnor array to match xor
        xor_dut = int(~dut.xnor_outputs.value, 2)
        assert xor_dut == xor_outputs, "Wrong XNOR output"
