import cocotb
from cocotb.triggers import Timer, RisingEdge, Lock

import random

nr_xnor_gates = 64
output_width = 32

max_xnor_val = (2**(nr_xnor_gates))-1
cycles = 100
delay = 10

lock = Lock()

async def generate_clock_param(dut, cycles_param):
    """Generate clock pulses."""

    for cycle in range(cycles_param):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")

async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(cycles+delay):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")

async def check_res(dut, acc_result):
    # print("I'm executing", acc_result)
    await Timer(22, units="ns")
    # print("I waited 20 ns, acc_result: ", acc_result)
    dut_result = int(dut.o_data_cc.value)
    # print("DUT value:", dut_result)
    assert dut_result == acc_result


async def set_inputs(dut, acc_result, cycles_param=cycles):
    """Set outputs."""
    random.seed(1)
    # acc_result = 0
    for cycle in range(cycles_param):
        # Sample inputs
        xnor_inputs_1 = random.randint(0, max_xnor_val)
        xnor_inputs_2 = random.randint(0, max_xnor_val)
        # Perform xnor and popcount
        xor_outputs = (xnor_inputs_1 ^ xnor_inputs_2)
        ppop = nr_xnor_gates - bin(xor_outputs).count('1')
        # print("popc", ppop)
        async with lock:
            acc_result += ppop
            # print("acc_result", acc_result)

        dut.xnor_inputs_1.value = xnor_inputs_1
        dut.xnor_inputs_2.value = xnor_inputs_2
        # Start a coroutine that checks the result after the delay
        await cocotb.start(check_res(dut, acc_result))
        await Timer(2, units="ns")

# Random test
@cocotb.test()
async def computing_column_vm_test(dut):
    """Test Computing Column VM"""

    random.seed(1)
    total_test_time = 2*cycles + 2*delay
    acc_result = 0
    await cocotb.start(generate_clock(dut))

    # Set input, weight and reset to 0
    dut.rst.value = int(0)
    dut.xnor_inputs_1.value = int(0)
    dut.xnor_inputs_2.value = int(0)

    # dut_result = dut.o_data_cc.value
    # assert dut_result == 64
    # Add delay of 1 to change inputs at every rising edge
    await Timer(1, units="ns")
    await cocotb.start(set_inputs(dut, acc_result))
    await Timer(total_test_time+10, units="ns")
    # await cocotb.start(check_outputs(dut))
    # await Timer(total_test_time, units="ns")

    # Test reset
    dut.rst.value = int(1)
    await cocotb.start(generate_clock_param(dut, 100))
    await Timer(22, units="ns")
    dut_result = int(dut.o_data_cc.value)
    assert dut_result == int(0), "Reset did not work as expected"

    # Run tests again, with reset set to 0, but with less cycles
    dut.rst.value = int(0)
    await Timer(1, units="ns")
    await cocotb.start(set_inputs(dut, acc_result, 50))
    await Timer(total_test_time+10, units="ns")
