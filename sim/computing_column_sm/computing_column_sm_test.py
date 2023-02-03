import cocotb
from cocotb.triggers import Timer, RisingEdge, Lock

import random

nr_xnor_gates = 64
output_width = 32

max_xnor_val = (2**(nr_xnor_gates))-1
max_output_val = (2**(output_width))-1
cycles = 1
delay = 20

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

async def check_res(dut, acc_result, less, eq, th):
    # print("I'm executing", acc_result)
    # Assign threshold one clock cycle before result of dut is returned
    await Timer(18, units="ns")
    dut.threshold_in.value = th
    await Timer(1, units="ns")
    # await Timer(1, units="ns")
    # print("I waited 20 ns, acc_result: ", acc_result)
    # dut_result = int(dut.o_data_cc.value)
    dut_less = int(dut.less_cc.value)
    dut_eq = int(dut.eq_cc.value)
    # print("value:", acc_result)
    # print("less:", int(less))
    # print("eq:", int(eq))
    # print("th:", th)
    # print("DUT value:", dut_result)
    # print("DUT less:", dut_less)
    # print("DUT eq:", dut_eq)
    # print("---")
    # assert dut_result == int(acc_result)
    assert dut_less == int(less)
    assert dut_eq == int(eq)
    # wait 2 ns because o_data_acc is ready one cycle later
    await Timer(10, units="ns")
    dut_result = int(dut.o_data_cc.value)
    assert dut_result == int(acc_result)


async def set_inputs(dut, acc_result, cycles_param=cycles):
    """Set outputs."""
    random.seed(1)
    dut.xnor_inputs_1.value = int(0)
    dut.xnor_inputs_2.value = int(0)
    dut.threshold_in.value = int(0)
    dut.register_select.value = int(0)
    # acc_result = 0
    for cycle in range(cycles_param):
        # Sample inputs
        xnor_inputs_1 = random.randint(0, max_xnor_val)
        xnor_inputs_2 = random.randint(0, max_xnor_val)
        # Perform xnor and popcount
        xor_outputs = (xnor_inputs_1 ^ xnor_inputs_2)
        ppop = nr_xnor_gates - bin(xor_outputs).count('1')
        # print("popc", ppop)
        less = None
        eq = None
        threshold = None
        async with lock:
            acc_result += ppop
            threshold = random.randint(acc_result-nr_xnor_gates/2, acc_result+nr_xnor_gates/2)
            less = acc_result < threshold
            eq = acc_result == threshold
            # print("acc_result", acc_result)

        dut.xnor_inputs_1.value = xnor_inputs_1
        dut.xnor_inputs_2.value = xnor_inputs_2
        # Start a coroutine that checks the result after the delay
        await cocotb.start(check_res(dut, acc_result, less, eq, threshold))
        await Timer(2, units="ns")

# Random test
@cocotb.test()
async def computing_column_sm_test(dut):
    """Test Computing Column SM"""

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

    # # Test reset
    # dut.rst.value = int(1)
    # await cocotb.start(generate_clock_param(dut, 100))
    # await Timer(22, units="ns")
    # dut_result = int(dut.o_data_cc.value)
    # assert dut_result == int(0), "Reset did not work as expected"
    #
    # # Run tests again, with reset set to 0, but with less cycles
    # dut.rst.value = int(0)
    # await Timer(1, units="ns")
    # await cocotb.start(set_inputs(dut, acc_result, 50))
    # await Timer(total_test_time+10, units="ns")
