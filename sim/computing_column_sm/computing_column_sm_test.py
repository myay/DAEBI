import cocotb
from cocotb.triggers import Timer, RisingEdge, Lock

import random

nr_xnor_gates = 64
output_width = 32
nr_regs = 4
and_mask = 0xffff

max_xnor_val = (2**(nr_xnor_gates))-1
max_output_val = (2**(output_width))-1
reps = 500
delay = 35
cycles = reps*delay

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

async def check_res(dut, regs_py, addr_to_store_value, value_to_store, rep):
    # less = regs_py[addr_to_store_value] < threshold
    # eq = regs_py[addr_to_store_value] == threshold
    #
    # dut_less = int(dut.less_cc.value)
    # dut_eq = int(dut.eq_cc.value)
    # print("dut less", dut_less)
    # print("dut eq", dut_eq)
    # assert dut_less == int(less)
    # assert dut_eq == int(eq)
    # await Timer(4, units="ns")
    # assert dut_less == int(less)
    # assert dut_eq == int(eq)
    # print("address", addr_to_store_value)
    # print("value", value_to_store)
    # print("After: Python value", regs_py)
    # print("py th", threshold)
    # print("py x", regs_py[addr_to_store_value])
    # print("py less", less)
    # print("py eq", eq)
    # print("less", less)
    await Timer(16, units="ns")
    dut.register_select.value = int(addr_to_store_value)
    await Timer(10, units="ns")
    dut_result = int(dut.o_data_cc.value)
    # print("Before: Python value", regs_py)
    async with lock:
        regs_py[addr_to_store_value] += value_to_store
        regs_py[addr_to_store_value] = regs_py[addr_to_store_value] & and_mask
    # print("After: Python value", regs_py)
    # print("---")
    # print("python output", regs_py[addr_to_store_value])
    # print("dut output", dut_result)
    assert dut_result == int(regs_py[addr_to_store_value])
    # await Timer(2, units="ns")

async def set_inputs(dut, regs_py):
    """Set inputs."""
    for rep in range(reps):
        # Sample inputs
        xnor_inputs_1 = random.randint(0, max_xnor_val)
        xnor_inputs_2 = random.randint(0, max_xnor_val)
        # Perform xnor and popcount
        xor_outputs = (xnor_inputs_1 ^ xnor_inputs_2)
        ppop = nr_xnor_gates - bin(xor_outputs).count('1')
        addr_to_store_value = int(rep % (nr_regs))

        dut.xnor_inputs_1.value = xnor_inputs_1
        dut.xnor_inputs_2.value = xnor_inputs_2

        await cocotb.start(check_res(dut, regs_py, addr_to_store_value, ppop, rep))
        await Timer(6, units="ns")

# Random test
@cocotb.test()
async def computing_column_sm_test(dut):
    """Test Computing Column SM"""

    random.seed(1)
    total_test_time = reps*delay*2
    acc_result = 0
    await cocotb.start(generate_clock(dut))

    # Create simulation of register file in Python
    regs_py = [int(0) for y in range(nr_regs)]
    dut.rst.value = int(0)

    # await Timer(1, units="ns")
    await cocotb.start(set_inputs(dut, regs_py))
    await Timer(total_test_time, units="ns")
