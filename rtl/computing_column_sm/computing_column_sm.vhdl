library ieee;
use ieee.std_logic_1164.all;

entity computing_column_sm is
  generic(
    nr_xnor_gates: integer; -- Number of XNOR gates
    acc_data_width: integer; -- Width of registers in accumulator
    nr_popc_bits_o: integer; -- Number of output bits from the popcount unit
    nr_regs_accm: integer; -- Number of registers in the multiregs accumulator
    addr_width_accm: integer -- Number of addresses neeed in the multiregs accumulator
  );
  port(
    clk           : in std_logic;
    rst           : in std_logic;
    xnor_inputs_1 : in std_logic_vector(nr_xnor_gates-1 downto 0); -- First inputs
    xnor_inputs_2 : in std_logic_vector(nr_xnor_gates-1 downto 0); -- Second inputs
    threshold_in  : in std_logic_vector(acc_data_width-1 downto 0); -- Threshold data
    register_select: in std_logic_vector(addr_width_accm-1 downto 0);
    o_data_cc     : out std_logic_vector(acc_data_width-1 downto 0); -- Output data
    less_cc : out std_logic;
    eq_cc : out std_logic
  );
end computing_column_sm;

architecture rtl of computing_column_sm is
-- For accumulator_multiregs
-- nr_popc_bits_o is input_width
-- acc_data_width is data_width
-- new param: nr_regs
-- new param: log2(nr_regs) is addr_width

-- Signals for XNOR array
signal in_cc_1 : std_logic_vector(nr_xnor_gates-1 downto 0) := (others => '0'); -- Input 1 for xnor array
signal in_cc_2 : std_logic_vector(nr_xnor_gates-1 downto 0) := (others => '1'); -- Input 2 for xnor array
signal o_data_xnor : std_logic_vector(nr_xnor_gates-1 downto 0) := (others => '0'); -- Output of xnor array

-- Signals for popcount unit
signal o_data_popc : std_logic_vector(nr_popc_bits_o-1 downto 0) := (others => '0'); -- Output of popcount unit
signal rst_popc, o_val_popc: std_logic := '0'; -- Reset and output signal
signal i_val_popc : std_logic := '1';

-- Signals for accumulator
signal rst_acc, o_val_acc: std_logic := '0'; -- Reset and signal for finished computations
signal i_data_acc : std_logic_vector(nr_popc_bits_o-1 downto 0) := (others => '0');
signal o_data_acc : std_logic_vector(acc_data_width-1 downto 0) := (others => '0'); -- Output for accumulator
signal rst_pipe : std_logic_vector(8 downto 0) := (others => '0');

-- Signals for comparator
signal threshold_cc : std_logic_vector(acc_data_width-1 downto 0) := (others => '0'); -- Output for accumulator

begin
  -- Instantiate xnor array
  inst_xnor_array : entity work.xnor_gate_array(rtl)
    generic map(nr_xnor_gates => nr_xnor_gates)
    port map(
      xnor_inputs_1 => in_cc_1,
      xnor_inputs_2 => in_cc_2,
      xnor_outputs => o_data_xnor
    );

  -- Instantiate popcount unit
  inst_popcount : entity work.popcount(rtl)
    port map(
      i_val => i_val_popc,
      clk => clk,
      rst => rst_popc,
      stream_i => o_data_xnor,
      o_val => o_val_popc,
      stream_o => o_data_popc
    );

  inst_accumulator_multiregs: entity work.accumulator_multiregs(bhv)
    generic map(
      input_width => nr_popc_bits_o,
      data_width => acc_data_width,
      addr_width => addr_width_accm,
      nr_regs => nr_regs_accm
    )
    port map(
      i_val_acc => o_val_popc,
      clk => clk,
      reset => rst_acc,
      r_s => register_select,
      i_data => o_data_popc,
      o_data => o_data_acc,
      o_val_acc => o_val_acc
    );

  -- Instantiate comparator
  inst_comparator : entity work.comparator(bhv)
    generic map(bit_width => acc_data_width)
    port map(
      x => o_data_acc,
      threshold => threshold_cc,
      less => less_cc,
      eq => eq_cc
    );

  -- Store reset signal in pipeline to reach accumulator at the right timing
  process(clk) begin
    if rising_edge(clk) then
      rst_pipe <= rst_pipe(7 downto 0) & rst;
      rst_acc <= rst_pipe(8);
    end if;
  end process;

  process(clk) begin
    -- Update clock signal of accumulator
    -- clk_acc <= clk;
    if rising_edge(clk) then
      -- Assign inputs to input buffers
      in_cc_1 <= xnor_inputs_1;
      in_cc_2 <= xnor_inputs_2;
      threshold_cc <= threshold_in;
      -- Assign output of popcount value to input of accumulator
      if o_val_popc = '1' then
        i_data_acc <= o_data_popc;
      end if;
      -- Assign output of accumulator to output pins of cc
      -- if o_val_acc = '1' then
      o_data_cc <= o_data_acc;
      -- end if;
    end if;
  end process;
end rtl;
