import cocotb
from cocotb.triggers import Timer

import random
### the code in comments causes the message
## vpi_get: unknown property
# data_width = int(cocotb.top.data_width)
# addr_width = int(cocotb.top.addr_width)
# nr_regs = int(cocotb.top.nr_regs)

data_width = 4
addr_width = 2
nr_regs = 4

max_val_data = (2**(data_width))-1
max_val_addr = (2**(addr_width))-1
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
async def regfile_random_test(dut):
    """Test Regfile"""

    random.seed(1)
    test_reps = 1000
    dut.a1.value = int(0)
    dut.reset.value = int(0)
    await cocotb.start(generate_clock(dut))

    # Test the storing and reading of data
    for i in range(0, test_reps):
        value_to_store = random.randint(0, max_val_data)
        addr_to_store_value = random.randint(0, addr_width)
        # print("val", value_to_store)
        # print("addr", addr_to_store_value)

        # Write to register
        # Apply random address to port a3
        dut.a3.value = addr_to_store_value
        # Apply random value to write into random address
        dut.wd3.value = value_to_store
        # Set write enable to 1
        dut.we3.value = int(1)
        # wait for clock to write
        await Timer(2, units="ns")

        # disable write enable and read the register that was written
        dut.we3.value = int(0)
        dut.a1.value = addr_to_store_value
        await Timer(2, units="ns")
        returned_value = int(dut.rd1.value)
        assert returned_value == value_to_store

    # Test the reset
    dut.reset.value = int(1)
    await Timer(2, units="ns")
    # Read all registers and test whether they are all zero
    for i in range(0, max_val_addr+1):
        dut.a1.value = int(i)
        await Timer(2, units="ns")
        returned_value = int(dut.rd1.value)
        assert returned_value == int(0)
