import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def xnor_test(dut):
    """Test XNOR"""

    test_input = [[0,0], [0,1], [1,0], [1,1]]
    test_output = [1, 0, 0, 1]

    for i in range(len(test_input)):

        xnor_in_1 = int(test_input[i][0])
        xnor_in_2 = int(test_input[i][1])
        xnor_out = int(test_output[i])

        dut.xnor_in_1.value = xnor_in_1
        dut.xnor_in_2.value = xnor_in_2

        await Timer(1, units="ns")

        assert dut.xnor_out.value == xnor_out, "Wrong XNOR output"
