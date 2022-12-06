import cocotb
from cocotb.triggers import Timer

import random

@cocotb.test()
async def xnor_array_test(dut):
    """Test XNOR Array"""

    nr_xnor_gates = 4
    max_xnor_val = (2**(nr_xnor_gates))-1
    random.seed(1)
    test_reps = 100

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
